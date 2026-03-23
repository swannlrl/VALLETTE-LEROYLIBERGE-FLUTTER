import 'package:flutter/material.dart';
import 'package:formation_flutter/api/pocketbase_api.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/auth/login_page.dart';
import 'package:formation_flutter/screens/auth/register_page.dart';
import 'package:formation_flutter/screens/favorites/favorites_page.dart';
import 'package:formation_flutter/screens/homepage/homepage_screen.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/screens/rappel/rappel_detail_page.dart';
import 'package:formation_flutter/screens/scanner/scanner_page.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

void main() => runApp(const MyApp());

final _router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = pb.authStore.isValid;
    final isAuthRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(
      path: '/product',
      builder: (_, state) => ProductPage(barcode: state.extra as String),
    ),
    GoRoute(
      path: '/rappel',
      builder: (_, state) =>
          RappelDetailPage(record: state.extra as RecordModel),
    ),
    GoRoute(path: '/scanner', builder: (_, __) => const ScannerPage()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        fontFamily: 'Avenir',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blueDark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
        extensions: [OffThemeExtension.defaultValues()],
      ),
    );
  }
}