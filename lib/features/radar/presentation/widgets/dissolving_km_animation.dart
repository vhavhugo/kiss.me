import 'package:flutter/material.dart';

class DissolvingKmAnimation extends StatefulWidget {
  final double radiusKm;

  const DissolvingKmAnimation({super.key, required this.radiusKm});

  @override
  State<DissolvingKmAnimation> createState() => _DissolvingKmAnimationState();
}

class _DissolvingKmAnimationState extends State<DissolvingKmAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String distanceText = widget.radiusKm < 1.0
        ? '${(widget.radiusKm * 1000).toInt()}m'
        : '${widget.radiusKm.toStringAsFixed(1)}km';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo pulsante de busca
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 200 * _scaleAnimation.value,
                height: 200 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.pink.withAlpha((_opacityAnimation.value * 255).toInt()),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // Texto do KM dissolvendo
          FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                distanceText,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ),
          // Radar Icon fixo no centro
          const Icon(Icons.radar, size: 40, color: Colors.pink),
        ],
      ),
    );
  }
}
