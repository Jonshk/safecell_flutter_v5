import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── Product Card Premium ─────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddCart;
  final bool isNew;
  final bool isHot;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddCart,
    this.isNew = false,
    this.isHot = false,
  });

  Color get _bgColor {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return const Color(0xFFEEF2FF);
    if (c.contains('bater')) return const Color(0xFFE9FDF3);
    if (c.contains('funda') || c.contains('tapa')) return const Color(0xFFF4F0FF);
    if (c.contains('cable') || c.contains('cargador') || c.contains('conector')) return const Color(0xFFFFF7E8);
    if (c.contains('herramienta')) return const Color(0xFFEAF3FF);
    if (c.contains('auricular') || c.contains('corneta')) return const Color(0xFFFFEEF7);
    if (c.contains('camara')) return const Color(0xFFEAFBF7);
    if (c.contains('flex')) return const Color(0xFFFFEEEE);
    return AppTheme.orangeLight;
  }

  Color get _accent {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return const Color(0xFF5B5FF5);
    if (c.contains('bater')) return const Color(0xFF10B981);
    if (c.contains('funda') || c.contains('tapa')) return const Color(0xFF8B5CF6);
    if (c.contains('cable') || c.contains('cargador') || c.contains('conector')) return const Color(0xFFF59E0B);
    if (c.contains('herramienta')) return const Color(0xFF2563EB);
    if (c.contains('auricular') || c.contains('corneta')) return const Color(0xFFEC4899);
    if (c.contains('camara')) return const Color(0xFF14B8A6);
    if (c.contains('flex')) return const Color(0xFFEF4444);
    return AppTheme.orange;
  }

  IconData get _icon {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return Icons.phone_android_rounded;
    if (c.contains('bater')) return Icons.battery_charging_full_rounded;
    if (c.contains('funda')) return Icons.shield_rounded;
    if (c.contains('tapa')) return Icons.layers_rounded;
    if (c.contains('cable')) return Icons.cable_rounded;
    if (c.contains('cargador')) return Icons.power_rounded;
    if (c.contains('conector')) return Icons.settings_input_component_rounded;
    if (c.contains('herramienta')) return Icons.build_rounded;
    if (c.contains('auricular') || c.contains('corneta')) return Icons.headphones_rounded;
    if (c.contains('camara')) return Icons.camera_alt_rounded;
    if (c.contains('flex')) return Icons.memory_rounded;
    return Icons.devices_other_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null &&
        product.imageUrl!.trim().isNotEmpty &&
        !product.imageUrl!.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
          boxShadow: [AppTheme.softShadow(.055)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(color: _bgColor)),
                    Positioned.fill(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _placeholderContent(),
                              errorWidget: (_, __, ___) => _placeholderContent(),
                            )
                          : _placeholderContent(),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _badge(
                        isHot ? 'HOT' : isNew ? 'NUEVO' : 'SAFE',
                        isHot ? AppTheme.orange : isNew ? AppTheme.black : _accent,
                      ),
                    ),
                    if (product.quality != null && product.quality!.trim().isNotEmpty)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.92),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [AppTheme.softShadow(.04)],
                          ),
                          child: Text(
                            product.quality!.toUpperCase(),
                            style: TextStyle(
                              color: _accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product.brand ?? 'SAFECELL').toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.grey3,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppTheme.success, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        product.stock > 0 ? 'Disponible' : 'Consultar stock',
                        style: TextStyle(
                          color: product.stock > 0 ? AppTheme.success : AppTheme.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (onAddCart != null)
                        GestureDetector(
                          onTap: onAddCart,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: AppTheme.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderContent() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.65),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: _accent, size: 34),
        ),
        const SizedBox(height: 8),
        Text(
          product.category,
          style: TextStyle(
            color: _accent.withOpacity(.72),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: .6,
      ),
    ),
  );
}

// ─── Section Header ───────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              color: AppTheme.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(
                color: AppTheme.grey2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
            ],
          ],
        ),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(
            color: AppTheme.orange,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          )),
        ),
    ],
  );
}

// ─── Category Chip ────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppTheme.black : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppTheme.black : AppTheme.border),
        boxShadow: selected ? [AppTheme.softShadow(.10)] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.grey1,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    ),
  );
}

// ─── Shimmer Grid ─────────────────────────────────────────────────
class ShimmerGrid extends StatelessWidget {
  final int count;
  const ShimmerGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.66,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
    ),
    itemCount: count,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: AppTheme.border,
      highlightColor: AppTheme.bgCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
  );
}
