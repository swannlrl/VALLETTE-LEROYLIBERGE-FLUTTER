import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';

class RappelBanner extends StatelessWidget {
  const RappelBanner({super.key, required this.record});

  final RecordModel record;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/rappel', extra: record),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Ce produit fait l'objet d'un rappel produit",
                style: TextStyle(
                  color: Color(0xFFA60000),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFA60000)),
          ],
        ),
      ),
    );
  }
}
