import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/models.dart';

class ApiService {
  static final _base = Uri.parse(AppTheme.apiBase);

  static Map<String, String> _headers([String? token]) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ── Productos ─────────────────────────────────────────────────
  static Future<List<Product>> getProducts({
    String? category, String? search, int page = 1, int limit = 20,
  }) async {
    try {
      final uri = _base.replace(
        path: '/catalog/products',
        queryParameters: {
          if (category != null) 'category_slug': category,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': '$page',
          'page_size': '$limit',
          'featured': 'true',
        },
      );
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data is List ? data : (data['items'] ?? data['products'] ?? data['results'] ?? []);
        return (list as List).map((e) => Product.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Buscar producto por slug
  static Future<Product?> getProductBySlug(String slug) async {
    try {
      final res = await http.get(
        _base.replace(path: '/catalog/products/$slug'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return Product.fromJson(jsonDecode(res.body));
    } catch (_) {}
    return null;
  }

  // Buscar producto por ID (busca en lista y retorna el primero que coincida)
  static Future<Product?> getProduct(int id) async {
    try {
      final res = await http.get(
        _base.replace(
          path: '/catalog/products',
          queryParameters: {'page': '1', 'page_size': '100'},
        ),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data is List ? data : (data['items'] ?? []);
        for (final item in list) {
          if (item['id'] == id) return Product.fromJson(item);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Categorías ────────────────────────────────────────────────
  static Future<List<String>> getCategories() async {
    try {
      final res = await http.get(
        _base.replace(path: '/catalog/categories'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data.map((e) {
            if (e is Map) return e['name']?.toString() ?? e['slug']?.toString() ?? '';
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
        if (data is Map && data['categories'] != null) {
          return (data['categories'] as List).map((e) {
            if (e is Map) return e['name']?.toString() ?? '';
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  // ── Auth ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        _base.replace(path: '/auth/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> register(
    String name, String email, String password, String phone,
  ) async {
    try {
      final res = await http.post(
        _base.replace(path: '/auth/register'),
        headers: _headers(),
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'phone': phone}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200 || res.statusCode == 201) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  // ── Órdenes ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shipping,
    required String paymentMethod,
    String? token,
  }) async {
    try {
      final res = await http.post(
        _base.replace(path: '/checkout/orders'),
        headers: _headers(token),
        body: jsonEncode({'items': items, 'shipping': shipping, 'payment_method': paymentMethod}),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 || res.statusCode == 201) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<List<Order>> getMyOrders(String token) async {
    try {
      final res = await http.get(
        _base.replace(path: '/account/orders'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data is List ? data : (data['items'] ?? data['orders'] ?? []);
        return (list as List).map((e) => Order.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Chat ──────────────────────────────────────────────────────
  static Future<String> sendChatMessage(String msg, String visitorId) async {
    try {
      final res = await http.post(
        _base.replace(path: '/live/chat/ai-reply'),
        headers: _headers(),
        body: jsonEncode({'message': msg, 'visitor_id': visitorId}),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['reply'] ?? data['message'] ?? data['response'] ?? '¿En qué te ayudo?';
      }
    } catch (_) {}
    return 'No pude conectar. ¿Quieres hablar con un asesor?';
  }
}