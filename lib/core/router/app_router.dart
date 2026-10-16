import 'package:flutter/material.dart';

import '../../features/details/screens/product_details_screen.dart';
import '../../features/home/domain/entities/product_entity.dart';
import '../../features/main_navigation/screens/main_navigation_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../errors/exceptions.dart';
import '../network/api_client.dart';
import '../../features/home/data/models/product_model.dart';
import 'package:dio/dio.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String productDetails = '/product/:id';

  static String productDetailsPath(String productId) => '/product/$productId';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final uri = Uri.tryParse(name);

    if (uri != null && uri.pathSegments.length == 2 && uri.pathSegments.first == 'product') {
      final idStr = uri.pathSegments[1];
      final productId = int.tryParse(idStr);

      if (productId != null) {
        return _DeepLinkProductRoute(productId: productId);
      }
    }

    if (name == AppRoutes.home) {
      return MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: (_) => const SplashScreen(),
      settings: settings,
    );
  }
}

class _DeepLinkProductRoute extends MaterialPageRoute<void> {
  _DeepLinkProductRoute({required int productId})
      : super(
          builder: (_) => _ProductDeepLinkScreen(productId: productId),
        );
}

class _ProductDeepLinkScreen extends StatefulWidget {
  final int productId;
  const _ProductDeepLinkScreen({required this.productId});

  @override
  State<_ProductDeepLinkScreen> createState() => _ProductDeepLinkScreenState();
}

class _ProductDeepLinkScreenState extends State<_ProductDeepLinkScreen> {
  late Future<ProductEntity> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProduct(widget.productId);
  }

  Future<ProductEntity> _fetchProduct(int id) async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('products/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(ApiClient.formatDioError(e));
    } catch (e) {
      throw ServerException('Failed to load product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductEntity>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return _ErrorScreen(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {
              _productFuture = _fetchProduct(widget.productId);
            }),
          );
        }

        return ProductDetailsScreen(product: snapshot.data!);
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading product...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Could not load product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
