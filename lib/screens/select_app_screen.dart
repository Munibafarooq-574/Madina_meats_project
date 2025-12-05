import 'package:flutter/material.dart';
import 'package:madina_meats/core/constants/app_images.dart';


class SelectAppScreen extends StatelessWidget {
  const SelectAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("SCREEN LOADED 🌟");
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5E8), // soft off-white

      appBar: AppBar(
        backgroundColor: const Color(0xFF344955), // navy blue
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Select Application",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // LOGO
            Image.asset(
              AppImages.logo,
              width: 130,
              height: 130,
            ),

            const SizedBox(height: 25),

            // Heading
            const Text(
              "Choose Your App Access",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF344955), // navy
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Continue to your respective application dashboard.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF344955),
              ),
            ),

            const SizedBox(height: 40),

            // BUTTONS

            buildButton(
              context,
              icon: Icons.admin_panel_settings,
              text: "Admin App",
              route: "/admin_login",   // FIXED
            ),

            const SizedBox(height: 20),

            buildButton(
              context,
              icon: Icons.local_shipping_rounded,
              text: "Driver App",
              route: "/driver_login",  // FIXED
            ),

            const SizedBox(height: 20),

            buildButton(
              context,
              icon: Icons.person_pin_circle_rounded,
              text: "Customer App",
              route: "/customer_login", // FIXED
            ),

          ],
        ),
      ),
    );
  }

  // CUSTOM BUTTON WIDGET
  Widget buildButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required String route,
      }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD6C28F), // GOLD
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
              Color(0xFF344955), // NAVY on pressed
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Colors.black),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
