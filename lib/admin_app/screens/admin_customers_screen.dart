import 'package:flutter/material.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  // THEME COLORS
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);

  // Dummy Customer List
  List<Map<String, dynamic>> customers = [
    {
      "name": "Ali Raza",
      "email": "ali@gmail.com",
      "password": "12345",
      "contact": "03001234567",
      "address": "Lahore"
    },
    {
      "name": "Hina Khan",
      "email": "hina@gmail.com",
      "password": "abcd",
      "contact": "03007654321",
      "address": "Islamabad"
    }
  ];

  // Text Controllers
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _address = TextEditingController();

  // Open Add / Edit Dialog
  void openCustomerDialog({Map<String, dynamic>? data, int? index}) {
    bool isEdit = data != null;

    if (isEdit) {
      _name.text = data["name"];
      _email.text = data["email"];
      _password.text = data["password"];
      _contact.text = data["contact"];
      _address.text = data["address"];
    } else {
      _name.clear();
      _email.clear();
      _password.clear();
      _contact.clear();
      _address.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: gold, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    isEdit ? "Update Customer" : "Add Customer",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FORM FIELDS
                  customField("Full Name", _name),
                  customField("Email", _email),
                  customField("Password", _password, obscure: true),
                  customField("Contact Number", _contact),
                  customField("Address", _address),

                  const SizedBox(height: 25),

                  // SAVE BUTTON
                  ElevatedButton(
                    onPressed: () {
                      if (_name.text.isEmpty ||
                          _email.text.isEmpty ||
                          _password.text.isEmpty ||
                          _contact.text.isEmpty ||
                          _address.text.isEmpty) {
                        return;
                      }

                      if (isEdit) {
                        customers[index!] = {
                          "name": _name.text,
                          "email": _email.text,
                          "password": _password.text,
                          "contact": _contact.text,
                          "address": _address.text,
                        };
                      } else {
                        customers.add({
                          "name": _name.text,
                          "email": _email.text,
                          "password": _password.text,
                          "contact": _contact.text,
                          "address": _address.text,
                        });
                      }

                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: navy, width: 2),
                      ),
                    ),
                    child: Text(
                      isEdit ? "Update" : "Add",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Custom TextField UI
  Widget customField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [background, extraGold.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          "Customers",
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: navy),
      ),

      // BODY
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final c = customers[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: navy.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              title: Text(
                c["name"],
                style: TextStyle(
                  color: navy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Email: ${c["email"]}\nContact: ${c["contact"]}\nAddress: ${c["address"]}",
                style: TextStyle(color: navy.withOpacity(0.8)),
              ),

              // ACTION BUTTONS
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EDIT
                  IconButton(
                    icon: Icon(Icons.edit, color: gold),
                    onPressed: () {
                      openCustomerDialog(data: c, index: index);
                    },
                  ),

                  // DELETE
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      customers.removeAt(index);
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),

      // ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(color: navy, width: 2),
        ),
        onPressed: () => openCustomerDialog(),
        child: Icon(Icons.add, color: navy, size: 28),
      ),
    );
  }
}
