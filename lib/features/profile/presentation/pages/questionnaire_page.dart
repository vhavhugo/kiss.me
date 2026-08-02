import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  // Dados locais para evitar erros de importação e garantir funcionamento imediato
  final List<Map<String, String>> _questions = [
    {"question": "Você ficaria comigo?", "icon": "💋"},
    {"question": "Você sonha em casar?", "icon": "💍"},
    {"question": "Qual o seu hobby principal?", "icon": "🎨"},
    {"question": "Qual seu tipo de filme predileto?", "icon": "🎬"},
    {"question": "Você pratica esportes?", "icon": "⚽"},
    {"question": "Qual sua viagem dos sonhos?", "icon": "✈️"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Caderno de Perguntas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final q = _questions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(q["icon"]!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q["question"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Escreva sua resposta aqui...",
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text("SALVAR NO CADERNO", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
