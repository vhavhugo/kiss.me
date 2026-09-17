import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[400]!, Colors.pink[800]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.favorite, color: Colors.white, size: 80),
              const Text(
                "Kiss Me",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "Porque tudo começa com um beijo",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(flex: 3),
              if (authState.status == AuthStatus.authenticating)
                const CircularProgressIndicator(color: Colors.white)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        label: "Entrar com Google",
                        color: Colors.white,
                        textColor: Colors.black87,
                        onTap: () => _handleGoogleLogin(context, ref),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              const Text(
                "Ao entrar, você concorda com nossos Termos e Políticas.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoogleLogin(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_providerError('Google', e))),
        );
      }
    }
  }

  String _providerError(String provider, Object error) {
    if (error is AuthException && error.code == 'validation_failed') {
      return 'Login $provider indisponível: habilite o provider $provider no Supabase Dashboard.';
    }
    return 'Falha no login $provider. Verifique a configuração do Supabase.';
  }
}

class _SocialLoginButton extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              FaIcon(icon, color: textColor, size: 24),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
