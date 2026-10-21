import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/verification_provider.dart';

/// Selo exibido somente depois que a verificação do perfil foi concluída.
class VerifiedSeal extends ConsumerWidget {
  final double size;
  const VerifiedSeal({super.key, this.size = 22});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(verificationProvider)) return const SizedBox.shrink();
    return Tooltip(
      message: 'Perfil verificado',
      child: Icon(Icons.verified_rounded, color: Colors.blue, size: size),
    );
  }
}
