import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _name;
  String? _email;
  bool _loading = false;

  String? get token   => _token;
  String? get name    => _name;
  String? get email   => _email;
  bool    get isAuth  => _token != null;
  bool    get loading => _loading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _name  = prefs.getString('name');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true; notifyListeners();
    final data = await ApiService.login(email, password);
    _loading = false;
    if (data != null) {
      _token = data['access_token'] ?? data['token'];
      _name  = data['name'] ?? data['user']?['name'];
      _email = email;
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('token', _token!);
      if (_name  != null) await prefs.setString('name',  _name!);
      await prefs.setString('email', email);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _loading = true; notifyListeners();
    final data = await ApiService.register(name, email, password, phone);
    _loading = false;
    if (data != null) {
      _token = data['access_token'] ?? data['token'];
      _name  = name; _email = email;
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('token', _token!);
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null; _name = null; _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int    get count => _items.fold(0, (s, i) => s + i.quantity);
  double get total => _items.fold(0.0, (s, i) => s + i.subtotal);

  void add(Product p) {
    final idx = _items.indexWhere((i) => i.product.id == p.id);
    if (idx >= 0) { _items[idx].quantity++; }
    else { _items.add(CartItem(product: p)); }
    notifyListeners();
  }

  void remove(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void setQty(int productId, int qty) {
    if (qty <= 0) { remove(productId); return; }
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) { _items[idx].quantity = qty; notifyListeners(); }
  }

  void clear() { _items.clear(); notifyListeners(); }

  List<Map<String, dynamic>> toOrderItems() =>
    _items.map((i) => {'product_id': i.product.id, 'quantity': i.quantity}).toList();
}
