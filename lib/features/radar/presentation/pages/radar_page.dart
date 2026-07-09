import 'package:flutter/material.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_button.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Dados fictícios para visualização inicial
  final List<UserEntity> _dummyUsers = [
    UserEntity(
      id: '1',
      name: 'Julia',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      distanceInMeters: 350,
      bio: 'Amo café e viagens inesperadas.',
      icebreakers: [],
    ),
    UserEntity(
      id: '2',
      name: 'Marcos',
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
      distanceInMeters: 120,
      bio: 'Músico nas horas vagas.',
      icebreakers: [],
    ),
    UserEntity(
      id: '3',
      name: 'Beatriz',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      distanceInMeters: 500,
      bio: 'Design e vinhos.',
      icebreakers: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiss-me", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Alguém especial está por perto...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _dummyUsers.length,
              itemBuilder: (context, index) {
                return ProfileCard(user: _dummyUsers[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
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
