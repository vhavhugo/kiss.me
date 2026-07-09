import 'package:flutter/material.dart';
import 'features/radar/presentation/pages/radar_page.dart';

void main() {
  runApp(const KissMeApp());
}

class KissMeApp extends StatelessWidget {
  const KissMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiss-me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Pode ser substituída por uma fonte mais moderna
      ),
      home: const RadarPage(),
    );
  }
}
