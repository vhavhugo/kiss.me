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
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.radiusKm > 0) {
      _pulseController.repeat();
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(DissolvingKmAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.radiusKm > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat();
      _rotationController.repeat();
    } else if (widget.radiusKm == 0) {
      _pulseController.stop();
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se o raio for 0 ou muito pequeno (Offline), mostra efeito de desativado
    final bool isOffline = widget.radiusKm <= 0.1;
    
    final bool isMeters = widget.radiusKm < 1.0;
    final String unit = isOffline ? "" : (isMeters ? 'm' : 'km');
    final String value = isOffline 
        ? "Radar Off" 
        : (isMeters 
            ? (widget.radiusKm * 1000).toInt().toString() 
            : widget.radiusKm.toStringAsFixed(1));

    final Color themeColor = isOffline ? Colors.grey : Colors.pink;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ondas de Radar pulsantes e elegantes
          if (!isOffline)
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
                        color: themeColor.withAlpha((255 * (1 - progress)).toInt()),
                        width: 1.5,
                      ),
                    ),
                  );
                },
              );
            }),

          // Brilho central rotativo (desativado se offline)
          if (!isOffline)
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      themeColor.withAlpha(0),
                      themeColor.withAlpha(150),
                      themeColor.withAlpha(0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            )
          else
            // Efeito de círculo cinza estático para Offline
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withAlpha(50), width: 2),
              ),
            ),

          // Container do Texto
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  fontSize: isOffline ? 32 : 64,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                  letterSpacing: isOffline ? 0 : -2,
                ),
                child: Text(value),
              ),
              if (!isOffline)
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: themeColor.withAlpha(180),
                    letterSpacing: 4,
                  ),
                ),
            ],
          ),
          
          Positioned(
            bottom: -40,
            child: Icon(
              isOffline ? Icons.radar_outlined : Icons.favorite_rounded,
              color: themeColor.withAlpha(50),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
