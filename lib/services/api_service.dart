// lib/services/api_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const timeoutDuration =  Duration(seconds: 15);
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<void> logout() async {
    await clearToken();
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (auth && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = response.body.trim();

      if (body.isEmpty) {
        return {
          'statusCode': response.statusCode,
          'message': 'Empty server response',
        };
      }

      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return {
          ...decoded,
          'statusCode': response.statusCode,
        };
      }

      return {
        'statusCode': response.statusCode,
        'data': decoded,
      };
    } catch (e) {
      return {
        'statusCode': response.statusCode,
        'message': 'Invalid server response',
      };
    }
  }

  static Future<Map<String, dynamic>> _safeRequest(
      Future<http.Response> Function() request,
      ) async {
    try {
      final response = await request().timeout(timeoutDuration);

      if (response.statusCode == 401) {
        await clearToken();
      }

      return _handleResponse(response);
    } on TimeoutException {
      return {
        'statusCode': 0,
        'message': 'Request timeout. Please try again.',
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'message': 'Unable to connect to server',
      };
    }
  }

  static Future<Map<String, dynamic>> signup(
      String name,
      String email,
      String password,
      ) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    final data = await _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
    });

    if (data['statusCode'] == 200 && data['token'] != null) {
      await saveToken(data['token'].toString());
    }

    return data;
  }

  static Future<Map<String, dynamic>> forgotPassword(
      String email,
      String newPassword,
      ) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _headers(),
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return _safeRequest(() async {
      return http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> getProducts({
    String? category,
    String? search,
  }) async {
    final params = <String, String>{};

    if (category != null && category.trim().isNotEmpty && category != 'All') {
      params['category'] = category.trim();
    }

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/products').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    return _safeRequest(() async {
      return http.get(
        uri,
        headers: await _headers(),
      );
    });
  }

  static Future<Map<String, dynamic>> getProduct(int productId) async {
    return _safeRequest(() async {
      return http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await _headers(),
      );
    });
  }

  static Future<Map<String, dynamic>> addProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    String imageUrl = '',
    int isDigital = 1,
  }) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/products'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          'price': price,
          'image_url': imageUrl,
          'is_digital': isDigital,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required String title,
    required String description,
    required String category,
    required double price,
    String imageUrl = '',
    int isDigital = 1,
    int isActive = 1,
  }) async {
    return _safeRequest(() async {
      return http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          'price': price,
          'image_url': imageUrl,
          'is_digital': isDigital,
          'is_active': isActive,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    return _safeRequest(() async {
      return http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> getWishlist() async {
    return _safeRequest(() async {
      return http.get(
        Uri.parse('$baseUrl/wishlist'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> addToWishlist(int productId) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/wishlist'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'product_id': productId,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> toggleWishlist(int productId) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/wishlist/toggle'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'product_id': productId,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> removeFromWishlist(int productId) async {
    return _safeRequest(() async {
      return http.delete(
        Uri.parse('$baseUrl/wishlist/$productId'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> placeOrder(
      int productId, {
        int quantity = 1,
        String paymentMethod = 'Demo Payment',
      }) async {
    return _safeRequest(() async {
      return http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'items': [
            {
              'product_id': productId,
              'quantity': quantity,
            }
          ],
          'payment_method': paymentMethod,
        }),
      );
    });
  }

  static Future<Map<String, dynamic>> getOrders() async {
    return _safeRequest(() async {
      return http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    return _safeRequest(() async {
      return http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: await _headers(auth: true),
      );
    });
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    return _safeRequest(() async {
      return http.patch(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: await _headers(auth: true),
      );
    });
  }
}
