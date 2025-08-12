import 'package:flutter/material.dart';
import 'package:product_list/repository/product_repository.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
import '../widgets/loading_indicator.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Products',
          style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<ProductProvider>().refresh();
            },
          ),
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == 'clear_cache') {
                context.read<ProductProvider>().clearCache();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_cache',
                child: Text('Clear Cache'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Show error message if there's an error and no cached data
          if (productProvider.error != null && productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      productProvider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => productProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show loading indicator if no data yet
          if (productProvider.products.isEmpty && productProvider.isLoading) {
            return LoadingIndicator(message: productProvider.statusMessage);
          }

          // Show product list
          return Column(
            children: [
              // Status bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: _getStatusColor(productProvider),
                child: Row(
                  children: [
                    if (productProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    if (productProvider.isLoading) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        productProvider.statusMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (productProvider.error != null)
                      const Icon(Icons.warning, color: Colors.white, size: 16),
                  ],
                ),
              ),

              // Product list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => productProvider.refresh(),
                  child: ListView.builder(
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      return ProductItem(
                        product: productProvider.products[index],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(ProductProvider provider) {
    if (provider.error != null) {
      return Colors.orange; // Warning color for errors with cached data
    } else if (provider.isLoading) {
      return Colors.blue;
    } else if (provider.lastDataSource == DataSource.network) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
}
