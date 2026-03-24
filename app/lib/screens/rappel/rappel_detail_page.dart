import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:formation_flutter/res/app_colors.dart';

class RappelDetailPage extends StatelessWidget {
  const RappelDetailPage({
    super.key,
    required this.record,
    this.productImageUrl = '',
  });

  final RecordModel record;
  final String productImageUrl;

  static const _kContentPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  static const _kContentStyle = TextStyle(
    color: AppColors.grey3, // rgba(106,106,106,1) ≈ #6A6A6A
    fontFamily: 'Avenir',
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final String imageUrl = record.getStringValue('image_url').isNotEmpty
        ? record.getStringValue('image_url')
        : productImageUrl;
    final String motif = record.getStringValue('motif');
    final String risques = record.getStringValue('risques');
    final String conduite = record.getStringValue('conduite');
    final String lienPdf = record.getStringValue('lien_pdf');
    final String dateDebut = record.getStringValue('date_debut');
    final String dateFin = record.getStringValue('date_fin');
    final String distributeurs = record.getStringValue('distributeurs');
    final String zoneGeo = record.getStringValue('zone_geographique');
    final String infosComp =
        record.getStringValue('informations_complementaires');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Rappel produit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
            fontFamily: 'Avenir',
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.blue),
            onPressed: () {
              final text = lienPdf.isNotEmpty
                  ? 'Rappel produit\n$lienPdf'
                  : 'Rappel produit';
              Share.share(text);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image produit — 188×181px, marges 103px gauche / 84px droite (Sketch)
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 103, right: 84, top: 16, bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 188,
                    height: 181,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Dates de commercialisation
            if (dateDebut.isNotEmpty || dateFin.isNotEmpty) ...[
              const _SectionHeader(title: 'Dates de commercialisation'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  'Du $dateDebut au $dateFin',
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Distributeurs
            if (distributeurs.isNotEmpty) ...[
              const _SectionHeader(title: 'Distributeurs'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  distributeurs,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Zone géographique
            if (zoneGeo.isNotEmpty) ...[
              const _SectionHeader(title: 'Zone géographique'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  zoneGeo,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Motif du rappel
            if (motif.isNotEmpty) ...[
              const _SectionHeader(title: 'Motif du rappel'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  motif,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Risques encourus
            if (risques.isNotEmpty) ...[
              const _SectionHeader(title: 'Risques encourus'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  risques,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Conduite à tenir
            if (conduite.isNotEmpty) ...[
              const _SectionHeader(title: 'Conduite à tenir'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  conduite,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Informations complémentaires
            if (infosComp.isNotEmpty) ...[
              const _SectionHeader(title: 'Informations complémentaires'),
              Padding(
                padding: _kContentPadding,
                child: Text(
                  infosComp,
                  textAlign: TextAlign.center,
                  style: _kContentStyle,
                ),
              ),
            ],

            // Bouton PDF
            if (lienPdf.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openPdf(lienPdf),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Voir la fiche de rappel complète'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA60000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
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

// ─────────────────────────────────────────────
// Header de section : fond gris, texte bleu centré (identique à Tab1)
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.grey1,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.blue,
          fontFamily: 'Avenir',
        ),
      ),
    );
  }
}
