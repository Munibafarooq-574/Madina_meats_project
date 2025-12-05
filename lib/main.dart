import 'package:flutter/material.dart';
import 'admin_app/screens/admin_login_screen.dart';
import 'driver_app/screens/driver_login_screen.dart';
import 'customer_app/screens/customer_login_screen.dart';
import 'core/splash/common_splash.dart';
import 'screens/get_started_screen.dart';
import 'screens/select_app_screen.dart';
void main() {
  runApp(const MadinaMeatsApp());
}

class MadinaMeatsApp extends StatelessWidget {
  const MadinaMeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (_) => const CommonSplashScreen(nextRoute: "/getStarted"),
        "/getStarted": (_) => const GetStartedScreen(),
        "/selectApp": (_) => const SelectAppScreen(),

        "/admin_login": (_) => const AdminLoginScreen(),
        "/driver_login": (_) => const DriverLoginScreen(),
        "/customer_login": (_) => const CustomerLoginScreen(),
      },
    );
  }
}

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin_login'),
              child: const Text("Admin App"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/driver_login'),
              child: const Text("Driver App"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/customer_login'),
              child: const Text("Customer App"),
            ),
          ],
        ),
      ),
    );
  }
}
