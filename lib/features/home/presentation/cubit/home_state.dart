import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

enum HomeStatus { initial, loading, success, error }

/// Number of products fetched per page.
const int kProductsPageSize = 10;

class HomeState {
  final HomeStatus status;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? error;
  final bool isProductsLoading;

  // ── Pagination ──────────────────────────────────────────────────────
  /// The current page index (0-based offset pages).
  final int currentPage;

  /// True when the last API call returned fewer items than [kProductsPageSize],
  /// meaning there are no more pages to load.
  final bool hasReachedMax;

  /// True while a "load more" request is in-flight (bottom of list spinner).
  final bool isLoadingMore;
  // ────────────────────────────────────────────────────────────────────

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.error,
    this.isProductsLoading = false,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == HomeStatus.loading;
  bool get isSuccess => status == HomeStatus.success;
  bool get isError => status == HomeStatus.error;

  HomeState copyWith({
    HomeStatus? status,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    String? error,
    bool? isProductsLoading,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
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
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
