import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/verification_provider.dart';

enum _Challenge {
  front('Olhe de frente para a câmera', Icons.face),
  turn('Vire o rosto para um dos lados', Icons.swap_horiz_rounded),
  smile('Dê um sorriso bem aberto', Icons.sentiment_very_satisfied_rounded),
  eyesClosed('Feche os olhos', Icons.visibility_off_outlined);

  final String instruction;
  final IconData icon;
  const _Challenge(this.instruction, this.icon);
}

/// Verificação em duas etapas, tudo no aparelho:
/// 1) detecta um único rosto real na selfie (ML Kit);
/// 2) exige desafios sorteados (virar, sorrir, fechar os olhos) que uma
///    foto impressa ou uma imagem parada não consegue cumprir.
/// A comparação com as fotos do perfil (embeddings) exige um serviço no
/// servidor e ainda não está ligada.
class PhotoVerificationPage extends ConsumerStatefulWidget {
  const PhotoVerificationPage({super.key});

  @override
  ConsumerState<PhotoVerificationPage> createState() =>
      _PhotoVerificationPageState();
}

class _PhotoVerificationPageState extends ConsumerState<PhotoVerificationPage> {
  late List<_Challenge> _steps;
  int _index = 0;
  bool _busy = false;
  String? _feedback;
  late final FaceDetector _detector;

  @override
  void initState() {
    super.initState();
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _newRound();
  }

  void _newRound() {
    final random = Random.secure();
    final extra = [_Challenge.turn, _Challenge.smile, _Challenge.eyesClosed]
      ..shuffle(random);
    _steps = [_Challenge.front, extra[0], extra[1]];
    _index = 0;
    _feedback = null;
  }

  @override
  void dispose() {
    _detector.close();
    super.dispose();
  }

  Future<void> _capture() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      setState(() => _feedback =
          'A verificação está disponível apenas no aplicativo do celular.');
      return;
    }
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      final shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
      );
      if (shot == null) return;
      final faces =
          await _detector.processImage(InputImage.fromFilePath(shot.path));
      try {
        await File(shot.path).delete();
      } catch (_) {}

      final error = _validate(_steps[_index], faces);
      if (error != null) {
        setState(() => _feedback = error);
        return;
      }
      if (_index + 1 >= _steps.length) {
        await ref.read(verificationProvider.notifier).markVerified();
        if (mounted) setState(() => _index = _steps.length);
      } else {
        setState(() => _index++);
      }
    } catch (_) {
      setState(() => _feedback =
          'Não foi possível usar a câmera. Verifique a permissão e tente de novo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validate(_Challenge c, List<Face> faces) {
    if (faces.isEmpty) return 'Não encontrei seu rosto. Tente com mais luz.';
    if (faces.length > 1) return 'Apareça sozinho(a) na foto.';
    final f = faces.first;
    final yaw = (f.headEulerAngleY ?? 0).abs();
    final left = f.leftEyeOpenProbability;
    final right = f.rightEyeOpenProbability;
    switch (c) {
      case _Challenge.front:
        if (yaw > 15) return 'Olhe de frente, sem virar o rosto.';
        if ((left ?? 1) < 0.5 || (right ?? 1) < 0.5) {
          return 'Mantenha os olhos abertos.';
        }
        return null;
      case _Challenge.turn:
        return yaw >= 20 ? null : 'Vire um pouco mais o rosto para o lado.';
      case _Challenge.smile:
        return (f.smilingProbability ?? 0) >= 0.7
            ? null
            : 'Sorria mais, com os dentes à mostra.';
      case _Challenge.eyesClosed:
        return (left ?? 1) < 0.3 && (right ?? 1) < 0.3
            ? null
            : 'Feche os dois olhos até a foto ser tirada.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _index >= _steps.length || ref.watch(verificationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verificação de perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: done ? _buildDone() : _buildStep(),
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_rounded, size: 88, color: Colors.blue),
        const SizedBox(height: 16),
        const Text('Perfil verificado!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Você passou nos desafios de vivacidade. O selo aparece para quem vê o seu perfil.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.pop(context),
          child: const Text('Concluir'),
        ),
      ],
    );
  }

  Widget _buildStep() {
    final step = _steps[_index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _steps.length; i++)
              Container(
                width: 36,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i <= _index ? AppColors.primary : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Icon(step.icon, size: 84, color: AppColors.primary),
        const SizedBox(height: 16),
        Text('Passo ${_index + 1} de ${_steps.length}',
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(step.instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Os desafios mudam a cada tentativa para impedir fotos e vídeos falsos. Nada sai do seu aparelho.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (_feedback != null) ...[
          const SizedBox(height: 14),
          Text(_feedback!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          onPressed: _busy ? null : _capture,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.photo_camera_front_outlined),
          label: Text(_busy ? 'Analisando...' : 'Tirar foto'),
        ),
        TextButton(
          onPressed: _busy ? null : () => setState(_newRound),
          child: const Text('Recomeçar'),
        ),
      ],
    );
  }
}
