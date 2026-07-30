import 'package:flutter/material.dart';

class PrivacySafeIndicator extends StatelessWidget {
  const PrivacySafeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPrivacyPolicy(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.withAlpha(30)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_person_rounded, color: Colors.green, size: 16),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Sua intimidade não é mercadoria. Seus dados estão blindados contra terceiros.",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.green.withAlpha(100), size: 18),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Base Teórica: Privacidade Institucional (Lutz, 2017)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Blindagem Kiss Me",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            const Text(
              "Combatemos a datificação da intimidade através de 3 camadas de proteção:",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildFeature(Icons.gps_fixed_rounded, "GPS Aproximado", "Nunca revelamos sua localização exata para a plataforma ou terceiros."),
            _buildFeature(Icons.auto_delete_rounded, "Efemeridade", "Seus gestos e mensagens são usados apenas para o match e deletados em seguida."),
            _buildFeature(Icons.block_rounded, "Zero Terceiros", "Não vendemos seus dados comportamentais para anunciantes."),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Privacidade Garantida"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
