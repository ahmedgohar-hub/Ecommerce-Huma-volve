import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<List<CategoryEntity>> getCategories();

  Future<List<ProductEntity>> getProducts({
    int? categoryId,
    String? search,
    int limit = 40,
    int offset = 0,
  });
}
