import 'package:hive/hive.dart';
import '../models/product_model.dart';

class CacheService {
  static const String _boxName = 'products_cache';
  static const String _cacheKey = 'cached_products';

  Box<CachedProductData>? _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<CachedProductData>(_boxName);
  }

  Future<List<Product>?> getCachedProducts() async {
    if (_box == null) await initialize();

    final cachedData = _box!.get(_cacheKey);
    if (cachedData == null) return null;

    return cachedData.products;
  }

  Future<bool> isCacheStale() async {
    if (_box == null) await initialize();

    final cachedData = _box!.get(_cacheKey);
    if (cachedData == null) return true;

    return cachedData.isStale;
  }

  Future<void> cacheProducts(List<Product> products) async {
    if (_box == null) await initialize();

    final cachedData = CachedProductData(
      products: products,
      cachedAt: DateTime.now(),
    );

    await _box!.put(_cacheKey, cachedData);
  }

  Future<void> clearCache() async {
    if (_box == null) await initialize();
    await _box!.clear();
  }

  Future<DateTime?> getLastCacheTime() async {
    if (_box == null) await initialize();

    final cachedData = _box!.get(_cacheKey);
    return cachedData?.cachedAt;
  }
}
