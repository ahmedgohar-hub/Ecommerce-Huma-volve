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

  // ── Initial load ──────────────────────────────────────────────────────────
  /// Fetches categories and the first page of products simultaneously.
  Future<void> loadInitialData() async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      error: null,
      isProductsLoading: true,
      // Reset pagination on every full reload
      currentPage: 0,
      hasReachedMax: false,
      isLoadingMore: false,
    ));

    try {
      final results = await Future.wait([
        _getCategoriesUseCase(const NoParams()),
        _getProductsUseCase(const GetProductsParams(
          limit: kProductsPageSize,
          offset: 0,
        )),
      ]);

      final categories = results[0] as List<CategoryEntity>;
      final products = results[1] as List<ProductEntity>;

      emit(state.copyWith(
        status: HomeStatus.success,
        categories: categories,
        products: products,
        isProductsLoading: false,
        error: null,
        currentPage: 0,
        // If the first batch is already smaller than a full page → no more data
        hasReachedMax: products.length < kProductsPageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        error: e.toString(),
        isProductsLoading: false,
      ));
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  /// Loads the next page and **appends** results to the existing list.
  /// Does nothing if already loading or the end has been reached.
  Future<void> loadMoreProducts() async {
    // Guard: skip if a load is already running or no more data exists
    if (state.isLoadingMore || state.hasReachedMax || state.isProductsLoading) {
      return;
    }

    final nextPage = state.currentPage + 1;
    final nextOffset = nextPage * kProductsPageSize;

    emit(state.copyWith(isLoadingMore: true, error: null));

    try {
      final newProducts = await _getProductsUseCase(
        GetProductsParams(
          categoryId: state.selectedCategoryId,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          limit: kProductsPageSize,
          offset: nextOffset,
        ),
      );

      emit(state.copyWith(
        status: HomeStatus.success,
        // Append new items to the existing list
        products: [...state.products, ...newProducts],
        isLoadingMore: false,
        error: null,
        currentPage: nextPage,
        hasReachedMax: newProducts.length < kProductsPageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
    }
  }

  // ── Category filter ───────────────────────────────────────────────────────
  Future<void> selectCategory(int? categoryId) async {
    if (state.selectedCategoryId == categoryId && !state.isError) return;

    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
      isProductsLoading: true,
      error: null,
      // Reset pagination when filter changes
      currentPage: 0,
      hasReachedMax: false,
      isLoadingMore: false,
    ));

    await _fetchFilteredProducts(
      categoryId: categoryId,
      search: state.searchQuery,
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────
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
      // Reset pagination on new search
      currentPage: 0,
      hasReachedMax: false,
      isLoadingMore: false,
    ));

    await _fetchFilteredProducts(
      categoryId: state.selectedCategoryId,
      search: query,
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────
  /// Always resets to page 0 and replaces the product list (used after a
  /// filter or search change).
  Future<void> _fetchFilteredProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      final products = await _getProductsUseCase(
        GetProductsParams(
          categoryId: categoryId,
          search: search,
          limit: kProductsPageSize,
          offset: 0,
        ),
      );

      emit(state.copyWith(
        status: HomeStatus.success,
        products: products,
        isProductsLoading: false,
        error: null,
        currentPage: 0,
        hasReachedMax: products.length < kProductsPageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProductsLoading: false,
        error: e.toString(),
      ));
    }
  }

  // ── Retry ─────────────────────────────────────────────────────────────────
  void retry() {
    if (state.categories.isEmpty) {
      loadInitialData();
    } else {
      emit(state.copyWith(
        isProductsLoading: true,
        error: null,
        currentPage: 0,
        hasReachedMax: false,
        isLoadingMore: false,
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
