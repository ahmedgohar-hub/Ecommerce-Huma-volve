import '../models/category_model.dart';
import '../models/product_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? error;
  final bool isProductsLoading;

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.error,
    this.isProductsLoading = false,
  });

  bool get isLoading => status == HomeStatus.loading;
  bool get isSuccess => status == HomeStatus.success;
  bool get isError => status == HomeStatus.error;

  HomeState copyWith({
    HomeStatus? status,
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    String? error,
    bool? isProductsLoading,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
    );
  }
}
