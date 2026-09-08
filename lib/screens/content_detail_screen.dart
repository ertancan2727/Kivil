import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/bundle.dart';
import '../models/content_detail.dart';
import '../services/content_service.dart';
import '../theme/app_colors.dart';

/// Quill editörü boş bırakılınca "<p><br></p>" gibi anlamsız HTML üretebiliyor —
/// bunu gerçek içerik olarak saymayız.
bool _hasContent(String? html) {
  if (html == null) return false;
  final stripped = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  return stripped.isNotEmpty;
}

class ContentDetailScreen extends StatefulWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final int contentId;

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  late final Future<ContentDetail?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = ContentService.fetchDetail(widget.contentId);
  }

  Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<ContentDetail?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.textGold));
          }
          final detail = snapshot.data;
          if (detail == null) {
            return Center(
              child: Text(
                'İçerik yüklenemedi.',
                style: GoogleFonts.manrope(color: AppColors.textMuted),
              ),
            );
          }
          return _DetailBody(detail: detail, onOpenStore: _openStore);
        },
      ),
      // Denedim / Favori / Yapılacak — ekran kayarken sabit kalır.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.15))),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: const _ActionRow(),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.onOpenStore});

  final ContentDetail detail;
  final Future<void> Function(String url) onOpenStore;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          pinned: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        SliverToBoxAdapter(
          child: _StageImage(imageUrl: detail.imageUrl),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail.title,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (detail.isPremium)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.lock_rounded, color: AppColors.textGold, size: 22),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(label: detail.category.name),
                    if (detail.difficulty != null) _Chip(label: detail.difficulty!),
                    if (detail.isNew) _Chip(label: 'Yeni', color: const Color(0xFFE0245E)),
                  ],
                ),
                if (_hasContent(detail.description)) ...[
                  const SizedBox(height: 18),
                  HtmlWidget(
                    detail.description!,
                    textStyle: GoogleFonts.manrope(
                      color: AppColors.textMuted,
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                ],
                if (detail.bundle != null) ...[
                  const SizedBox(height: 28),
                  _BundleSection(bundle: detail.bundle!, onOpenStore: onOpenStore),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Sabit "sahne" arkaplanı + üzerine bindirilen içerik görseli (şeffaf PNG
/// olması beklenir). Işığın vurduğu alana oturacak şekilde ortalanır.
class _StageImage extends StatelessWidget {
  const _StageImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/stage.jpg', fit: BoxFit.cover),
          if (imageUrl != null)
            Align(
              alignment: const Alignment(0, 0.4),
              child: FractionallySizedBox(
                widthFactor: 0.62,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

/// "Denedim / Favori / Yapılacak" — üyelik sistemi kurulunca gerçek işlev
/// kazanacak, şimdilik sadece görsel yer tutucu.
class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionButton(icon: Icons.check_circle_outline_rounded, label: 'Denedim')),
        const SizedBox(width: 10),
        Expanded(child: _ActionButton(icon: Icons.star_outline_rounded, label: 'Favori')),
        const SizedBox(width: 10),
        Expanded(child: _ActionButton(icon: Icons.playlist_add_rounded, label: 'Yapılacak')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleSection extends StatelessWidget {
  const _BundleSection({required this.bundle, required this.onOpenStore});

  final Bundle bundle;
  final Future<void> Function(String url) onOpenStore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bu deneyim için önerilen paket',
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bundle.name,
                style: GoogleFonts.manrope(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (bundle.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  bundle.description!,
                  style: GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in bundle.products)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        p.name,
                        style: GoogleFonts.manrope(color: AppColors.textPrimary, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => onOpenStore(bundle.storeUrl),
                      child: Center(
                        child: Text(
                          'Satın Al',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
