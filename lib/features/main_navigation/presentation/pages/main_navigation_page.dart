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
import '../../../notifications/presentation/pages/notifications_page.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 0; // Começa na nova tela 'Kiss Me'

  final List<Widget> _pages = [
    const KissMePage(), // 1ª posição: Kiss Me (Antigo Perfil)
    const RadarPage(),  // 2ª posição: Kiss Me Now
    const ChatPage(),
    const SettingsPage(), // 4ª posição: Ajustes (com perfil dentro)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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
          onTap: (index) => setState(() => _selectedIndex = index),
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
            leading: CircleAvatar(
              backgroundImage: photo == null ? null : MemoryImage(photo),
              child: photo == null ? const Icon(Icons.person) : null,
            ),
            title: const Text("Meu Perfil"),
            subtitle: const Text("Editar fotos e bio"),
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
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("Notificações"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text("Privacidade"),
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
