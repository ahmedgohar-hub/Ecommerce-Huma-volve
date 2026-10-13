import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetProductsParams {
  final int? categoryId;
  final String? search;
  final int limit;
  final int offset;

  const GetProductsParams({
    this.categoryId,
    this.search,
    this.limit = 40,
    this.offset = 0,
  });
}

class GetProductsUseCase implements UseCase<List<ProductEntity>, GetProductsParams> {
  final HomeRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(GetProductsParams params) {
    return repository.getProducts(
      categoryId: params.categoryId,
      search: params.search,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
