import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/radar/presentation/pages/radar_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase antes de rodar o app
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // A primeira tela agora é a LoginPage
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/radar': (context) => const RadarPage(),
      },
    );
  }
}
