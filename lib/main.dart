import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SupabaseSetupPage(),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
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
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainNavigationPage(),
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    switch (authState.status) {
      case AuthStatus.authenticating:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.onboarding:
        return const OnboardingPage();
      case AuthStatus.authenticated:
        return const MainNavigationPage();
      case AuthStatus.unauthenticated:
        return const LoginPage();
    }
  }
}

class SupabaseSetupPage extends StatelessWidget {
  const SupabaseSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFFFF7043), size: 72),
                const SizedBox(height: 20),
                const Text(
                  'Kiss Me',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Configure o Supabase para iniciar o aplicativo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                const SelectableText(
                  'flutter run -d chrome \\\n+--dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \\\n+--dart-define=SUPABASE_PUBLISHABLE_KEY=sua-chave-publishable',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Use o Project URL e a Publishable key do Supabase Dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
