import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../radar/presentation/pages/radar_page.dart';
import '../../../radar/presentation/pages/kiss_me_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';

import '../../../profile/presentation/pages/questionnaire_page.dart';
import '../../../profile/presentation/pages/my_profile_page.dart';
import '../../../profile/presentation/providers/profile_photo_provider.dart';
import '../../../profile/presentation/providers/verification_provider.dart';
import '../../../profile/presentation/widgets/verified_seal.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../privacy/presentation/pages/privacy_page.dart';
import '../../../notifications/presentation/providers/notification_items_provider.dart';
import '../../../notifications/presentation/providers/notification_state_provider.dart';
import '../../../radar/presentation/providers/interactions_provider.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 0; // Começa na nova tela 'Kiss Me'

  // Mudar a chave recria a mesa e começa um jogo novo.
  int _gameId = 0;

  final _kissMe = const KissMePage();
  final _chat = const ChatPage();
  final _settings = const SettingsPage();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      Future.microtask(() {
        ref.read(interactionsProvider.notifier).load(user.id);
        ref.read(notificationStateProvider.notifier).load(user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _kissMe,
          RadarPage(key: ValueKey(_gameId)),
          _chat,
          _settings,
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
            if (index == 1) _gameId++;
            _selectedIndex = index;
          }),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.offline,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Kiss Me',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_motion_rounded),
              activeIcon: Icon(Icons.auto_awesome_motion_rounded),
              label: 'Kiss Me Now',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget simples para representar a tela de Ajustes com Perfil
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(profilePhotoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: [
          ListTile(
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundImage: photo == null ? null : MemoryImage(photo),
                  child: photo == null ? const Icon(Icons.person) : null,
                ),
                if (ref.watch(verificationProvider))
                  const Positioned(
                    right: -4,
                    bottom: -4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: VerifiedSeal(size: 18),
                    ),
                  ),
              ],
            ),
            title: const Text("Meu Perfil"),
            subtitle: Text(ref.watch(verificationProvider)
                ? "Perfil verificado"
                : "Editar fotos e bio"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfilePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Builder(builder: (_) {
              final unread = ref.watch(unreadNotificationsCountProvider);
              return Badge(
                isLabelVisible: unread > 0,
                label: Text(unread > 99 ? '99+' : '$unread'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.notifications_outlined),
              );
            }),
            title: const Text("Notificações"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text("Privacidade"),
            subtitle: const Text("Localização, distância e mensagens"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPage()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
            title: const Text("Caderno de Perguntas"),
            subtitle: const Text("O que temos em comum?"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuestionnairePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text("Sair da conta", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
