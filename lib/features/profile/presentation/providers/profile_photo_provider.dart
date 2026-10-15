import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foto principal do perfil (primeira foto salva), usada em Ajustes.
class ProfilePhotoNotifier extends Notifier<Uint8List?> {
  @override
  Uint8List? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('my_profile_v1');
    if (raw == null) return;
    final photos = (jsonDecode(raw) as Map<String, dynamic>)['photos'] as List?;
    if (photos == null || photos.isEmpty) return;
    state = base64Decode(photos.first as String);
  }

  void set(Uint8List? photo) => state = photo;
}

final profilePhotoProvider =
    NotifierProvider<ProfilePhotoNotifier, Uint8List?>(ProfilePhotoNotifier.new);
