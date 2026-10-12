import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeService {
  final ApiClient apiClient;

  HomeService([ApiClient? client]) : apiClient = client ?? ApiClient();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.categories);
      if (response.data is List) {
        final list = response.data as List;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .where((cat) => cat.name.trim().isNotEmpty)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiClient.formatDioError(e);
    } catch (e) {
      throw 'Failed to load categories: $e';
    }
  }

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    int limit = 40,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      if (categoryId != null && categoryId > 0) {
        queryParams['categoryId'] = categoryId;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['title'] = search.trim();
      }

      final response = await apiClient.dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        final list = response.data as List;
        return list
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiClient.formatDioError(e);
    } catch (e) {
      throw 'Failed to load products: $e';
    }
  }
}
