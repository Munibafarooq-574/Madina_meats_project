import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // APP COLORS (THEME)
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ⭐ APPBAR WITH GRADIENT
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [background, extraGold.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ⭐ BACKGROUND GRADIENT
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [background, extraGold.withOpacity(0.3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [

                  // 👑 ADMIN ICON
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 90,
                    color: navy,
                  ),

                  const SizedBox(height: 10),

                  // TITLE
                  Text(
                    "Admin Login",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: navy,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ⭐ LOGIN CARD
                  Container(
                    padding: const EdgeInsets.all(30),

                    constraints: const BoxConstraints(
                      minHeight: 400,
                      minWidth: double.infinity,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withOpacity(0.20),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: gold, width: 1.3),
                    ),

                    child: Form(
                      key: _formKey,
                      child: Column(

                        // ⭐ CENTER EVERYTHING
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [

                          // USERNAME
                          TextFormField(
                            controller: _username,
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: navy),
                              prefixIcon: Icon(Icons.person, color: navy),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold, width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) =>
                            v!.isEmpty ? "Enter username" : null,
                          ),

                          const SizedBox(height: 30),

                          // PASSWORD
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: navy),
                              prefixIcon: Icon(Icons.lock, color: navy),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: navy,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold, width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) =>
                            v!.isEmpty ? "Enter password" : null,
                          ),

                          const SizedBox(height: 40),

                          // ⭐ LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () {
                                if (_formKey.currentState!.validate()) {
                                  print("ADMIN LOGIN PRESSED");
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: navy, width: 2),
                                ),
                                elevation: 10,
                                shadowColor: extraGold,
                              ).copyWith(
                                overlayColor:
                                MaterialStateProperty.all(navy),
                              ),

                              child: _loading
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
