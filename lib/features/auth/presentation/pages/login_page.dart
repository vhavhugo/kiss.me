import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCB2769), Color(0xFF840444)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (kIsWeb && constraints.maxWidth >= 900) {
                return _buildWebLayout(context, ref, authState, constraints);
              }

              final logoWidth = constraints.maxWidth < 360
                  ? constraints.maxWidth * 0.65
                  : 228.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/login_logo.png',
                              width: logoWidth,
                              height: logoWidth * 766 / 798,
                              fit: BoxFit.contain,
                              semanticLabel: 'Logo Kiss Me',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Porque tudo começa com um beijo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 26),
                            if (authState.status == AuthStatus.authenticating)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 70),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else
                              Column(
                                children: [
                                  _SocialLoginButton(
                                    icon: FontAwesomeIcons.google,
                                    label: "Entrar com Google",
                                    color: Colors.white,
                                    textColor: Colors.black87,
                                    onTap: () =>
                                        _handleGoogleLogin(context, ref),
                                  ),
                                  const SizedBox(height: 12),
                                  _SocialLoginButton(
                                    icon: FontAwesomeIcons.instagram,
                                    label: "Entrar com Instagram",
                                    color: Colors.white,
                                    textColor: const Color(0xFFE1306C),
                                    onTap: () =>
                                        _handleInstagramLogin(context, ref),
                                  ),
                                  const SizedBox(height: 12),
                                  _SocialLoginButton(
                                    icon: FontAwesomeIcons.tiktok,
                                    label: "Entrar com TikTok",
                                    color: Colors.black87,
                                    textColor: Colors.white,
                                    onTap: () =>
                                        _handleTikTokLogin(context, ref),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 22),
                            const Text(
                              "Ao entrar, você concorda com nossos Termos e Políticas.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    BoxConstraints constraints,
  ) {
    final cardWidth = math.min(1160.0, constraints.maxWidth - 64);
    final brandWidth = cardWidth * 11 / 21;
    final cardHeight = math.max(
      640.0,
      math.min(760.0, constraints.maxHeight - 48),
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F8), Color(0xFFF3EEF6)],
        ),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF57233E).withValues(alpha: 0.12),
                        blurRadius: 48,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 11,
                        child: _WebBrandPanel(availableWidth: brandWidth),
                      ),
                      Expanded(
                        flex: 10,
                        child: _buildWebLoginPanel(context, ref, authState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLoginPanel(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 44),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'BEM-VINDO AO KISS ME',
            style: TextStyle(
              color: Color(0xFFB3205D),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sua próxima história começa aqui.',
            style: TextStyle(
              color: Color(0xFF342331),
              fontSize: 34,
              height: 1.16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Entre para conhecer pessoas e criar conexões de verdade.',
            style: TextStyle(
              color: Color(0xFF766873),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (authState.status == AuthStatus.authenticating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 88),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFB3205D)),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SocialLoginButton(
                  icon: FontAwesomeIcons.google,
                  label: 'Entrar com Google',
                  color: Colors.white,
                  textColor: const Color(0xFF342331),
                  onTap: () => _handleGoogleLogin(context, ref),
                ),
                const SizedBox(height: 14),
                _SocialLoginButton(
                  icon: FontAwesomeIcons.instagram,
                  label: 'Entrar com Instagram',
                  color: const Color(0xFFFFF4F8),
                  textColor: const Color(0xFFC02A68),
                  onTap: () => _handleInstagramLogin(context, ref),
                ),
                const SizedBox(height: 14),
                _SocialLoginButton(
                  icon: FontAwesomeIcons.tiktok,
                  label: 'Entrar com TikTok',
                  color: const Color(0xFF211B23),
                  textColor: Colors.white,
                  onTap: () => _handleTikTokLogin(context, ref),
                ),
              ],
            ),
          const SizedBox(height: 28),
          const Text(
            'Ao continuar, você concorda com nossos Termos e Políticas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8D8089),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleGoogleLogin(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_providerError('Google', e))));
      }
    }
  }

  void _handleInstagramLogin(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).loginWithInstagram();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_providerError('Instagram', e))));
      }
    }
  }

  void _handleTikTokLogin(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).loginWithTikTok();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_providerError('TikTok', e))));
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

class _WebBrandPanel extends StatelessWidget {
  final double availableWidth;

  const _WebBrandPanel({required this.availableWidth});

  @override
  Widget build(BuildContext context) {
    final logoWidth = math.min(350.0, availableWidth - 72);

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCB2769), Color(0xFF840444)],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -95,
          child: _WebGlow(size: 270, opacity: 0.07),
        ),
        Positioned(
          bottom: -130,
          left: -95,
          child: _WebGlow(size: 330, opacity: 0.06),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/login_logo.png',
                  width: logoWidth,
                  height: logoWidth * 766 / 798,
                  fit: BoxFit.contain,
                  semanticLabel: 'Logo Kiss Me',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Porque tudo começa com um beijo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Conexões leves, momentos reais.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFDCC3CF), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WebGlow extends StatelessWidget {
  final double size;
  final double opacity;

  const _WebGlow({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
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
      borderRadius: BorderRadius.circular(28),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              FaIcon(icon, color: textColor, size: 22),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 22),
            ],
          ),
        ),
      ),
    );
  }
}
