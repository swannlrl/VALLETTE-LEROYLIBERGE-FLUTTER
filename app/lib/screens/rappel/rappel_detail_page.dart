import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/res/app_colors.dart';

class RappelDetailPage extends StatelessWidget {
  const RappelDetailPage({super.key, required this.record});

  final RecordModel record;

  @override
  Widget build(BuildContext context) {
    // Lecture directe depuis la collection unifiée "rappels"
    final String titre = record.getStringValue('titre').isNotEmpty
        ? record.getStringValue('titre')
        : 'Rappel produit';
    final String imageUrl = record.getStringValue('image_url');
    final String motif = record.getStringValue('motif');
    final String risques = record.getStringValue('risques');
    final String conduite = record.getStringValue('conduite');
    final String lienPdf = record.getStringValue('lien_pdf');
    final String dateDebut = record.getStringValue('date_debut');
    final String dateFin = record.getStringValue('date_fin');
    final String distributeurs = record.getStringValue('distributeurs');
    final String zoneGeo = record.getStringValue('zone_geographique');
    final String infosComp = record.getStringValue('informations_complementaires');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectorialImages.iconBack,
            colorFilter: const ColorFilter.mode(AppColors.blueDark, BlendMode.srcIn),
            width: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Fiche de rappel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Bouton partage
          if (lienPdf.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
              onPressed: () => Share.share('Rappel produit : $titre\n$lienPdf'),
            ),
          if (lienPdf.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Ouvrir la fiche PDF',
              onPressed: () => _openPdf(lienPdf),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            if (imageUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            if (imageUrl.isNotEmpty) const SizedBox(height: 16),

            // Titre
            Text(
              titre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Bandeau d'alerte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppVectorialImages.iconRappelBanner,
                    colorFilter: const ColorFilter.mode(Color(0xFFA60000), BlendMode.srcIn),
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ce produit fait l\'objet d\'un rappel',
                      style: TextStyle(
                        color: Color(0xFFA60000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dates de commercialisation
            if (dateDebut.isNotEmpty || dateFin.isNotEmpty)
              _Section(
                title: 'Dates de commercialisation',
                iconData: Icons.calendar_today,
                child: Text(
                  'Du $dateDebut au $dateFin',
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Distributeurs
            if (distributeurs.isNotEmpty)
              _Section(
                title: 'Distributeurs',
                iconData: Icons.store,
                child: Text(
                  distributeurs,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Zone géographique
            if (zoneGeo.isNotEmpty)
              _Section(
                title: 'Zone géographique de vente',
                icon: AppVectorialImages.iconLocation,
                child: Text(
                  zoneGeo,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Motif du rappel
            if (motif.isNotEmpty)
              _Section(
                title: 'Motif du rappel',
                iconData: Icons.report_problem,
                child: Text(
                  motif,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Risques encourus
            if (risques.isNotEmpty)
              _Section(
                title: 'Risques encourus',
                iconData: Icons.health_and_safety,
                child: Text(
                  risques,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Informations complémentaires
            if (infosComp.isNotEmpty)
              _Section(
                title: 'Informations complémentaires',
                iconData: Icons.info_outline,
                child: Text(
                  infosComp,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Conduite à tenir
            if (conduite.isNotEmpty)
              _Section(
                title: 'Conduite à tenir',
                iconData: Icons.checklist,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: conduite
                      .split('|')
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  item.trim(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // Bouton PDF en bas
            if (lienPdf.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
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
            ],
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

class _Section extends StatelessWidget {
  final String title;
  final String? icon;
  final IconData? iconData;
  final Widget child;
  
  const _Section({
    required this.title,
    this.icon,
    this.iconData,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                SvgPicture.asset(
                  icon!,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(Colors.grey[700]!, BlendMode.srcIn),
                )
              else if (iconData != null)
                Icon(iconData!, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: child,
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
