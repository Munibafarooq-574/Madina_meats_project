import 'package:flutter/material.dart';
import '../constants/app_images.dart';
import '../constants/app_strings.dart';

class CommonSplashScreen extends StatefulWidget {
  final String nextRoute;
  const CommonSplashScreen({super.key, required this.nextRoute});

  @override
  State<CommonSplashScreen> createState() => _CommonSplashScreenState();
}

class _CommonSplashScreenState extends State<CommonSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeTextAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // LOGO SLIDE ANIMATION
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-1.5, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(Offset.zero),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(1.5, 0))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // LOGO SCALE ANIMATION
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // SLOGAN FADE IN + FADE OUT (SYNCED WITH LOGO)
    _fadeTextAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40, // fade in
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 20, // stay visible
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40, // fade out with logo
      ),
    ]).animate(_controller);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  AppImages.logo,
                  width: 200,
                  height: 200,
                ),
              ),
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: _fadeTextAnimation,
              child: Text(
                AppStrings.slogan,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
