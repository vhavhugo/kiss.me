import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../profile/presentation/pages/photo_verification_page.dart';
import '../../../profile/presentation/providers/verification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/radar_provider.dart';
import '../../../privacy/presentation/providers/privacy_provider.dart';
import '../providers/radar_search_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/interaction_actions.dart';
import '../../../chat/presentation/pages/conversation_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../widgets/dissolving_km_animation.dart';
import '../../domain/entities/interaction_entity.dart';

import '../widgets/ai_trust_system.dart';
import '../../domain/entities/user_entity.dart';
import '../../../profile/domain/entities/profile_authenticity_entity.dart';
import '../../../safety/presentation/providers/safety_provider.dart';
import '../../../safety/presentation/widgets/safety_sheet.dart';
import '../../../../features/privacy/presentation/widgets/privacy_safe_indicator.dart';
import '../../../../features/gamification/presentation/widgets/gamification_progress_bar.dart';

class RadarPage extends ConsumerStatefulWidget {
  const RadarPage({super.key});

  @override
  ConsumerState<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends ConsumerState<RadarPage> {
  int _selected = 0;
  final Set<String> _done = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.isOnline) {
        _startSearchWithCurrentLocation(authState.user!.id);
      }
    });
  }

  Future<void> _startSearchWithCurrentLocation(String userId) async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      if (!mounted) return;
      ref
          .read(radarSearchProvider.notifier)
          .startSearch(userId, position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ative a localização para encontrar pessoas próximas.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final blocked = ref.watch(blockedUsersProvider);
    final rawSearch = ref.watch(radarSearchProvider);
    final searchState = rawSearch.copyWith(
      users: rawSearch.users
          .where((u) => !blocked.contains(u.id) && !_done.contains(u.id))
          .toList(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kiss Me Now",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -1,
          ),
        ),
        centerTitle: true,
        leading: _buildStatusToggle(authState),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _buildMainContent(authState, searchState),
      ),
    );
  }

  Widget _buildStatusToggle(AuthState auth) {
    return GestureDetector(
      onTap: () {
        ref.read(authProvider.notifier).toggleOnlineStatus();
        final newAuthState = ref.read(authProvider);
        if (newAuthState.isOnline) {
          _startSearchWithCurrentLocation(newAuthState.user!.id);
        } else {
          ref.read(radarSearchProvider.notifier).stopSearch();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: auth.isOnline ? AppColors.online : AppColors.offline,
            boxShadow: auth.isOnline
                ? [
                    BoxShadow(
                      color: AppColors.online.withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            auth.isOnline
                ? Icons.radar_rounded
                : Icons.power_settings_new_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AuthState auth, RadarSearchState search) {
    if (!auth.isOnline || (search.isSearching && search.users.isEmpty)) {
      return LayoutBuilder(
        key: const ValueKey('searching_content'),
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DissolvingKmAnimation(radiusKm: 0.0),
                  const SizedBox(height: 30),
                  // Sistema de Confiança Híbrido: Combina Local e Global (Alam, 2021)
                  const AiTrustSystem(
                    localJustification:
                        "Fique on-line para que nossa tecnologia encontre afinidades baseadas em seus interesses reais.",
                    score: 0.0,
                  ),
                  const SizedBox(height: 10),
                  const PrivacySafeIndicator(),
                  const SizedBox(height: 20),
                  // Gamificação: Barra de Progresso de Conquista (Feng, 2020)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: GamificationProgressBar(
                      progress: 0.65,
                      label: "NÍVEL DE INTENCIONALIDADE",
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    !auth.isOnline
                        ? "Você está invisível"
                        : "Procurando conexões reais...",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      !auth.isOnline
                          ? "Fique on-line para que o radar encontre pessoas próximas a você agora."
                          : "Estamos varrendo a área para encontrar os 3 perfis mais compatíveis.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final table = search.users.take(3).toList();
    if (table.isEmpty) return _buildEmptyTable();
    final selected = _selected.clamp(0, table.length - 1);
    final current = table[selected];

    return SingleChildScrollView(
      key: const ValueKey('results_content'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        children: [
          const Text(
            'Sua mesa',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Aqui pode rolar um beijo?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Text(
            'Toque em uma carta e escolha',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (!ref.watch(verificationProvider)) _buildVerifyBanner(),
          const SizedBox(height: 4),
          SizedBox(
            height: 270,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() < 250 || table.length < 2) return;
                HapticFeedback.selectionClick();
                // Deslizar para a esquerda traz a próxima carta; para a direita, a anterior.
                setState(
                  () => _selected =
                      (selected + (v < 0 ? 1 : -1) + table.length) %
                      table.length,
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < table.length; i++)
                    Expanded(
                      flex: i == selected ? 5 : 3,
                      child: _TableCard(
                        user: table[i],
                        selected: i == selected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, .08),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(current.id),
              child: _buildSelectedInfo(current),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButtonsRow(current),
          const SizedBox(height: 8),
          const Text(
            'Toque em um ícone para enviar uma mensagem e abrir a conversa.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.verified_user_outlined, color: Colors.blue),
        title: const Text(
          'Verifique seu perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Ganhe o selo azul e mais confiança.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PhotoVerificationPage()),
        ),
      ),
    );
  }

  Widget _buildEmptyTable() {
    return Center(
      key: const ValueKey('empty_table'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🃏', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'A mesa está vazia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Você jogou todas as cartas por aqui. Procure novas pessoas por perto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                setState(() {
                  _done.clear();
                  _selected = 0;
                });
                final auth = ref.read(authProvider);
                if (auth.user != null) {
                  _startSearchWithCurrentLocation(auth.user!.id);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Procurar de novo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInfo(UserEntity user) {
    final verified = user.authenticity.level == AuthenticityLevel.verified;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDistance(user.distanceInMeters),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(user.bio, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                if (user.icebreakers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💬 ${user.icebreakers.first.text}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Denunciar ou bloquear',
            icon: const Icon(Icons.more_vert),
            onPressed: () async {
              final blocked = await showSafetySheet(
                context,
                ref,
                userId: user.id,
                userName: user.name,
              );
              if (blocked && mounted) setState(() => _selected = 0);
            },
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    final t = ref.read(privacySettingsProvider).distanceText(meters);
    return t.startsWith('a ') ? 'Está $t' : '$t de você';
  }

  Widget _buildActionButtonsRow(UserEntity user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final type in ActionType.values)
          ActionButton(type: type, onTap: () => _handleAction(user, type)),
      ],
    );
  }

  Future<void> _handleAction(UserEntity user, ActionType type) async {
    if (_isSending) return;
    _isSending = true;
    try {
      HapticFeedback.mediumImpact();
      final senderId = ref.read(authProvider).user?.id;
      final sent = await sendInteractionFromUi(
        context,
        ref,
        target: user,
        type: type,
        requireIcebreaker: false,
        source: InteractionSource.kissMeNow,
      );
      if (!sent || senderId == null || !mounted) return;
      await ref
          .read(chatControllerProvider)
          .sendText(
            conversationIdFor(senderId, user.id),
            senderId,
            type.chatMessage,
          );
      if (!mounted) return;
      setState(() {
        _done.add(user.id);
        _selected = 0;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationPage(
            peerId: user.id,
            peerName: user.name,
            peerPhotoUrl: user.photoUrl,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível enviar a mensagem: $error')),
        );
    } finally {
      _isSending = false;
    }
  }
}

class _TableCard extends StatelessWidget {
  final UserEntity user;
  final bool selected;
  final VoidCallback onTap;

  const _TableCard({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: selected ? 0 : 22,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(selected ? 60 : 25),
              blurRadius: selected ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                user.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black26,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(190)],
                    stops: const [0.55, 1],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  user.name.split(',').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
