import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl([HomeRemoteDataSource? dataSource])
      : remoteDataSource = dataSource ?? HomeRemoteDataSourceImpl();

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getProducts({
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
