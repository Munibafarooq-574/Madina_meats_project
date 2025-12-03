import 'package:flutter/material.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final Color navy = const Color(0xFF2C3E50);
  final Color gold = const Color(0xFFD4AF37);
  final Color extraGold = const Color(0xFFEEDC82);

  TextEditingController searchCtrl = TextEditingController();

  List<Map<String, dynamic>> customers = [
    {
      "name": "Ali Raza",
      "email": "ali@gmail.com",
      "password": "123456",
      "contact": "03001234567",
      "address": "Lahore, Pakistan"
    },
    {
      "name": "Muniba",
      "email": "muniba@gmail.com",
      "password": "abcd",
      "contact": "03111234567",
      "address": "Karachi, Pakistan"
    },
  ];

  List<Map<String, dynamic>> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = List.from(customers);
    searchCtrl.addListener(filterData);
  }

  void filterData() {
    String q = searchCtrl.text.toLowerCase();

    setState(() {
      filtered = customers.where((c) {
        return c["name"].toLowerCase().contains(q) ||
            c["email"].toLowerCase().contains(q) ||
            c["contact"].toLowerCase().contains(q) ||
            c["address"].toLowerCase().contains(q);
      }).toList();
    });
  }

  // ---------------- ADD / EDIT CUSTOMER ----------------
  void openCustomerDialog({Map<String, dynamic>? data, int? index}) {
    TextEditingController nameC = TextEditingController(text: data?["name"]);
    TextEditingController emailC =
    TextEditingController(text: data?["email"]);
    TextEditingController pwdC =
    TextEditingController(text: data?["password"]);
    TextEditingController contactC =
    TextEditingController(text: data?["contact"]);
    TextEditingController addressC =
    TextEditingController(text: data?["address"]);

    ValueNotifier<bool> isValid = ValueNotifier(false);

    void validate() {
      isValid.value = nameC.text.isNotEmpty &&
          emailC.text.isNotEmpty &&
          pwdC.text.isNotEmpty &&
          contactC.text.isNotEmpty &&
          addressC.text.isNotEmpty;
    }

    nameC.addListener(validate);
    emailC.addListener(validate);
    pwdC.addListener(validate);
    contactC.addListener(validate);
    addressC.addListener(validate);
    validate();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            data == null ? "Add Customer" : "Edit Customer",
            style: TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                textField("Full Name", nameC),
                const SizedBox(height: 10),
                textField("Email", emailC),
                const SizedBox(height: 10),
                textField("Password", pwdC),
                const SizedBox(height: 10),
                textField("Contact No.", contactC),
                const SizedBox(height: 10),
                textField("Address", addressC),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isValid,
              builder: (context, valid, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: valid ? navy : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: valid
                      ? () {
                    if (data == null) {
                      customers.add({
                        "name": nameC.text,
                        "email": emailC.text,
                        "password": pwdC.text,
                        "contact": contactC.text,
                        "address": addressC.text,
                      });
                    } else {
                      customers[index!] = {
                        "name": nameC.text,
                        "email": emailC.text,
                        "password": pwdC.text,
                        "contact": contactC.text,
                        "address": addressC.text,
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

  // ---------------- DELETE ----------------
  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Customer"),
        content: const Text("Are you sure you want to delete this customer?"),
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
              customers.removeAt(index);
              filterData();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

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

  // ---------------- UI ----------------
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
          "Customer Management",
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- TOP CREATE BUTTON ----------------
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
                  "Add Customer",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => openCustomerDialog(),
              ),
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search customers...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                var c = filtered[index];

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
                      // HEADER
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
                              c["name"],
                              style: TextStyle(
                                color: navy,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // DETAILS
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textRow("Email", c["email"]),
                            textRow("Password", c["password"]),
                            textRow("Contact", c["contact"]),
                            textRow("Address", c["address"]),
                          ],
                        ),
                      ),

                      Divider(color: gold),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: navy, size: 26),
                            onPressed: () =>
                                openCustomerDialog(data: c, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 26),
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
