import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── Product Card ─────────────────────────────────────────────────
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

  // Color único por categoría
  Color get _bgColor {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return const Color(0xFFEEF2FF);
    if (c.contains('bater')) return const Color(0xFFECFDF5);
    if (c.contains('funda') || c.contains('tapa')) return const Color(0xFFF5F3FF);
    if (c.contains('cable') || c.contains('cargador') || c.contains('conector')) return const Color(0xFFFFFBEB);
    if (c.contains('herramienta')) return const Color(0xFFEFF6FF);
    if (c.contains('auricular') || c.contains('corneta')) return const Color(0xFFFDF2F8);
    if (c.contains('camara')) return const Color(0xFFF0FDF4);
    if (c.contains('flex')) return const Color(0xFFFEF2F2);
    return AppTheme.orangeLight;
  }

  Color get _iconColor {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return const Color(0xFF6366F1);
    if (c.contains('bater')) return const Color(0xFF10B981);
    if (c.contains('funda') || c.contains('tapa')) return const Color(0xFF8B5CF6);
    if (c.contains('cable') || c.contains('cargador') || c.contains('conector')) return const Color(0xFFF59E0B);
    if (c.contains('herramienta')) return const Color(0xFF3B82F6);
    if (c.contains('auricular') || c.contains('corneta')) return const Color(0xFFEC4899);
    if (c.contains('camara')) return const Color(0xFF14B8A6);
    if (c.contains('flex')) return const Color(0xFFEF4444);
    return AppTheme.orange;
  }

  IconData get _icon {
    final c = product.category.toLowerCase();
    if (c.contains('pantalla')) return Icons.phone_android;
    if (c.contains('bater')) return Icons.battery_charging_full;
    if (c.contains('funda')) return Icons.shield;
    if (c.contains('tapa')) return Icons.layers;
    if (c.contains('cable')) return Icons.cable;
    if (c.contains('cargador')) return Icons.power;
    if (c.contains('conector')) return Icons.settings_input_component;
    if (c.contains('herramienta')) return Icons.build;
    if (c.contains('auricular') || c.contains('corneta')) return Icons.headphones;
    if (c.contains('camara')) return Icons.camera_alt;
    if (c.contains('flex')) return Icons.developer_board;
    return Icons.devices_other;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen / placeholder con color por categoría
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  children: [
                    // Fondo de color
                    Container(color: _bgColor),
                    // Imagen real o placeholder
                    if (product.imageUrl != null &&
                        !product.imageUrl!.endsWith('.svg'))
                      CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (_, __) => _placeholderContent(),
                        errorWidget: (_, __, ___) => _placeholderContent(),
                      )
                    else
                      _placeholderContent(),
                    // Badge HOT / NEW
                    if (isHot)
                      Positioned(
                        top: 8, left: 8,
                        child: _badge('HOT', AppTheme.orange),
                      ),
                    if (isNew && !isHot)
                      Positioned(
                        top: 8, left: 8,
                        child: _badge('NEW', AppTheme.black),
                      ),
                    // Badge calidad
                    if (product.quality != null)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.quality!,
                            style: TextStyle(
                              color: _iconColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marca
                  if (product.brand != null)
                    Text(
                      product.brand!.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.grey3,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (onAddCart != null)
                        GestureDetector(
                          onTap: onAddCart,
                          child: Container(
                            width: 26, height: 26,
                            decoration: const BoxDecoration(
                              color: AppTheme.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
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
        Icon(_icon, color: _iconColor, size: 38),
        const SizedBox(height: 4),
        Text(
          product.category,
          style: TextStyle(
            color: _iconColor.withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
      ),
    ),
  );
}

// ─── Section Header ───────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(
        color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.w800)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(
            color: AppTheme.orange, fontSize: 12, fontWeight: FontWeight.w600)),
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
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppTheme.black : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.black : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.grey2,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
      crossAxisCount: 2, childAspectRatio: 0.72,
      crossAxisSpacing: 12, mainAxisSpacing: 12,
    ),
    itemCount: count,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: AppTheme.border,
      highlightColor: AppTheme.bgCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}