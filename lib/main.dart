import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  MobileAds.instance.initialize();

  await Supabase.initialize(
    url: 'https://tfjnbbybrdcmjxwlcuzw.supabase.co/rest/v1/',
    anonKey: 'sb_publishable_VK51tv5QTgZZbWce8dnCSQ_5Jxoc8hA',
  );

  runApp(
    const ProviderScope(
      child: KissMeApp(),
    ),
  );
}

class KissMeApp extends StatelessWidget {
  const KissMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiss Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainNavigationPage(),
      },
    );
  }
}
