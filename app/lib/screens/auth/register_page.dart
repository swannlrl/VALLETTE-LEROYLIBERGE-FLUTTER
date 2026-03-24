import 'package:flutter/material.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await pb.collection('users').create(body: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'passwordConfirm': _confirmController.text,
      });

      // Auto-login after registration
      await pb.collection('users').authWithPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = 'Erreur lors de l\'inscription');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectorialImages.iconBackCurved,
            colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
            width: 28,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Inscription',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Avenir',
                    letterSpacing: -0.48,
                  ),
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Adresse email',
                    hintStyle: const TextStyle(
                      color: AppColors.grey3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 11, right: 20),
                      child: SvgPicture.asset(
                        AppVectorialImages.iconEmail,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 44),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    hintStyle: const TextStyle(
                      color: AppColors.grey3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 11, right: 20),
                      child: SvgPicture.asset(
                        AppVectorialImages.iconLock,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 44),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Confirmation du mot de passe',
                    hintStyle: const TextStyle(
                      color: AppColors.grey3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 11, right: 20),
                      child: SvgPicture.asset(
                        AppVectorialImages.iconLock,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 44),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grey2, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: 197,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.blue,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'S\'INSCRIRE',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.36,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
