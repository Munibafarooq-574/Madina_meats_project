import 'package:flutter/material.dart';
import 'package:madina_meats/core/constants/app_images.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5E8), // soft off-white

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // TOP LOGO
            Image.asset(
              AppImages.logo,
              width: 160,
              height: 160,
            ),

            const SizedBox(height: 20),

            // MAIN HEADING
            const Text(
              "Welcome to Madina Meats",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344955), // navy blue
              ),
            ),

            const SizedBox(height: 15),

            // INTRO LINES
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Premium quality, hygienic and farm-fresh meat.\n"
                    "Delivered with honesty, care and trust.\n"
                    "Your trusted halal meat partner.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF344955), // navy
                ),
              ),
            ),

            const SizedBox(height: 45),

            // Animated Get Started Button
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 700),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/selectApp");
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6C28F), // GOLD BUTTON
                  foregroundColor: Colors.black, // white text for premium look
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(
                      color: Color(0xFF344955), // navy border
                      width: 2,
                    ),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF344955),
                ).copyWith(
                  overlayColor: const MaterialStatePropertyAll(
                    Color(0xFF344955), // NAVY BLUE when pressed
                  ),
                ),

                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
