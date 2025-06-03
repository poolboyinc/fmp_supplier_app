// lib/features/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Creative animated logo using Lottie
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/party_pulse.json', // You'll need to add this animation
                repeat: true,
              ),
            ),
            const SizedBox(height: 24),

            // Glowing app name with animated gradient
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    AppTheme.accentPink,
                    AppTheme.primaryPurple,
                    AppTheme.accentBlue,
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: const Text(
                'FMP SUPPLIER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Manage your parties effortlessly',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
            ),

            const SizedBox(height: 48),

            // Animated pulse loading indicator
            SizedBox(width: 40, height: 40, child: _PulsingCircleAnimation()),
          ],
        ),
      ),
    );
  }
}

// Custom animated loading indicator
class _PulsingCircleAnimation extends StatefulWidget {
  @override
  _PulsingCircleAnimationState createState() => _PulsingCircleAnimationState();
}

class _PulsingCircleAnimationState extends State<_PulsingCircleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 40 * _animation.value,
          height: 40 * _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryPurple.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryPurple.withOpacity(_animation.value),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
