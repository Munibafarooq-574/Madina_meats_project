import 'package:flutter/material.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD4AF37);
  final Color background = const Color(0xFFF8F5E8);

  List<Map<String, String>> drivers = [
    {
      "name": "Ali Raza",
      "email": "ali@gmail.com",
      "phone": "03001234567",
      "password": "12345",
    },
    {
      "name": "Hamza Khan",
      "email": "hamza@gmail.com",
      "phone": "03017654321",
      "password": "driver123",
    },
  ];

  // ADD + EDIT POPUP
  void _showDriverDialog({Map<String, String>? driver, int? index}) {
    TextEditingController nameCtrl =
    TextEditingController(text: driver?["name"] ?? "");
    TextEditingController emailCtrl =
    TextEditingController(text: driver?["email"] ?? "");
    TextEditingController phoneCtrl =
    TextEditingController(text: driver?["phone"] ?? "");
    TextEditingController passCtrl =
    TextEditingController(text: driver?["password"] ?? "");

    bool isEdit = driver != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: gold, width: 2),
          ),
          title: Text(
            isEdit ? "Update Driver" : "Add Driver",
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField("Driver Name", nameCtrl),
              const SizedBox(height: 10),
              _buildField("Email", emailCtrl),
              const SizedBox(height: 10),
              _buildField("Phone Number", phoneCtrl),
              const SizedBox(height: 10),
              _buildField("Password", passCtrl),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: navy)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (isEdit) {
                  setState(() {
                    drivers[index!] = {
                      "name": nameCtrl.text,
                      "email": emailCtrl.text,
                      "phone": phoneCtrl.text,
                      "password": passCtrl.text,
                    };
                  });
                } else {
                  setState(() {
                    drivers.add({
                      "name": nameCtrl.text,
                      "email": emailCtrl.text,
                      "phone": phoneCtrl.text,
                      "password": passCtrl.text,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  // DELETE POPUP
  void _deleteDriver(int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: gold)),
          title: Text(
            "Delete Driver?",
            style: TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: navy)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),
              onPressed: () {
                setState(() => drivers.removeAt(index));
                Navigator.pop(ctx);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // CUSTOM FIELD
  Widget _buildField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: navy),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: gold, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ⭐ NEW APPBAR WITH SAME BACK BUTTON STYLE
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy, size: 26),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          "Drivers Management",
          style: TextStyle(
            color: navy,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        child: Icon(Icons.add, color: navy),
        onPressed: () => _showDriverDialog(),
      ),

      // ⭐ REMOVED OLD CUSTOM BACK BUTTON ROW
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final d = drivers[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: Row(
              children: [
                // ICON
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.person, color: navy, size: 30),
                ),

                const SizedBox(width: 15),

                // TEXT INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d["name"]!,
                        style: TextStyle(
                          fontSize: 21,
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Email: ${d['email']}"),
                      Text("Phone: ${d['phone']}"),
                      Text("Password: ${d['password']}"),
                    ],
                  ),
                ),

                // ACTION BUTTONS
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: navy, size: 26),
                      onPressed: () =>
                          _showDriverDialog(driver: d, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red, size: 26),
                      onPressed: () => _deleteDriver(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
