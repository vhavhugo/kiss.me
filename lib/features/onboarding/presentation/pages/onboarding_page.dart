import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "Como você se identifica?",
      options: ["Homem", "Mulher", "Não-binário"],
    ),
    OnboardingStep(
      title: "Quem você quer encontrar?",
      options: ["Homens", "Mulheres", "Todos"],
    ),
    OnboardingStep(
      title: "Qual seu objetivo?",
      options: ["Algo sério", "Amizade", "Ver no que dá"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _steps.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  return _buildStep(_steps[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            step.title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ...step.options.map((option) => _OptionButton(
                label: option,
                onTap: _nextPage,
              )),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Save onboarding data and navigate to Radar
      Navigator.of(context).pushReplacementNamed('/radar');
    }
  }
}

class OnboardingStep {
  final String title;
  final List<String> options;
  OnboardingStep({required this.title, required this.options});
}

class _OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
