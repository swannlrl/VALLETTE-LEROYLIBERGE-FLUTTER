import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RappelBanner extends StatelessWidget {
  const RappelBanner({super.key, required this.record});

  final RecordModel record;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/rappel', extra: {
        'record': record,
        'imageUrl': context.read<Product>().picture ?? '',
      }),
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 13, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0x5CFF0000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                "Ce produit fait l'objet d'un rappel produit",
                style: TextStyle(
                  color: Color(0xFFA60000),
                  fontFamily: 'Avenir',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, color: Color(0xFFA60000), size: 16),
          ],
        ),
      ),
    );
  }
}
