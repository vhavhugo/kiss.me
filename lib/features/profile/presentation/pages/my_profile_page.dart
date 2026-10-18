import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_photo_provider.dart';
import 'photo_verification_page.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  static const int _maxPhotos = 6;
  static const List<String> _genders = [
    'Mulher',
    'Homem',
    'Não-binário',
    'Prefiro não informar',
  ];

  static const List<String> _educationLevels = [
    'Técnico',
    'Faculdade',
    'MBA',
    'Especialização',
    'Mestrado',
    'Doutorado',
    'Pós-doutorado',
    'PhD',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _dreamController = TextEditingController();
  final _cityController = TextEditingController();
  final _professionController = TextEditingController();

  final List<Uint8List> _photos = [];
  DateTime? _birthDate;
  String? _gender;
  String? _education;
  bool _acceptSponsor = true;
  final List<String> _icebreakers = [];
  final TextEditingController _customQuestion = TextEditingController();
  static const int _maxIcebreakers = 3;
  static const List<String> _suggestedQuestions = [
    'O que você faria se eu aceitasse um encontro com você?',
    'Qual o seu encontro ideal?',
    'Qual foi a última coisa que te fez rir de verdade?',
    'Qual viagem você nunca esqueceu?',
    'Que música define o seu momento?',
  ];

  static const String _prefsKey = 'my_profile_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || !mounted) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _nameController.text = data['name'] as String? ?? '';
      _aboutController.text = data['about'] as String? ?? '';
      _dreamController.text = data['dream'] as String? ?? '';
      _cityController.text = data['city'] as String? ?? '';
      _professionController.text = data['profession'] as String? ?? '';
      final gender = data['gender'] as String?;
      _gender = _genders.contains(gender) ? gender : null;
      final birth = data['birthDate'] as String?;
      _birthDate = birth == null ? null : DateTime.tryParse(birth);
      final education = data['education'] as String?;
      _education = _educationLevels.contains(education) ? education : null;
      _acceptSponsor = data['acceptSponsor'] as bool? ?? true;
      _icebreakers
        ..clear()
        ..addAll((data['icebreakers'] as List? ?? []).cast<String>());
      _photos
        ..clear()
        ..addAll((data['photos'] as List? ?? [])
            .map((e) => base64Decode(e as String)));
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'name': _nameController.text.trim(),
        'about': _aboutController.text.trim(),
        'dream': _dreamController.text.trim(),
        'city': _cityController.text.trim(),
        'profession': _professionController.text.trim(),
        'gender': _gender,
        'education': _education,
        'birthDate': _birthDate?.toIso8601String(),
        'acceptSponsor': _acceptSponsor,
        'icebreakers': _icebreakers,
        'photos': _photos.map(base64Encode).toList(),
      }),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _dreamController.dispose();
    _cityController.dispose();
    _professionController.dispose();
    _customQuestion.dispose();
    super.dispose();
  }

  int? get _age {
    final birth = _birthDate;
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    final added = result.files
        .map((f) => f.bytes)
        .whereType<Uint8List>()
        .take(remaining);
    setState(() => _photos.addAll(added));
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe sua data de nascimento.')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await _persist();
    ref.read(profilePhotoProvider.notifier).set(_photos.isEmpty ? null : _photos.first);
    messenger.showSnackBar(
      const SnackBar(content: Text('Perfil salvo com sucesso!')),
    );
    navigator.pop();
  }

  Widget _section(String title, {String? subtitle}) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      );

  Widget _photoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _maxPhotos,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, i) {
        if (i < _photos.length) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_photos[i], fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _photos.removeAt(i)),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
              if (i == 0)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Principal',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          );
        }
        return InkWell(
          onTap: _pickPhotos,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(90)),
            ),
            child: const Icon(Icons.add_a_photo_outlined,
                color: AppColors.primary),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = _age;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              _section('Minhas fotos',
                  subtitle:
                      'Até $_maxPhotos fotos. A primeira é a principal.'),
              _photoGrid(),
              _section('Informações básicas'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Nome', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe seu nome'
                    : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de nascimento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.cake_outlined),
                  ),
                  child: Text(
                    _birthDate == null
                        ? 'Selecionar'
                        : '${_formatDate(_birthDate!)}  ($age anos)',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                    labelText: 'Gênero', border: OutlineInputBorder()),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'Cidade', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(
                    labelText: 'Profissão', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _education,
                decoration: const InputDecoration(
                    labelText: 'Escolaridade', border: OutlineInputBorder()),
                items: _educationLevels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _education = v),
              ),
              _section('Sobre mim'),
              TextFormField(
                controller: _aboutController,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Conte um pouco sobre você...',
                  border: OutlineInputBorder(),
                ),
              ),
              _section('Meu sonho'),
              TextFormField(
                controller: _dreamController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Qual é o seu maior sonho?',
                  border: OutlineInputBorder(),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  secondary: const Icon(Icons.volunteer_activism_rounded,
                      color: AppColors.primary),
                  title: const Text('Aceito um patrocinador'),
                  subtitle: const Text(
                      'Permite que alguém apoie a realização do seu sonho.'),
                  value: _acceptSponsor,
                  onChanged: (v) => setState(() => _acceptSponsor = v),
                ),
              ),
              _section('Caderno de perguntas',
                  subtitle:
                      'Quem quiser te enviar um ícone precisa responder uma delas. Escolha até $_maxIcebreakers.'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final q in {..._suggestedQuestions, ..._icebreakers})
                    FilterChip(
                      label: Text(q),
                      selected: _icebreakers.contains(q),
                      onSelected: (on) => setState(() {
                        if (on) {
                          if (_icebreakers.length < _maxIcebreakers) {
                            _icebreakers.add(q);
                          }
                        } else {
                          _icebreakers.remove(q);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customQuestion,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: 'Escreva sua própria pergunta',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      final q = _customQuestion.text.trim();
                      if (q.length < 8 ||
                          _icebreakers.length >= _maxIcebreakers ||
                          _icebreakers.contains(q)) {
                        return;
                      }
                      setState(() {
                        _icebreakers.add(q);
                        _customQuestion.clear();
                      });
                    },
                  ),
                ),
              ),
              _section('Verificação'),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.verified_user_outlined,
                      color: AppColors.primary),
                  title: const Text('Verificar meu perfil'),
                  subtitle: const Text('Tire uma selfie para ganhar o selo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhotoVerificationPage()),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Salvar perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
