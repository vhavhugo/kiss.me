import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF06292); 
  static const Color secondary = Color(0xFFFF8A65); 
  static const Color background = Color(0xFFFAFAFA); 
  static const Color surface = Colors.white;
  
  static const Color actionKiss = Color(0xFFFF4081);
  static const Color actionHug = Color(0xFF64B5F6);
  static const Color actionHandshake = Color(0xFFFFB74D);
  static const Color actionDate = Color(0xFF9575CD);
  
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFFBDBDBD);
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
