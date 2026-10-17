import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

VideoPlayerController _controllerFor(String source) {
  if (source.startsWith('http')) {
    return VideoPlayerController.networkUrl(Uri.parse(source));
  }
  return VideoPlayerController.file(File(source));
}

bool _isPlayable(String source) =>
    source.startsWith('http') || (!kIsWeb && source.startsWith('/'));

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Prévia do vídeo dentro da conversa: mostra o primeiro quadro com um botão
/// de play; tocar abre o vídeo em tela cheia.
class VideoMessagePreview extends StatefulWidget {
  final String source;
  final String? fileName;
  final bool isMine;

  const VideoMessagePreview({
    super.key,
    required this.source,
    required this.fileName,
    required this.isMine,
  });

  @override
  State<VideoMessagePreview> createState() => _VideoMessagePreviewState();
}

class _VideoMessagePreviewState extends State<VideoMessagePreview> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!_isPlayable(widget.source)) {
      _failed = true;
      return;
    }
    final c = _controllerFor(widget.source);
    _controller = c;
    c.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _open() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          source: widget.source,
          title: widget.fileName ?? 'Vídeo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final ratio = ready && c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9;

    return GestureDetector(
      onTap: _failed ? null : _open,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 240,
          child: AspectRatio(
            aspectRatio: ratio.clamp(0.6, 1.8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black87),
                if (ready) FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
                if (!ready && !_failed)
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                if (ready || _failed)
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 2),
                      ),
                      child: Icon(
                        _failed ? Icons.videocam_off_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          ready ? _fmt(c.value.duration) : 'Vídeo',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reprodutor de vídeo em tela cheia.
class VideoPlayerPage extends StatefulWidget {
  final String source;
  final String title;

  const VideoPlayerPage({super.key, required this.source, required this.title});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = _controllerFor(widget.source);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _controller.value;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
      ),
      body: _failed
          ? const Center(
              child: Text('Não foi possível reproduzir o vídeo.',
                  style: TextStyle(color: Colors.white)))
          : !v.isInitialized
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => v.isPlaying ? _controller.pause() : _controller.play(),
                          child: AspectRatio(
                            aspectRatio: v.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller),
                                if (!v.isPlaying)
                                  const Icon(Icons.play_circle_fill_rounded,
                                      color: Colors.white70, size: 72),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
                        child: Row(
                          children: [
                            IconButton(
                              color: Colors.white,
                              icon: Icon(v.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded),
                              onPressed: () =>
                                  v.isPlaying ? _controller.pause() : _controller.play(),
                            ),
                            Text(_fmt(v.position),
                                style: const TextStyle(color: Colors.white)),
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                colors: const VideoProgressColors(
                                  playedColor: AppColors.primary,
                                  bufferedColor: Colors.white38,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                            ),
                            Text(_fmt(v.duration),
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Mensagem de áudio com play/pause e progresso.
class AudioMessageBubble extends StatefulWidget {
  final String source;
  final String? fileName;
  final Color foreground;

  const AudioMessageBubble({
    super.key,
    required this.source,
    required this.fileName,
    required this.foreground,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!_isPlayable(widget.source)) {
      _failed = true;
      return;
    }
    final c = _controllerFor(widget.source);
    _controller = c;
    c.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
    c.addListener(() {
      if (!mounted) return;
      if (c.value.isInitialized &&
          !c.value.isPlaying &&
          c.value.position >= c.value.duration &&
          c.value.duration > Duration.zero) {
        c.seekTo(Duration.zero);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final playing = ready && c.value.isPlaying;
    final total = ready ? c.value.duration : Duration.zero;
    final pos = ready ? c.value.position : Duration.zero;
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final fg = widget.foreground;

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          InkWell(
            onTap: ready ? () => playing ? c.pause() : c.play() : null,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fg.withAlpha(40), shape: BoxShape.circle),
              child: _failed
                  ? Icon(Icons.error_outline_rounded, color: fg)
                  : !ready
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                        )
                      : Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: fg, size: 26),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: fg.withAlpha(60),
                  color: fg,
                ),
                const SizedBox(height: 6),
                Text(
                  _failed ? 'Áudio indisponível' : '${_fmt(playing || pos > Duration.zero ? pos : total)} • Mensagem de voz',
                  style: TextStyle(color: fg.withAlpha(200), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
