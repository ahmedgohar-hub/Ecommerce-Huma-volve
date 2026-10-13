import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsUseCase _getProductsUseCase;
  Timer? _debounceTimer;

  HomeCubit({
    GetCategoriesUseCase? getCategoriesUseCase,
    GetProductsUseCase? getProductsUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase ??
            GetCategoriesUseCase(HomeRepositoryImpl(HomeRemoteDataSourceImpl())),
        _getProductsUseCase = getProductsUseCase ??
            GetProductsUseCase(HomeRepositoryImpl(HomeRemoteDataSourceImpl())),
        super(const HomeState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      error: null,
      isProductsLoading: true,
    ));

    try {
      final results = await Future.wait([
        _getCategoriesUseCase(const NoParams()),
        _getProductsUseCase(const GetProductsParams()),
      ]);

      final categories = results[0] as List<CategoryEntity>;
      final products = results[1] as List<ProductEntity>;

      emit(state.copyWith(
        status: HomeStatus.success,
        categories: categories,
        products: products,
        isProductsLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        error: e.toString(),
        isProductsLoading: false,
      ));
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    if (state.selectedCategoryId == categoryId && !state.isError) {
      return;
    }

    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
      isProductsLoading: true,
      error: null,
    ));

    await _fetchFilteredProducts(
      categoryId: categoryId,
      search: state.searchQuery,
    );
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchProducts(query);
    });
  }

  Future<void> searchProducts(String query) async {
    emit(state.copyWith(
      searchQuery: query,
      isProductsLoading: true,
      error: null,
    ));

    await _fetchFilteredProducts(
      categoryId: state.selectedCategoryId,
      search: query,
    );
  }

  Future<void> _fetchFilteredProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      final products = await _getProductsUseCase(
        GetProductsParams(
          categoryId: categoryId,
          search: search,
        ),
      );

      emit(state.copyWith(
        status: HomeStatus.success,
        products: products,
        isProductsLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProductsLoading: false,
        error: e.toString(),
      ));
    }
  }

  void retry() {
    if (state.categories.isEmpty) {
      loadInitialData();
    } else {
      emit(state.copyWith(
        isProductsLoading: true,
        error: null,
      ));
      _fetchFilteredProducts(
        categoryId: state.selectedCategoryId,
        search: state.searchQuery,
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
