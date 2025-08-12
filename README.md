# product_list

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

/// ReadMe file of this project
# First, get all dependencies
Dependencies used in this project:
provider: ^6.0.5
hive: ^2.2.3
hive_flutter: ^1.1.0
http: ^1.1.0
path_provider: ^2.1.1

dev_dependencies:
hive_generator: ^2.0.1
build_runner: ^2.4.6
flutter pub get

# Then run the code generator
# Run this to generate the ProductAdapter or Product Model.g file
flutter packages pub run build_runner build --delete-conflicting-outputs

# Project Structure
lib/
├── main.dart
├── models/
│   └── product_model.dart
├── services/
│   ├── api_service.dart
│   └── cache_service.dart
├── repository/
│   └── product_repository.dart
├── providers/
│   └── product_provider.dart
├── screens/
│   └── product_list_screen.dart
└── widgets/
├── product_item.dart
└── loading_indicator.dart

# Core Components
ProductRepository: Central data coordination layer that intelligently manages multiple data sources
ApiService: Handles remote API communication with error handling and timeouts
CacheService: Manages local Hive storage with staleness detection
ProductProvider: State management using Provider pattern for reactive UI updates

# State Management Solution
Provider Pattern Choice
Why Provider?
Simplicity: Perfect for managing multi-source asynchronous data flows
Reactivity: Automatic UI updates when data state changes
Performance: Efficient rebuilds only for affected widgets
Testing: Easy to mock and test state changes

# State Management Flow
**dart code
enum LoadingState { initial, loadingFromCache, loadingFromNetwork, loaded, error }**

The ProductProvider manages five distinct states:
Initial: App startup
Loading from Cache: Retrieving cached data
Loading from Network: Fetching fresh data
Loaded: Data successfully retrieved
Error: Network failure with fallback handling

# Multi-Source Data Handling
dart
// Intelligent data source coordination
if (cachedProducts != null && !isCacheStale) {
return cachedData;  // Fast cache response
} else if (cachedProducts != null && isCacheStale) {
showCachedData();   // Immediate display
fetchNetworkData(); // Background refresh
} else {
fetchNetworkData(); // No cache available
}


# Caching & Staleness Detection Logic
Cache Architecture
Storage: Hive local database with type-safe models
Structure: Products + metadata (timestamp, staleness check)
Persistence: Survives app restarts

# Staleness Detection Algorithm
dart
class CachedProductData {
final DateTime cachedAt;

    bool get isStale {
        final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 5));
        return cachedAt.isBefore(fiveMinutesAgo);
    }
}

# Running the Project
# Prerequisites
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0

# Installation
1. Clone and Setup
git clone <repository-url>
cd product_list_app
flutter pub get

2. Generate Hive Adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

3. Run the App
flutter run


# Testing Different States
1. First Launch (No Cache)
Expected: Direct network loading → 2-second delay → Products displayed
Status: "Fetching from network..."
Color: Blue status bar

2. Fresh Cache (< 5 minutes)
Trigger: Close and reopen app within 5 minutes
Expected: Instant product display
Status: "Loaded from cache"
Color: Grey status bar

3. Stale Cache (> 5 minutes)
Trigger: Wait 5+ minutes or modify device time
Expected: Instant cached display → Background refresh → Updated products
Status: "Loading from cache..." → "Fetching from network..." → "Up-to-date from network"
Color: Grey → Blue → Green

4. Network Error with Cache
Trigger: Turn off internet, refresh app
Expected: Cached data displayed + error notification
Status: Error message with cached data
Color: Orange status bar

5. Network Error without Cache
Trigger: Clear cache + turn off internet + refresh
Expected: Error screen with retry button
Status: "Failed to load products"
UI: Error icon + retry button

6. Manual Refresh
Trigger: Pull down to refresh or tap refresh icon
Expected: Force network fetch regardless of cache age
Status: "Fetching from network..."

7. Cache Management
Trigger: Menu → "Clear Cache"
Expected: Cache cleared, next load fetches from network
Verification: Check immediate behavior after clearing