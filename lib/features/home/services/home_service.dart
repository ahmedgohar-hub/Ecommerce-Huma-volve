import '../../../../core/network/api_client.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';

@Deprecated('Use HomeRepository or UseCases instead')
class HomeService {
  final HomeRemoteDataSource remoteDataSource;

  HomeService([ApiClient? client])
      : remoteDataSource = HomeRemoteDataSourceImpl(client);

  Future<List<CategoryModel>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    int limit = 40,
    int offset = 0,
  }) async {
    return await remoteDataSource.getProducts(
      categoryId: categoryId,
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
