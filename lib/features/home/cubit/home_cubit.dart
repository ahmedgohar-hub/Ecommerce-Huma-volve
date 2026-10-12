import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService homeService;
  Timer? _debounceTimer;

  HomeCubit({HomeService? service})
      : homeService = service ?? HomeService(),
        super(const HomeState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      error: null,
      isProductsLoading: true,
    ));

    try {
      final results = await Future.wait([
        homeService.getCategories(),
        homeService.getProducts(),
      ]);

      final categories = results[0] as List<dynamic>;
      final products = results[1] as List<dynamic>;

      emit(state.copyWith(
        status: HomeStatus.success,
        categories: categories.cast(),
        products: products.cast(),
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
      final products = await homeService.getProducts(
        categoryId: categoryId,
        search: search,
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
