import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService({required this.navigatorKey});

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        _handleUri(initialUri);
      }
    } catch (_) {}

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  void _handleUri(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.length == 2 && segments.first == 'product') {
      final productId = int.tryParse(segments[1]);
      if (productId != null) {
        _navigateTo(AppRoutes.productDetailsPath(productId.toString()));
        return;
      }
    }

    _navigateTo(AppRoutes.home);
  }

  void _navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}
