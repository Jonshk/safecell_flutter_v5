import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';

// ─── CATÁLOGO ─────────────────────────────────────────────────────
class CatalogScreen extends StatefulWidget {
  final String? initialCategory;
  const CatalogScreen({super.key, this.initialCategory});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  final _scroll     = ScrollController();
  List<Product> _products   = [];
  List<String>  _categories = [];
  String?       _selCat;
  bool          _loading    = true;
  int           _page       = 1;
  bool          _hasMore    = true;

  @override
  void initState() {
    super.initState();
    _selCat = widget.initialCategory;
    _loadCats();
    _load(reset: true);
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200 &&
          !_loading && _hasMore) _load();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _loadCats() async {
    final cats = await ApiService.getCategories();
    if (mounted) setState(() => _categories = cats);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading && !reset) return;
    setState(() => _loading = true);
    if (reset) { _page = 1; _products.clear(); }
    final items = await ApiService.getProducts(
      category: _selCat,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      page: _page, limit: 20,
    );
    if (mounted) setState(() {
      _products.addAll(items);
      _hasMore = items.length == 20;
      if (items.isNotEmpty) _page++;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.black),
                onPressed: () => context.go('/cart'),
              ),
              if (cart.count > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
                    child: Center(child: Text('${cart.count}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Búsqueda
                TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _load(reset: true),
                  onChanged: (v) { if (v.isEmpty) _load(reset: true); },
                  style: const TextStyle(color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.grey3),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.grey3),
                          onPressed: () { _searchCtrl.clear(); _load(reset: true); },
                        )
                      : null,
                    filled: true,
                    fillColor: AppTheme.bgPage,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Chips
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryChip(
                        label: 'Todos', selected: _selCat == null,
                        onTap: () { setState(() => _selCat = null); _load(reset: true); },
                      ),
                      ..._categories.map((c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CategoryChip(
                          label: c, selected: _selCat == c,
                          onTap: () { setState(() => _selCat = c); _load(reset: true); },
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: _loading && _products.isEmpty
              ? const Padding(padding: EdgeInsets.all(16), child: ShimmerGrid(count: 8))
              : _products.isEmpty
                ? const Center(child: Text('No se encontraron productos',
                    style: TextStyle(color: AppTheme.grey2)))
                : GridView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.72,
                      crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: _products.length + (_hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _products.length)
                        return const Center(child: CircularProgressIndicator(color: AppTheme.orange));
                      final p = _products[i];
                      return ProductCard(
                        product: p, isNew: i % 5 == 1,
                        onTap: () => context.go('/product/${p.slug}'),
                        onAddCart: () {
                          context.read<CartProvider>().add(p);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${p.name} agregado'),
                            backgroundColor: AppTheme.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 2),
                          ));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── DETALLE ──────────────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final String productSlug;
  const ProductDetailScreen({super.key, required this.productSlug});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await ApiService.getProductBySlug(widget.productSlug);
    if (mounted) setState(() { _product = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: Center(child: CircularProgressIndicator(color: AppTheme.orange)));
    if (_product == null) return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(),
      body: const Center(child: Text('Producto no encontrado')));

    final p = _product!;
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.bgCard,
            foregroundColor: AppTheme.black,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.black, size: 16),
              ),
              onPressed: () => context.go('/catalog'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppTheme.black),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: p.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: p.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.orangeLight,
                      child: const Icon(Icons.phone_android, color: AppTheme.orange, size: 80)),
                  )
                : Container(
                    color: AppTheme.orangeLight,
                    child: const Icon(Icons.phone_android, color: AppTheme.orange, size: 80)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.bgCard,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.orangeLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${p.category.toUpperCase()} · REPUESTOS',
                      style: const TextStyle(color: AppTheme.orange, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(p.name, style: const TextStyle(
                    color: AppTheme.black, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.black, fontSize: 28, fontWeight: FontWeight.w800)),
                      if (p.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text('\$${p.oldPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.grey3, fontSize: 16, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.stock > 0 ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              p.stock > 0 ? Icons.check_circle : Icons.cancel,
                              color: p.stock > 0 ? AppTheme.success : AppTheme.error,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.stock > 0 ? '${p.stock} en stock' : 'Sin stock',
                              style: TextStyle(
                                color: p.stock > 0 ? AppTheme.success : AppTheme.error,
                                fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 12),
                  const Text('Descripción', style: TextStyle(
                    color: AppTheme.black, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isNotEmpty ? p.description : 'Sin descripción disponible.',
                    style: const TextStyle(color: AppTheme.grey2, height: 1.6)),
                  if (p.model != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('Modelo: ${p.model}', style: const TextStyle(color: AppTheme.grey3, fontSize: 12)),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppTheme.bgCard,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: p.stock > 0
                    ? () {
                        context.read<CartProvider>().add(p);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Agregado al carrito'),
                          backgroundColor: AppTheme.black,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ));
                      }
                    : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Agregar al carrito'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => context.go('/cart'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ver carrito', style: TextStyle(color: AppTheme.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CARRITO ──────────────────────────────────────────────────────
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Tu carrito'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: cart.clear,
              child: const Text('Vaciar', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: cart.items.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, color: AppTheme.grey3, size: 64),
                SizedBox(height: 16),
                Text('Tu carrito está vacío',
                  style: TextStyle(color: AppTheme.grey2, fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text('Agrega productos desde el catálogo',
                  style: TextStyle(color: AppTheme.grey3, fontSize: 13)),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.orangeLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone_android, color: AppTheme.orange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.category.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.grey3, fontSize: 9,
                                    fontWeight: FontWeight.w700, letterSpacing: 1)),
                                Text(item.product.name,
                                  style: const TextStyle(color: AppTheme.black,
                                    fontSize: 13, fontWeight: FontWeight.w700),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('\$${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.black,
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              _qtyBtn(Icons.remove, () => cart.setQty(item.product.id, item.quantity - 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.quantity}',
                                  style: const TextStyle(color: AppTheme.black,
                                    fontSize: 15, fontWeight: FontWeight.w800)),
                              ),
                              _qtyBtn(Icons.add, () => cart.setQty(item.product.id, item.quantity + 1)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.bgCard,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgPage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _summaryRow('Subtotal', '\$${cart.total.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _summaryRow('Envío', 'Por coordinar'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: AppTheme.border, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(
                                color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.w800)),
                              Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(
                                color: AppTheme.black, fontSize: 20, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/checkout'),
                        child: const Text('Proceder al pago'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: AppTheme.bgPage,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, color: AppTheme.black, size: 16),
    ),
  );

  Widget _summaryRow(String label, String val) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.grey2, fontSize: 13)),
      Text(val, style: const TextStyle(color: AppTheme.black, fontSize: 13, fontWeight: FontWeight.w600)),
    ],
  );
}

// ─── CHECKOUT ─────────────────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  String _payMethod  = 'transferencia';
  bool   _submitting = false;

  final _methods = const [
    ('transferencia', 'Transferencia bancaria', Icons.account_balance_outlined),
    ('zelle',         'Zelle',                  Icons.attach_money),
    ('pago_movil',    'Pago Móvil',              Icons.phone_android_outlined),
    ('efectivo',      'Efectivo',                Icons.money_outlined),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Completa todos los campos obligatorios'),
        backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final result = await ApiService.createOrder(
      items: cart.toOrderItems(),
      shipping: {
        'name': _nameCtrl.text, 'phone': _phoneCtrl.text,
        'address': _addressCtrl.text, 'city': _cityCtrl.text,
      },
      paymentMethod: _payMethod, token: auth.token,
    );
    setState(() => _submitting = false);
    if (result != null && mounted) {
      cart.clear();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            SizedBox(width: 8),
            Text('¡Pedido enviado!', style: TextStyle(color: AppTheme.black)),
          ]),
          content: Text(
            'Tu pedido #${result['id'] ?? ''} fue registrado.\nTe contactaremos para confirmar el pago.',
            style: const TextStyle(color: AppTheme.grey2)),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); context.go('/'); },
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error al procesar el pedido.'),
        backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progreso
            Row(children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < 3 ? AppTheme.orange : AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ))),
            const SizedBox(height: 20),

            _sectionTitle('Datos de envío', Icons.local_shipping_outlined),
            const SizedBox(height: 10),
            _field('Nombre completo *', _nameCtrl, TextInputType.name),
            const SizedBox(height: 8),
            _field('Teléfono / WhatsApp *', _phoneCtrl, TextInputType.phone),
            const SizedBox(height: 8),
            _field('Dirección *', _addressCtrl, TextInputType.streetAddress),
            const SizedBox(height: 8),
            _field('Ciudad', _cityCtrl, TextInputType.text),
            const SizedBox(height: 20),

            _sectionTitle('Método de pago', Icons.payment_outlined),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: _methods.map(((String, String, IconData) m) => GestureDetector(
                onTap: () => setState(() => _payMethod = m.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _payMethod == m.$1 ? AppTheme.orangeLight : AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _payMethod == m.$1 ? AppTheme.orange : AppTheme.border,
                      width: _payMethod == m.$1 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m.$3,
                        color: _payMethod == m.$1 ? AppTheme.orange : AppTheme.grey3, size: 18),
                      const SizedBox(width: 6),
                      Flexible(child: Text(m.$2, style: TextStyle(
                        color: _payMethod == m.$1 ? AppTheme.orange : AppTheme.grey2,
                        fontSize: 11, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Resumen
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.product.name} ×${item.quantity}',
                          style: const TextStyle(color: AppTheme.grey2, fontSize: 12),
                          overflow: TextOverflow.ellipsis)),
                        Text('\$${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.black, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                  const Divider(color: AppTheme.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(
                        color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(
                        color: AppTheme.black, fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirmar pedido'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AppTheme.orange, size: 18),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(
        color: AppTheme.black, fontSize: 15, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _field(String label, TextEditingController ctrl, TextInputType type) =>
    TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppTheme.black),
      decoration: InputDecoration(labelText: label),
    );
}