import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repository/product_repository.dart';

enum LoadingState { initial, loadingFromCache, loadingFromNetwork, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  List<Product> _products = [];
  LoadingState _loadingState = LoadingState.initial;
  String? _error;
  DataSource _lastDataSource = DataSource.none;

  // Getters
  List<Product> get products => _products;
  LoadingState get loadingState => _loadingState;
  String? get error => _error;
  DataSource get lastDataSource => _lastDataSource;

  bool get isLoading => _loadingState == LoadingState.loadingFromCache ||
      _loadingState == LoadingState.loadingFromNetwork;

  String get statusMessage {
    switch (_loadingState) {
      case LoadingState.initial:
        return 'Initializing...';
      case LoadingState.loadingFromCache:
        return 'Loading from cache...';
      case LoadingState.loadingFromNetwork:
        return 'Fetching from network...';
      case LoadingState.loaded:
        switch (_lastDataSource) {
          case DataSource.cache:
            return 'Loaded from cache';
          case DataSource.network:
            return 'Up-to-date from network';
          case DataSource.none:
            return 'No data available';
        }
      case LoadingState.error:
        return _error ?? 'An error occurred';
    }
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _loadingState == LoadingState.loadingFromNetwork) {
      return; // Already loading
    }

    _error = null;

    if (_products.isEmpty || forceRefresh) {
      _loadingState = LoadingState.loadingFromCache;
      notifyListeners();
    }

    try {
      final result = await _repository.getProducts(forceRefresh: forceRefresh);

      _products = result.products;
      _lastDataSource = result.source;
      _error = result.error;

      if (result.needsRefresh) {
        // Cache was stale, fetch fresh data
        _loadingState = LoadingState.loadingFromNetwork;
        notifyListeners();

        final freshResult = await _repository.getProducts(forceRefresh: true);
        _products = freshResult.products;
        _lastDataSource = freshResult.source;
        _error = freshResult.error;
      }

      _loadingState = result.error != null ? LoadingState.error : LoadingState.loaded;

    } catch (e) {
      _error = e.toString();
      _loadingState = LoadingState.error;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadProducts(forceRefresh: true);
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
    _products = [];
    _loadingState = LoadingState.initial;
    _error = null;
    notifyListeners();
  }
}
