import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  List<String> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiService.getProducts(limit: 10),
      ApiService.getCategories(),
    ]);

    if (!mounted) return;

    setState(() {
      _featured = results[0] as List<Product>;
      _categories = results[1] as List<String>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: AppTheme.bgPage,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SafeCellLogo(fontSize: 27),
            SizedBox(height: 1),
            Text(
              'Repuestos y Servicio Técnico',
              style: TextStyle(
                color: AppTheme.grey2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          _RoundActionButton(
            icon: Icons.search_rounded,
            onTap: () => context.go('/catalog'),
          ),
          const SizedBox(width: 8),
          _RoundActionButton(
            icon: Icons.support_agent_rounded,
            onTap: () => context.go('/chat'),
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.topRight,
            children: [
              _RoundActionButton(
                icon: Icons.shopping_cart_outlined,
                onTap: () => context.go('/cart'),
              ),
              if (cart.count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppTheme.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 112),
          children: [
            _HeroCarousel(onShop: () => context.go('/catalog')),
            const SizedBox(height: 14),
            const _TrustPanel(),
            const SizedBox(height: 24),

            SectionHeader(
              title: 'Marcas destacadas',
              subtitle: 'Repuestos para los modelos más buscados',
              action: 'Ver todas  ›',
              onAction: () => context.go('/catalog'),
            ),
            const SizedBox(height: 12),
            _PremiumBrandsStrip(onBrandTap: (brand) => context.go('/catalog?brand=${Uri.encodeComponent(brand)}')),
            const SizedBox(height: 24),

            SectionHeader(
              title: 'Compra por categoría',
              action: 'Ver todo  ›',
              onAction: () => context.go('/catalog'),
            ),
            const SizedBox(height: 12),
            _CategoryPhotoStrip(
              categories: _categories,
              onTap: (cat) => context.go('/catalog?cat=${Uri.encodeComponent(cat)}'),
            ),
            const SizedBox(height: 22),

            _WeeklyOfferBanner(
              product: _featured.isNotEmpty ? _featured.first : null,
              onTap: () {
                if (_featured.isNotEmpty) {
                  context.go('/product/${_featured.first.slug}');
                } else {
                  context.go('/catalog');
                }
              },
            ),
            const SizedBox(height: 24),

            SectionHeader(
              title: 'Productos destacados',
              action: 'Ver todos  ›',
              onAction: () => context.go('/catalog'),
            ),
            const SizedBox(height: 12),
            _loading
                ? const SizedBox(height: 280, child: LoadingExperience())
                : _FeaturedProductsStrip(
                    products: _featured,
                    onTap: (p) => context.go('/product/${p.slug}'),
                    onAdd: (p) {
                      context.read<CartProvider>().add(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${p.name} agregado'),
                          backgroundColor: AppTheme.black,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 22),

            const _WhatsappCta(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOGO / ACTIONS
// ─────────────────────────────────────────────────────────────

class _SafeCellLogo extends StatelessWidget {
  final double fontSize;
  const _SafeCellLogo({required this.fontSize});

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Safe',
              style: TextStyle(
                color: AppTheme.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            TextSpan(
              text: 'Cell',
              style: TextStyle(
                color: AppTheme.orange,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      );
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border),
            boxShadow: [AppTheme.cardShadow(.035)],
          ),
          child: Icon(icon, color: AppTheme.black, size: 21),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// HERO CAROUSEL
// ─────────────────────────────────────────────────────────────

class _HeroSlide {
  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final String button;

  const _HeroSlide({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.button,
  });
}

class _HeroCarousel extends StatefulWidget {
  final VoidCallback onShop;

  const _HeroCarousel({required this.onShop});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  static const _slides = [
    _HeroSlide(
      image: 'assets/banners/banner_reparacion.jpg',
      tag: 'SERVICIO TÉCNICO',
      title: 'Reparamos y\nequipamos tu móvil',
      subtitle: 'Pantallas, baterías, flex, cámaras y diagnóstico profesional.',
      button: 'Ver catálogo',
    ),
    _HeroSlide(
      image: 'assets/banners/banner_taller.jpg',
      tag: 'REPUESTOS GARANTIZADOS',
      title: 'Tu móvil en\nbuenas manos',
      subtitle: 'Atención personalizada y repuestos revisados antes de entregar.',
      button: 'Comprar ahora',
    ),
    _HeroSlide(
      image: 'assets/banners/banner_repuestos.jpg',
      tag: 'PANTALLAS Y BATERÍAS',
      title: 'Encuentra el\nrepuesto exacto',
      subtitle: 'Samsung, Xiaomi, Realme, Tecno, Infinix y más modelos.',
      button: 'Buscar modelo',
    ),
    _HeroSlide(
      image: 'assets/banners/banner_micro_soldadura.jpg',
      tag: 'REPARACIÓN AVANZADA',
      title: 'Soluciones para\nfallos complejos',
      subtitle: 'Componentes, conectores, flex y revisión técnica especializada.',
      button: 'Consultar',
    ),
    _HeroSlide(
      image: 'assets/banners/banner_tienda.jpg',
      tag: 'SAFECELL VENEZUELA',
      title: 'Compra fácil,\nrápido y seguro',
      subtitle: 'Repuestos y accesorios con atención directa por WhatsApp.',
      button: 'Comprar ahora',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 540),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [AppTheme.softShadow(.12)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _HeroSlideView(
                slide: _slides[i],
                onShop: widget.onShop,
              ),
            ),
            // Dots indicators
            Positioned(
              left: 24,
              bottom: 17,
              child: Row(
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? AppTheme.orange : Colors.white.withOpacity(.62),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
}

class _HeroSlideView extends StatelessWidget {
  final _HeroSlide slide;
  final VoidCallback onShop;

  const _HeroSlideView({
    required this.slide,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(slide.image, fit: BoxFit.cover),
          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.black.withOpacity(.08),
                  Colors.black.withOpacity(.55),
                  Colors.black.withOpacity(.92),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.08),
                  Colors.black.withOpacity(.08),
                  Colors.black.withOpacity(.60),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 22, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.orange,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [AppTheme.softShadow(.12)],
                  ),
                  child: Text(
                    slide.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                // Title + subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 260,
                      child: Text(
                        slide.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.84),
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Buttons — fixed at bottom, no Spacer
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.button,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 15),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.28),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(.24),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// TRUST PANEL
// ─────────────────────────────────────────────────────────────

class _TrustPanel extends StatelessWidget {
  const _TrustPanel();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
          boxShadow: [AppTheme.cardShadow(.035)],
        ),
        child: Row(
          children: const [
            Expanded(
              child: _TrustItem(
                icon: Icons.local_shipping_outlined,
                title: 'Envíos a\ntoda Venezuela',
                text: 'Cobertura nacional',
              ),
            ),
            _VerticalSeparator(),
            Expanded(
              child: _TrustItem(
                icon: Icons.verified_user_outlined,
                title: 'Garantía',
                text: 'Repuestos revisados',
              ),
            ),
            _VerticalSeparator(),
            Expanded(
              child: _TrustItem(
                icon: Icons.support_agent_rounded,
                title: 'Soporte directo',
                text: 'WhatsApp rápido',
              ),
            ),
          ],
        ),
      );
}

class _VerticalSeparator extends StatelessWidget {
  const _VerticalSeparator();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        color: AppTheme.border,
      );
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.orange, size: 25),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 12,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppTheme.grey2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// MARCAS PREMIUM
// ─────────────────────────────────────────────────────────────

class _PremiumBrandsStrip extends StatelessWidget {
  final ValueChanged<String> onBrandTap;
  const _PremiumBrandsStrip({required this.onBrandTap});

  static const brands = [
    _BrandTileData(
      name: 'Samsung',
      logoPath: 'assets/logos/Samsung.svg',
      imagePath: 'assets/brands/Samsung.jpg',
    ),
    _BrandTileData(
      name: 'Xiaomi',
      logoPath: 'assets/logos/Xiaomi.svg',
      imagePath: 'assets/brands/Xiaomi.jpg',
    ),
    _BrandTileData(
      name: 'Huawei',
      logoPath: 'assets/logos/Huawei.svg',
      imagePath: 'assets/brands/Huawei.jpg',
    ),
    _BrandTileData(
      name: 'Motorola',
      logoPath: 'assets/logos/Motorola.svg',
      imagePath: 'assets/brands/Motorola.jpg',
    ),
    _BrandTileData(
      name: 'Apple',
      logoPath: 'assets/logos/Apple.svg',
      imagePath: 'assets/brands/Apple.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 102,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: brands.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _BrandTile(data: brands[i], onTap: () => onBrandTap(brands[i].name)),
        ),
      );
}

class _BrandTileData {
  final String name;
  final String logoPath;
  final String imagePath;

  const _BrandTileData({
    required this.name,
    required this.logoPath,
    required this.imagePath,
  });
}

class _BrandTile extends StatelessWidget {
  final _BrandTileData data;
  final VoidCallback onTap;

  const _BrandTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 174,
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [AppTheme.softShadow(.10)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              data.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _brandFallback(data.name),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(.82),
                    Colors.black.withOpacity(.34),
                    Colors.black.withOpacity(.05),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 50,
              child: SvgPicture.asset(
                data.logoPath,
                height: 20,
                alignment: Alignment.centerLeft,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => Text(
                  data.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.18)),
                ),
                child: const Text(
                  'Ver modelos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _brandFallback(String name) => Container(
        color: AppTheme.black,
        child: Center(
          child: Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// CATEGORÍAS
// ─────────────────────────────────────────────────────────────

class _CategoryPhotoStrip extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String> onTap;

  const _CategoryPhotoStrip({
    required this.categories,
    required this.onTap,
  });

  static const fallback = [
    'Pantallas',
    'Baterías',
    'Flex y Conectores',
    'Cámaras',
    'Herramientas',
  ];

  @override
  Widget build(BuildContext context) {
    final cats = categories.isEmpty ? fallback : categories.toSet().toList();

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CategoryPhotoCard(
          label: cats[i],
          models: _modelsFor(cats[i], i),
          onTap: () => onTap(cats[i]),
        ),
      ),
    );
  }

  String _modelsFor(String label, int i) {
    final l = label.toLowerCase();
    if (l.contains('pantalla')) return '325 modelos';
    if (l.contains('bater')) return '240 modelos';
    if (l.contains('flex') || l.contains('conector')) return '180 modelos';
    if (l.contains('camara') || l.contains('cámara')) return '120 modelos';
    if (l.contains('herramienta')) return '85 modelos';
    if (l.contains('auricular')) return '150 modelos';
    return '${80 + (i * 25)} modelos';
  }
}

class _CategoryPhotoCard extends StatelessWidget {
  final String label;
  final String models;
  final VoidCallback onTap;

  const _CategoryPhotoCard({
    required this.label,
    required this.models,
    required this.onTap,
  });

  String get _imagePath {
    final l = label.toLowerCase();
    if (l.contains('pantalla')) return 'assets/categories/pantallas.jpg';
    if (l.contains('bater')) return 'assets/categories/baterias.jpg';
    if (l.contains('flex')) return 'assets/categories/flex.jpg';
    if (l.contains('conector')) return 'assets/categories/conectores.jpg';
    if (l.contains('camara') || l.contains('cámara')) return 'assets/categories/camaras.jpg';
    if (l.contains('herramienta')) return 'assets/categories/herramientas.jpg';
    if (l.contains('auricular') || l.contains('corneta')) return 'assets/categories/auriculares.jpg';
    if (l.contains('cable')) return 'assets/categories/cables.jpg';
    if (l.contains('cargador')) return 'assets/categories/cargadores.jpg';
    if (l.contains('accesorio')) return 'assets/categories/accesorios.jpg';
    return 'assets/categories/accesorios.jpg';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 142,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.border),
            boxShadow: [AppTheme.cardShadow(.045)],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F7),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppTheme.grey3,
                          size: 34,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(.08),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      models,
                      style: const TextStyle(
                        color: AppTheme.grey2,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// OFERTA SEMANAL
// ─────────────────────────────────────────────────────────────

class _WeeklyOfferBanner extends StatelessWidget {
  final Product? product;
  final VoidCallback onTap;

  const _WeeklyOfferBanner({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = product?.name ?? 'Pantalla iPhone 11';
    final price = product == null
        ? '\$69.99'
        : '\$${product!.price.toStringAsFixed(2)}';
    final old = product?.oldPrice != null
        ? '\$${product!.oldPrice!.toStringAsFixed(2)}'
        : '\$89.99';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [AppTheme.softShadow(.10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.orange, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'Oferta de la semana',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '-22%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: AppTheme.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  old,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.35),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white54,
                  ),
                ),
                const Spacer(),
                const _CountdownBox(value: '14', label: 'H'),
                const SizedBox(width: 4),
                const _CountdownBox(value: '35', label: 'M'),
                const SizedBox(width: 4),
                const _CountdownBox(value: '28', label: 'S'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.55),
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// PRODUCTOS DESTACADOS
// ─────────────────────────────────────────────────────────────

class _FeaturedProductsStrip extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onAdd;

  const _FeaturedProductsStrip({
    required this.products,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No hay productos destacados',
            style: TextStyle(color: AppTheme.grey2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _FeaturedProductMiniCard(
          product: products[i],
          onTap: () => onTap(products[i]),
          onAdd: () => onAdd(products[i]),
        ),
      ),
    );
  }
}

class _FeaturedProductMiniCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _FeaturedProductMiniCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null &&
        product.imageUrl!.trim().isNotEmpty &&
        !product.imageUrl!.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 164,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
          boxShadow: [AppTheme.cardShadow(.04)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: hasImage
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.phone_android_rounded,
                              color: AppTheme.grey3,
                              size: 58,
                            ),
                          )
                        : const Icon(
                            Icons.phone_android_rounded,
                            color: AppTheme.grey3,
                            size: 58,
                          ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: AppTheme.black,
                      size: 21,
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.warning, size: 15),
                        SizedBox(width: 2),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: AppTheme.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.orange,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CTA WHATSAPP
// ─────────────────────────────────────────────────────────────

class _WhatsappCta extends StatelessWidget {
  const _WhatsappCta();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F9EE),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFC9EFD4)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿No encuentras el repuesto que buscas?',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Escríbenos por WhatsApp y te ayudamos.',
                    style: TextStyle(
                      color: AppTheme.grey1,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go('/chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Contactar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
}