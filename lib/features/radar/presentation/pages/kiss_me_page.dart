import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/radar_search_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_button.dart';
import '../widgets/dissolving_km_animation.dart';
import '../../domain/entities/interaction_entity.dart';
import '../widgets/ai_trust_system.dart';
import '../../../../features/privacy/presentation/widgets/privacy_safe_indicator.dart';
import '../../../../features/gamification/presentation/widgets/gamification_progress_bar.dart';

class KissMePage extends ConsumerStatefulWidget {
  const KissMePage({super.key});

  @override
  ConsumerState<KissMePage> createState() => _KissMePageState();
}

class _KissMePageState extends ConsumerState<KissMePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garante que a busca comece imediatamente se estiver online
      final authState = ref.read(authProvider);
      if (authState.isOnline) {
        ref.read(radarSearchProvider.notifier).startSearch(-23.5505, -46.6333);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final searchState = ref.watch(radarSearchProvider);

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
          ref.read(radarSearchProvider.notifier).startSearch(-23.5505, -46.6333);
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
                    )
                  ]
                : [],
          ),
          child: Icon(
            auth.isOnline ? Icons.radar_rounded : Icons.power_settings_new_rounded,
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
                    localJustification: "Encontrando conexões reais baseadas na sua essência.",
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
                    !auth.isOnline ? "Você está offline" : "Expandindo o Radar...",
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

    return LayoutBuilder(
      key: const ValueKey('results_content_km'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: constraints.maxHeight * 0.65,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: search.users.length,
                      itemBuilder: (context, index) {
                        return ProfileCard(user: search.users[index]);
                      },
                    ),
                  ),
                  const Spacer(),
                  _buildActionButtonsRow(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
          type: ActionType.handshake,
          onTap: () {},
        ),
        ActionButton(
          type: ActionType.hug,
          onTap: () {},
        ),
        ActionButton(
          type: ActionType.kiss,
          onTap: () {},
        ),
        ActionButton(
          type: ActionType.drink,
          onTap: () {},
        ),
      ],
    );
  }
}
