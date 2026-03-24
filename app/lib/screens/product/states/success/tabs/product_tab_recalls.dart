import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/screens/product/rappel_fetcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductTabRecalls extends StatelessWidget {
  const ProductTabRecalls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RappelFetcher>(
      builder: (context, rappelNotifier, _) {
        return switch (rappelNotifier.state) {
          RappelLoading() => const Center(child: CircularProgressIndicator()),
          RappelNotFound() => _buildNoRecall(),
          RappelFound(record: var record) => _buildRecall(context, record),
        };
      },
    );
  }

  Widget _buildNoRecall() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppVectorialImages.iconRappelBanner,
              colorFilter: ColorFilter.mode(AppColors.grey2, BlendMode.srcIn),
              width: 48,
              height: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun rappel produit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ce produit ne fait pas l\'objet d\'un rappel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey2, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecall(BuildContext context, dynamic record) {
    final String titre = record.getStringValue('titre').isNotEmpty
        ? record.getStringValue('titre')
        : 'Rappel produit';
    final String motif = record.getStringValue('motif');
    final String risques = record.getStringValue('risques');
    final String conduite = record.getStringValue('conduite');
    final String lienPdf = record.getStringValue('lien_pdf');
    final String dateDebut = record.getStringValue('date_debut');
    final String dateFin = record.getStringValue('date_fin');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau alerte
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFA60000).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppVectorialImages.iconRappelBanner,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFFA60000), BlendMode.srcIn),
                  width: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titre,
                    style: const TextStyle(
                      color: Color(0xFFA60000),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (dateDebut.isNotEmpty || dateFin.isNotEmpty) ...[
            _RecallRow(
              icon: Icons.calendar_today_outlined,
              label: 'Période',
              value: 'Du $dateDebut au $dateFin',
            ),
            const Divider(),
          ],

          if (motif.isNotEmpty) ...[
            _RecallRow(
              icon: Icons.report_problem_outlined,
              label: 'Motif',
              value: motif,
            ),
            const Divider(),
          ],

          if (risques.isNotEmpty) ...[
            _RecallRow(
              icon: Icons.health_and_safety_outlined,
              label: 'Risques',
              value: risques,
            ),
            const Divider(),
          ],

          if (conduite.isNotEmpty) ...[
            _RecallRow(
              icon: Icons.checklist_outlined,
              label: 'Conduite à tenir',
              value: conduite.replaceAll('|', '\n• '),
            ),
            const Divider(),
          ],

          const SizedBox(height: 16),

          // Boutons
          Row(
            children: [
              if (lienPdf.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPdf(lienPdf),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Fiche PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFA60000),
                      side: const BorderSide(color: Color(0xFFA60000)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Share.share(
                    'Rappel produit : $titre${lienPdf.isNotEmpty ? '\n$lienPdf' : ''}',
                  ),
                  icon: Icon(AppIcons.share, size: 16),
                  label: const Text('Partager'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.push('/rappel', extra: {
                'record': record,
                'imageUrl': context.read<Product>().picture ?? '',
              }),
              child: const Text(
                'Voir la fiche complète',
                style: TextStyle(color: AppColors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _RecallRow extends StatelessWidget {
  const _RecallRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.grey3),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.grey3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
