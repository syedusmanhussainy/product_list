import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Product>> fetchProducts() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.get(
        Uri.parse('$_baseUrl/products?limit=50&select=title,description,category,price,brand,rating,images,thumbnail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final productsJson = jsonData['products'] as List;

        return productsJson
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      } else {
        throw HttpException('Failed to fetch products: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No internet connection');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
