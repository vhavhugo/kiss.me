import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String userId;
  final bool isCaller;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.userId,
    required this.isCaller,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _supabase = Supabase.instance.client;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RealtimeChannel? _signalChannel;
  StreamSubscription<List<Map<String, dynamic>>>? _signalSubscription;
  bool _isMuted = false;
  bool _isCameraOff = false;
  String _status = 'Iniciando chamada...';

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  @override
  void dispose() {
    _signalSubscription?.cancel();
    if (_signalChannel != null) _supabase.removeChannel(_signalChannel!);
    _localStream?.dispose();
    _peerConnection?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      _localRenderer.srcObject = _localStream;
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) _remoteRenderer.srcObject = event.streams.first;
      };
      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          _sendSignal('candidate', {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
        }
      };
      _listenForSignals();
      if (widget.isCaller) {
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        _sendSignal('offer', {'sdp': offer.sdp, 'type': offer.type});
      }
      if (mounted) setState(() => _status = 'Conectando com segurança...');
    } catch (error) {
      if (mounted) setState(() => _status = 'Não foi possível iniciar a chamada.');
    }
  }

  void _listenForSignals() {
    _signalSubscription = _supabase
        .from('call_signals')
        .stream(primaryKey: ['id'])
        .eq('call_id', widget.callId)
        .order('created_at')
        .listen((signals) async {
          for (final signal in signals) {
            if (signal['sender_id'] == widget.userId) continue;
            await _handleSignal(signal['signal_type'] as String, signal['payload'] as Map<String, dynamic>);
          }
        });
  }

  Future<void> _handleSignal(String type, Map<String, dynamic> payload) async {
    final peer = _peerConnection;
    if (peer == null) return;
    if (type == 'offer') {
      await peer.setRemoteDescription(RTCSessionDescription(payload['sdp'] as String, payload['type'] as String));
      final answer = await peer.createAnswer();
      await peer.setLocalDescription(answer);
      _sendSignal('answer', {'sdp': answer.sdp, 'type': answer.type});
    } else if (type == 'answer') {
      await peer.setRemoteDescription(RTCSessionDescription(payload['sdp'] as String, payload['type'] as String));
    } else if (type == 'candidate') {
      await peer.addCandidate(RTCIceCandidate(
        payload['candidate'] as String?,
        payload['sdpMid'] as String?,
        payload['sdpMLineIndex'] as int?,
      ));
    }
  }

  Future<void> _sendSignal(String type, Map<String, dynamic> payload) {
    return _supabase.from('call_signals').insert({
      'call_id': widget.callId,
      'sender_id': widget.userId,
      'signal_type': type,
      'payload': payload,
    });
  }

  void _toggleMute() {
    final tracks = _localStream?.getAudioTracks() ?? [];
    for (final track in tracks) {
      track.enabled = _isMuted;
    }
    setState(() => _isMuted = !_isMuted);
  }

  void _toggleCamera() {
    final tracks = _localStream?.getVideoTracks() ?? [];
    for (final track in tracks) {
      track.enabled = _isCameraOff;
    }
    setState(() => _isCameraOff = !_isCameraOff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Text(_status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            Positioned(
              top: 20,
              right: 20,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(onPressed: _toggleMute, icon: Icon(_isMuted ? Icons.mic_off : Icons.mic)),
                  const SizedBox(width: 16),
                  IconButton.filled(onPressed: _toggleCamera, icon: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam)),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}