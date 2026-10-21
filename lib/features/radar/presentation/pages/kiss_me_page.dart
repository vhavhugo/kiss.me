import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/radar_search_provider.dart';
import '../widgets/profile_detail_view.dart';
import '../widgets/action_button.dart';
import '../widgets/interaction_actions.dart';
import '../widgets/dissolving_km_animation.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../widgets/ai_trust_system.dart';
import '../../../profile/presentation/widgets/verified_seal.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_items_provider.dart';
import '../../../safety/presentation/providers/safety_provider.dart';
import '../../../../features/privacy/presentation/widgets/privacy_safe_indicator.dart';
import '../../../../features/gamification/presentation/widgets/gamification_progress_bar.dart';

class KissMePage extends ConsumerStatefulWidget {
  const KissMePage({super.key});

  @override
  ConsumerState<KissMePage> createState() => _KissMePageState();
}

class _KissMePageState extends ConsumerState<KissMePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isSending = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garante que a busca comece imediatamente se estiver online
      final authState = ref.read(authProvider);
      if (authState.isOnline) {
        ref
            .read(radarSearchProvider.notifier)
            .startSearch(authState.user!.id, -23.5505, -46.6333);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final blocked = ref.watch(blockedUsersProvider);
    final rawSearch = ref.watch(radarSearchProvider);
    final searchState = rawSearch.copyWith(
      users: rawSearch.users.where((u) => !blocked.contains(u.id)).toList(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kiss Me",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -1,
          ),
        ),
        centerTitle: true,
        leading: _buildStatusToggle(authState),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unread = ref.watch(unreadNotificationsCountProvider);
              return IconButton(
                tooltip: 'Notificações',
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text(unread > 99 ? '99+' : '$unread'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: VerifiedSeal()),
          ),
        ],
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
          ref
              .read(radarSearchProvider.notifier)
              .startSearch(newAuthState.user!.id, -23.5505, -46.6333);
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
        key: const ValueKey('searching_content_km'),
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DissolvingKmAnimation(radiusKm: 0.0),
                  const SizedBox(height: 30),
                  const AiTrustSystem(
                    localJustification:
                        "Encontrando conexões reais baseadas na sua essência.",
                    score: 0.0,
                  ),
                  const SizedBox(height: 10),
                  const PrivacySafeIndicator(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: GamificationProgressBar(
                      progress: 0.85,
                      label: "MAGNETISMO PESSOAL",
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    !auth.isOnline
                        ? "Você está offline"
                        : "Expandindo o Radar...",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Column(
      key: const ValueKey('results_content_km'),
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => _currentIndex = i,
                itemCount: search.users.length,
                itemBuilder: (context, index) {
                  return ProfileDetailView(
                    key: PageStorageKey('profile_${search.users[index].id}'),
                    user: search.users[index],
                    heroHeight: constraints.maxHeight,
                  );
                },
              );
            },
          ),
        ),
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: SafeArea(
            top: false,
            child: _buildActionButtonsRow(search.users),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsRow(List<UserEntity> users) {
    UserEntity? current() =>
        _currentIndex < users.length ? users[_currentIndex] : null;
    Future<void> send(ActionType type) async {
      if (_isSending) return;
      _isSending = true;
      try {
        final sent = await sendInteractionFromUi(
          context,
          ref,
          target: current(),
          type: type,
          requireIcebreaker: false,
        );
        if (!sent || !mounted || !_pageController.hasClients) return;
        if (_currentIndex + 1 < users.length) {
          await _pageController.nextPage(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não há mais pessoas por perto agora.'),
            ),
          );
        }
      } finally {
        _isSending = false;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(type: ActionType.kiss, onTap: () => send(ActionType.kiss)),
        ActionButton(type: ActionType.hug, onTap: () => send(ActionType.hug)),
        ActionButton(
          type: ActionType.handshake,
          onTap: () => send(ActionType.handshake),
        ),
        ActionButton(type: ActionType.walk, onTap: () => send(ActionType.walk)),
      ],
    );
  }
}
