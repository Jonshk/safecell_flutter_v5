class Product {
  final int id;
  final String slug;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final int stock;
  final String category;
  final String? imageUrl;
  final String? brand;
  final String? model;
  final String? quality;

  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.stock,
    required this.category,
    this.imageUrl,
    this.brand,
    this.model,
    this.quality,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id:          j['id'] as int? ?? 0,
    slug:        j['slug'] as String? ?? '',
    name:        j['title'] as String? ?? j['name'] as String? ?? '',
    description: j['description'] as String? ?? '',
    price:       (j['price'] as num?)?.toDouble() ?? 0.0,
    oldPrice:    (j['old_price'] as num?)?.toDouble(),
    stock:       j['stock'] as int? ?? 0,
    category:    j['category'] as String? ?? 'General',
    imageUrl:    _fixUrl(j['image_url'] as String?),
    brand:       j['brand'] as String?,
    model:       j['model'] as String?,
    quality:     j['quality'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'slug':        slug,
    'name':        name,
    'description': description,
    'price':       price,
    'old_price':   oldPrice,
    'stock':       stock,
    'category':    category,
    'image_url':   imageUrl,
    'brand':       brand,
    'model':       model,
    'quality':     quality,
  };
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
}

class Order {
  final int id;
  final String status;
  final double total;
  final String createdAt;
  final List<dynamic> items;

  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id:        j['id'] as int? ?? 0,
    status:    j['status'] as String? ?? 'pendiente',
    total:     (j['total'] as num?)?.toDouble() ?? 0.0,
    createdAt: j['created_at'] as String? ?? '',
    items:     j['items'] as List<dynamic>? ?? [],
  );
}

class ChatMessage {
  final String sender;
  final String text;
  final DateTime time;
  final List<String> quickReplies;

  ChatMessage({
    required this.sender,
    required this.text,
    DateTime? time,
    this.quickReplies = const [],
  }) : time = time ?? DateTime.now();
}

String? _fixUrl(String? url) {
  if (url == null) return null;
  if (url.startsWith('http')) return url;
  return 'https://safecell-backend.onrender.com$url';
}