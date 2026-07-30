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

class RadarPage extends ConsumerStatefulWidget {
  const RadarPage({super.key});

  @override
  ConsumerState<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends ConsumerState<RadarPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                    localJustification: "Fique on-line para que nossa tecnologia encontre afinidades baseadas em seus interesses reais.",
                    score: 0.0,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    !auth.isOnline ? "Você está invisível" : "Procurando conexões reais...",
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

    return LayoutBuilder(
      key: const ValueKey('results_content'),
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
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: _buildActionButtonsRow(),
                        ),
                      );
                    },
                  ),
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
          onTap: () => _handleAction(ActionType.handshake),
        ),
        ActionButton(
          type: ActionType.hug,
          onTap: () => _handleAction(ActionType.hug),
        ),
        ActionButton(
          type: ActionType.kiss,
          onTap: () => _handleAction(ActionType.kiss),
        ),
        ActionButton(
          type: ActionType.drink,
          onTap: () => _handleAction(ActionType.drink),
        ),
      ],
    );
  }

  void _handleAction(ActionType type) {
    // Modal implementation
  }
}
