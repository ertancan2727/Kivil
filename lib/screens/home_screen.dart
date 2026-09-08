import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category.dart';
import '../models/content_item.dart';
import '../services/content_service.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categoriesFuture;
  late Future<List<ContentItem>> _contentFuture;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ContentService.fetchCategories();
    _contentFuture = ContentService.fetchContent();
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _contentFuture = ContentService.fetchContent(categoryId: categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _categoriesFuture = ContentService.fetchCategories();
              _contentFuture = ContentService.fetchContent(categoryId: _selectedCategoryId);
            });
            await Future.wait([_categoriesFuture, _contentFuture]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? const [];
                    return _CategoryRow(
                      categories: categories,
                      selectedCategoryId: _selectedCategoryId,
                      onSelect: _selectCategory,
                    );
                  },
                ),
              ),
              FutureBuilder<List<ContentItem>>(
                future: _contentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.textGold),
                      ),
                    );
                  }
                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Henüz içerik eklenmedi.',
                          style: GoogleFonts.manrope(color: AppColors.textMuted),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => _ContentCard(item: items[index]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo_wordmark.png',
            height: 22,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 22),
          Text(
            'Bugün ne keşfetmek istersin?',
            style: GoogleFonts.cormorantGaramond(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hayalindeki deneyimi seç, sana özel önerilerle tanış.',
            style: GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'Tümü',
              iconUrl: null,
              selected: selectedCategoryId == null,
              onTap: () => onSelect(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            iconUrl: category.iconUrl,
            selected: selectedCategoryId == category.id,
            onTap: () => onSelect(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.iconUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? iconUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppColors.primaryButtonGradient : null,
                color: selected ? null : AppColors.surface,
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.textMuted.withValues(alpha: 0.25),
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Container(
                  color: AppColors.background,
                  child: iconUrl != null
                      ? Image.network(
                          iconUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackIcon(),
                        )
                      : _fallbackIcon(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(Icons.auto_awesome, color: AppColors.textMuted, size: 20),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 96,
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.category.name,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.textGold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.isNew) _Badge(label: 'YENİ', color: const Color(0xFFE0245E)),
                      if (item.isNew && item.isPremium) const SizedBox(width: 6),
                      if (item.isPremium)
                        _Badge(label: 'ÜYELERE ÖZEL', color: AppColors.textGold, icon: Icons.lock_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.local_fire_department_rounded, color: AppColors.textMuted, size: 26),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
