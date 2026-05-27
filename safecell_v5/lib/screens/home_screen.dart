import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featured = [];
  List<String>  _categories = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiService.getProducts(limit: 6),
      ApiService.getCategories(),
    ]);
    if (mounted) setState(() {
      _featured   = results[0] as List<Product>;
      _categories = results[1] as List<String>;
      _loading    = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Safe', style: TextStyle(
                color: AppTheme.grey1, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              TextSpan(text: 'cell', style: TextStyle(
                color: AppTheme.orange, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.black),
            onPressed: () => context.go('/catalog'),
          ),
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
                    child: Center(
                      child: Text('${cart.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroBanner(onShop: () => context.go('/catalog')),
            const SizedBox(height: 20),

            // Categorías con iconos
            if (_categories.isNotEmpty) ...[
              SectionHeader(
                title: 'Categorías',
                action: 'Ver todo →',
                onAction: () => context.go('/catalog'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.toSet().toList().length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cats = _categories.toSet().toList();
                    return _CategoryIconChip(
                      label: cats[i],
                      onTap: () => context.go('/catalog?cat=${cats[i]}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            SectionHeader(
              title: 'Más vendidos',
              action: 'Ver todos →',
              onAction: () => context.go('/catalog'),
            ),
            const SizedBox(height: 12),
            _loading
              ? const SizedBox(height: 360, child: ShimmerGrid(count: 4))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.72,
                    crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: _featured.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: _featured[i],
                    isHot: i == 0,
                    isNew: i == 1,
                    onTap: () => context.go('/product/${_featured[i].slug}'),
                    onAddCart: () {
                      context.read<CartProvider>().add(_featured[i]);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${_featured[i].name} agregado'),
                        backgroundColor: AppTheme.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                  ),
                ),
            const SizedBox(height: 20),
            _PromoBanner(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Banner con patrón de puntos ────────────────────────────
class _HeroBanner extends StatelessWidget {
  final VoidCallback onShop;
  const _HeroBanner({required this.onShop});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      color: AppTheme.orangeLight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NUEVA COLECCIÓN',
                          style: TextStyle(
                            color: AppTheme.orange, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Repara\ntu móvil',
                        style: TextStyle(
                          color: AppTheme.black, fontSize: 28,
                          fontWeight: FontWeight.w800, height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Envío rápido · Garantía',
                        style: TextStyle(color: AppTheme.grey2, fontSize: 11)),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: onShop,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Comprar ahora', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _heroIcon(Icons.phone_android, AppTheme.orange),
                    const SizedBox(height: 8),
                    _heroIcon(Icons.battery_charging_full_outlined, AppTheme.grey1),
                    const SizedBox(height: 8),
                    _heroIcon(Icons.build_outlined, AppTheme.orange.withOpacity(0.6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _heroIcon(IconData icon, Color color) => Container(
    width: 42, height: 42,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.75),
      shape: BoxShape.circle,
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.orange.withOpacity(0.13)
      ..strokeCap = StrokeCap.round;
    const spacing = 18.0;
    const radius = 1.5;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Categoría con personalidad ──────────────────────────────────
class _CategoryIconChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryIconChip({required this.label, required this.onTap});

  IconData get _icon {
    final l = label.toLowerCase();
    if (l.contains('pantalla')) return Icons.phone_android;
    if (l.contains('bater')) return Icons.battery_charging_full;
    if (l.contains('funda')) return Icons.shield;
    if (l.contains('cable') || l.contains('cargador') || l.contains('conector')) return Icons.cable;
    if (l.contains('camara')) return Icons.camera_alt;
    if (l.contains('herramienta')) return Icons.build;
    if (l.contains('auricular') || l.contains('corneta')) return Icons.headphones;
    if (l.contains('vidrio') || l.contains('glass')) return Icons.smartphone;
    if (l.contains('tapa')) return Icons.layers;
    if (l.contains('flex')) return Icons.settings_input_component;
    if (l.contains('modulo') || l.contains('camara')) return Icons.camera;
    return Icons.devices_other;
  }

  Color get _color {
    final l = label.toLowerCase();
    if (l.contains('pantalla')) return const Color(0xFF6366F1);
    if (l.contains('bater')) return const Color(0xFF10B981);
    if (l.contains('funda')) return const Color(0xFF8B5CF6);
    if (l.contains('cable') || l.contains('cargador') || l.contains('conector')) return const Color(0xFFF59E0B);
    if (l.contains('herramienta')) return const Color(0xFF3B82F6);
    if (l.contains('auricular') || l.contains('corneta')) return const Color(0xFFEC4899);
    if (l.contains('tapa')) return const Color(0xFF14B8A6);
    if (l.contains('flex')) return const Color(0xFFEF4444);
    return AppTheme.orange;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label.length > 10 ? '${label.substring(0, 9)}.' : label,
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Promo banner ─────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.black,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_shipping_outlined, color: AppTheme.orange, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Envío a todo Venezuela',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Coordinamos contigo por WhatsApp',
                style: TextStyle(color: AppTheme.grey3, fontSize: 11)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: AppTheme.grey3, size: 14),
      ],
    ),
  );
}