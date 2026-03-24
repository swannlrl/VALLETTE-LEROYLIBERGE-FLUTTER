import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/res/app_colors.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _barcodeController = TextEditingController();

  void _onManualSubmit() {
    final code = _barcodeController.text.trim();
    if (code.isEmpty) return;
    context.push('/product', extra: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectorialImages.iconBack,
            colorFilter: const ColorFilter.mode(AppColors.blueDark, BlendMode.srcIn),
            width: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scanner un produit'),
      ),
      body: Column(
        children: [
          // Manual barcode input
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.grey1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrez le code-barre manuellement :',
                  style: TextStyle(
                    color: AppColors.blueDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Ex: 3017620422003',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _onManualSubmit(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onManualSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yellow,
                          foregroundColor: AppColors.blueDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Rechercher',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Camera Launch Button
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppVectorialImages.iconBasket,
                    width: 120,
                    height: 120,
                    colorFilter: const ColorFilter.mode(
                      AppColors.grey2,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Utilisez la caméra de votre appareil\npour scanner un code-barre.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.grey3,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      final res = await SimpleBarcodeScanner.scanBarcode(
                        context,
                        lineColor: '#ff6666',
                        cancelButtonText: 'Annuler',
                        isShowFlashIcon: true,
                      );
                      if (!mounted) return;
                      if (res is String && res != '-1' && res.isNotEmpty) {
                        router.push('/product', extra: res);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ouvrir le scanner'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
