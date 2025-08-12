import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

enum DataSource { cache, network, none }

class ProductRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  ProductRepository({
    ApiService? apiService,
    CacheService? cacheService,
  })  : _apiService = apiService ?? ApiService(),
        _cacheService = cacheService ?? CacheService();

  Future<ProductRepositoryResult> getProducts({bool forceRefresh = false}) async {
    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedProducts = await _cacheService.getCachedProducts();
        final isCacheStale = await _cacheService.isCacheStale();

        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          // Return cached data immediately
          if (!isCacheStale) {
            return ProductRepositoryResult(
              products: cachedProducts,
              source: DataSource.cache,
              isLoading: false,
              error: null,
            );
          } else {
            // Cache is stale, return cached data but indicate we need fresh data
            return ProductRepositoryResult(
              products: cachedProducts,
              source: DataSource.cache,
              isLoading: true,
              error: null,
              needsRefresh: true,
            );
          }
        }
      }

      // Fetch from network
      final products = await _apiService.fetchProducts();

      // Cache the fresh data
      await _cacheService.cacheProducts(products);

      return ProductRepositoryResult(
        products: products,
        source: DataSource.network,
        isLoading: false,
        error: null,
      );

    } catch (e) {
      // Network failed, try to return cached data as fallback
      final cachedProducts = await _cacheService.getCachedProducts();

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return ProductRepositoryResult(
          products: cachedProducts,
          source: DataSource.cache,
          isLoading: false,
          error: e.toString(),
        );
      }

      // No cached data available
      return ProductRepositoryResult(
        products: [],
        source: DataSource.none,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }
}

class ProductRepositoryResult {
  final List<Product> products;
  final DataSource source;
  final bool isLoading;
  final String? error;
  final bool needsRefresh;

  ProductRepositoryResult({
    required this.products,
    required this.source,
    required this.isLoading,
    this.error,
    this.needsRefresh = false,
  });
}
