import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class RappelDetailPage extends StatelessWidget {
  final RecordModel rappel;
  const RappelDetailPage({super.key, required this.rappel});

  @override
  Widget build(BuildContext context) {
    // Récupération de la campagne "expand"
    final campagne = rappel.expand['campagnes']?[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Rappel produit")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo du produit
            if (campagne?.getStringValue('image_url') != "")
              Image.network(campagne!.getStringValue('image_url'), height: 300, fit: BoxFit.contain),
            
            // Sections grises
            _buildSection("Motif du rappel", campagne?.getStringValue('motif')),
            _buildSection("Conduite à tenir", campagne?.getStringValue('conduite')),
            _buildSection("Lots concernés", rappel.getStringValue('lot')),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFF4F4F9), // Fond gris clair
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(content ?? "Information non disponible", style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}