import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/radar_search_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_button.dart';
import '../widgets/dissolving_km_animation.dart';
import '../../domain/entities/interaction_entity.dart';

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
    // Inicia a busca automaticamente ao carregar a tela
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
      appBar: AppBar(
        title: const Text("Kiss Me",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            ref.read(authProvider.notifier).toggleOnlineStatus();
            final newAuthState = ref.read(authProvider);
            if (newAuthState.isOnline) {
              // Inicia do zero
              ref.read(radarSearchProvider.notifier).startSearch(-23.5505, -46.6333);
            } else {
              // Para e ativa efeito Offline
              ref.read(radarSearchProvider.notifier).stopSearch();
            }
          },
          child: Tooltip(
            message: authState.isOnline ? "Você está On-line" : "Você está Off-line",
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: authState.isOnline ? Colors.green : Colors.grey,
                radius: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: authState.isOnline
                        ? [BoxShadow(color: Colors.green.withAlpha(100), blurRadius: 10, spreadRadius: 2)]
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _buildMainContent(authState, searchState),
      ),
    );
  }

  Widget _buildMainContent(AuthState auth, RadarSearchState search) {
    // Regra: Se Offline ou se estiver buscando (sem usuários encontrados ainda)
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
                  DissolvingKmAnimation(radiusKm: search.currentRadiusKm),
                  const SizedBox(height: 20),
                  Text(
                    !auth.isOnline ? "Fique On-line para buscar" : "Expandindo radar...",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Regra: Se Online e encontrou os pretendentes
    return LayoutBuilder(
      key: const ValueKey('results_content'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Encontramos alguém!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Raio: ${search.currentRadiusKm.toStringAsFixed(1)}km",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.6, // Limita altura do PageView
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: search.users.length,
                      itemBuilder: (context, index) {
                        return ProfileCard(user: search.users[index]);
                      },
                    ),
                  ),
                  const Spacer(), // Empurra botões para baixo
                  const SizedBox(height: 20),
                  // Os botões agora aparecem junto com as cartas dentro do estado "encontrado"
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: _buildActionButtons(),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
      ),
    );
  }

  void _handleAction(ActionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pergunta quebra-gelo:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Qual o seu encontro ideal?",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Sua resposta criativa...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getActionColor(type),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Enviar ${_getActionEmoji(type)}"),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(ActionType type) {
    switch (type) {
      case ActionType.kiss: return Colors.pink;
      case ActionType.hug: return Colors.blue;
      case ActionType.handshake: return Colors.orange;
      case ActionType.drink: return Colors.purple;
    }
  }

  String _getActionEmoji(ActionType type) {
    switch (type) {
      case ActionType.kiss: return "💋";
      case ActionType.hug: return "🫂";
      case ActionType.handshake: return "🤝";
      case ActionType.drink: return "🥂";
    }
  }
}
