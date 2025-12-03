import 'package:flutter/material.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  final Color navy = const Color(0xFF2C3E50);
  final Color gold = const Color(0xFFD4AF37);
  final Color extraGold = const Color(0xFFEEDC82);

  TextEditingController searchCtrl = TextEditingController();

  List<Map<String, dynamic>> drivers = [
    {
      "name": "Ali Raza",
      "email": "ali@gmail.com",
      "password": "123456",
      "phone": "03001234567",
    },
    {
      "name": "Hamza Khan",
      "email": "hamza@gmail.com",
      "password": "driver123",
      "phone": "03017654321",
    },
  ];

  List<Map<String, dynamic>> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = List.from(drivers);
    searchCtrl.addListener(filterData);
  }

  void filterData() {
    String q = searchCtrl.text.toLowerCase();

    setState(() {
      filtered = drivers.where((d) {
        return d["name"].toLowerCase().contains(q) ||
            d["email"].toLowerCase().contains(q) ||
            d["phone"].toLowerCase().contains(q) ||
            d["password"].toLowerCase().contains(q);
      }).toList();
    });
  }

  // ----------------------------------------------------------
  // ADD / EDIT DRIVER DIALOG
  // ----------------------------------------------------------
  void openDriverDialog({Map<String, dynamic>? data, int? index}) {
    TextEditingController nameC = TextEditingController(text: data?["name"]);
    TextEditingController emailC = TextEditingController(text: data?["email"]);
    TextEditingController pwdC =
    TextEditingController(text: data?["password"]);
    TextEditingController phoneC = TextEditingController(text: data?["phone"]);

    ValueNotifier<bool> isValid = ValueNotifier(false);

    void validate() {
      isValid.value = nameC.text.isNotEmpty &&
          emailC.text.isNotEmpty &&
          pwdC.text.isNotEmpty &&
          phoneC.text.isNotEmpty;
    }

    nameC.addListener(validate);
    emailC.addListener(validate);
    pwdC.addListener(validate);
    phoneC.addListener(validate);
    validate();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            data == null ? "Add Driver" : "Edit Driver",
            style: TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                textField("Driver Name", nameC),
                const SizedBox(height: 10),
                textField("Email", emailC),
                const SizedBox(height: 10),
                textField("Password", pwdC),
                const SizedBox(height: 10),
                textField("Phone Number", phoneC),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ValueListenableBuilder(
              valueListenable: isValid,
              builder: (_, valid, __) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: valid ? navy : Colors.grey,
                      foregroundColor: Colors.white),
                  onPressed: valid
                      ? () {
                    if (data == null) {
                      drivers.add({
                        "name": nameC.text,
                        "email": emailC.text,
                        "password": pwdC.text,
                        "phone": phoneC.text,
                      });
                    } else {
                      drivers[index!] = {
                        "name": nameC.text,
                        "email": emailC.text,
                        "password": pwdC.text,
                        "phone": phoneC.text,
                      };
                    }

                    filterData();
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text("Save"),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // DELETE DRIVER
  // ----------------------------------------------------------
  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Driver"),
        content: const Text("Are you sure you want to delete this driver?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF344955),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              drivers.removeAt(index);
              filterData();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CUSTOM TEXT FIELD WIDGET
  // ----------------------------------------------------------
  Widget textField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold),
        ),
      ),
    );
  }

  Widget textRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: navy),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Driver Management",
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------
          // NEW "ADD DRIVER" BUTTON (Create Order Style)
          // ---------------------------------------
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6C28F),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Driver",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => openDriverDialog(),
              ),
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search drivers...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                var d = filtered[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    border: Border.all(color: gold, width: 1.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22)),
                          gradient: LinearGradient(
                            colors: [
                              extraGold.withOpacity(0.5),
                              Colors.white
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: navy, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              d["name"],
                              style: TextStyle(
                                color: navy,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textRow("Email", d["email"]),
                            textRow("Password", d["password"]),
                            textRow("Phone", d["phone"]),
                          ],
                        ),
                      ),

                      Divider(color: gold),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: navy),
                            onPressed: () =>
                                openDriverDialog(data: d, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDelete(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
