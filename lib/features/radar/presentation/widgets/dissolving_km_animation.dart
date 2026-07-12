import 'package:flutter/material.dart';

class DissolvingKmAnimation extends StatefulWidget {
  final double radiusKm;

  const DissolvingKmAnimation({super.key, required this.radiusKm});

  @override
  State<DissolvingKmAnimation> createState() => _DissolvingKmAnimationState();
}

class _DissolvingKmAnimationState extends State<DissolvingKmAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    
    // Controlador para o pulso das ondas de radar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Controlador para a rotação suave do gradiente
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de exibição elegante: metros se < 1km, km se >= 1km
    final bool isMeters = widget.radiusKm < 1.0;
    final String unit = isMeters ? 'm' : 'km';
    final String value = isMeters 
        ? (widget.radiusKm * 1000).toInt().toString() 
        : widget.radiusKm.toStringAsFixed(1);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ondas de Radar pulsantes e elegantes
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                double progress = (_pulseController.value + index / 3) % 1.0;
                return Container(
                  width: 300 * progress,
                  height: 300 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.pink.withAlpha((255 * (1 - progress)).toInt()),
                      width: 1.5,
                    ),
                  ),
                );
              },
            );
          }),

          // Brilho central rotativo
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.pink.withAlpha(0),
                    Colors.pink.withAlpha(150),
                    Colors.pink.withAlpha(0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Container do Texto (O "KM" ou "M" que dissolve)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.pink,
                  letterSpacing: -2,
                ),
                child: Text(value),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.pink.withAlpha(180),
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          
          // Ícone de busca sutil
          Positioned(
            bottom: -40,
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.pink.withAlpha(50),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
