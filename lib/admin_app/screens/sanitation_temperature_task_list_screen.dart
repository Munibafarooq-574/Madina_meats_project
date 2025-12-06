// lib/sanitation_temperature_task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SanitationTemperatureTaskListScreen extends StatefulWidget {
  const SanitationTemperatureTaskListScreen({super.key});

  @override
  State<SanitationTemperatureTaskListScreen> createState() =>
      _SanitationTemperatureTaskListScreenState();
}

class _SanitationTemperatureTaskListScreenState
    extends State<SanitationTemperatureTaskListScreen> {
  final Color background = const Color(0xFFF5F3EB);
  final Color gold = const Color(0xFFD6C28F);

  final TextEditingController monthOfCtrl = TextEditingController();
  final TextEditingController yearOfCtrl = TextEditingController();
  final TextEditingController personCtrl = TextEditingController();
  final TextEditingController productsCtrl = TextEditingController();

  final TextEditingController operatorCtrl = TextEditingController();       // NEW
  final TextEditingController inspectorCtrl = TextEditingController();      // NEW

  final TextEditingController monthFilterCtrl = TextEditingController();
  final TextEditingController yearFilterCtrl = TextEditingController();

  final List<String> days = List.generate(31, (i) => (i + 1).toString());

  final List<String> items = [
    "Procedure Reference",
    "Cutting room/Shipping/Receiving",
    "4 hrs. mid shift",
    "Barns/holding pens",
    "Inedible/Hide rooms",
    "Chill cooler",
    "Hold cooler",
    "Welfare room/Offices",
    "Washroom",
    "Freezer",
    "Kill Floor/Equipment",
    "Walls/Ceilings/Overhead structures",
    "Captive Bolt",
    "Outside premises",
    "Housekeeping/Janitorial",
    "Refrig. Truck",
    "Temperatures: ",
    "Chill cooler (AM/PM)",
    "Carcasses in chill",
    "Hold cooler (AM/PM)",
    "Carcasses in Hold",
    "Freezer",
    "Knife sanitizer (Cutting/Processing)",
    "Product: Cutting room",
    "Air Temperature: Cutting room",
  ];

  late Map<String, Map<String, dynamic>> tableData;

  final List<Map<String, dynamic>> savedReports = [];
  int _nextId = 1000;

  String? editingRecordId;

  @override
  void initState() {
    super.initState();
    yearFilterCtrl.text = DateTime.now().year.toString();
    _initTableData();

    // ---------- UPDATED DUMMY RECORDS WITH NEW FIELDS ----------
    savedReports.addAll([
      {
        'id': (_nextId++).toString(),
        'monthOf': "January",
        'year': "2025",
        'person': "John Doe",
        'products': "Sanitizer A",
        'operator': "JD",                // NEW
        'inspector': "MK",               // NEW
        'details': {
          for (var it in items)
            it: {'days': {for (var d in days) d: (d == "1" || d == "5")}}
        },
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': (_nextId++).toString(),
        'monthOf': "February",
        'year': "2025",
        'person': "Sarah Smith",
        'products': "Detergent X",
        'operator': "SS",               // NEW
        'inspector': "KL",              // NEW
        'details': {
          for (var it in items)
            it: {
              'days': {
                for (var d in days) d: (d == "10" || d == "15" || d == "20")
              }
            }
        },
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
    ]);

    setState(() {});
  }

  void _initTableData() {
    tableData = {
      for (var it in items) it: {'days': {for (var d in days) d: false}}
    };
  }

  List<Map<String, dynamic>> get filteredReports {
    return savedReports.where((rec) {
      bool matchMonth = monthFilterCtrl.text.isEmpty
          ? true
          : rec['monthOf']
          .toString()
          .toLowerCase()
          .contains(monthFilterCtrl.text.toLowerCase());

      bool matchYear = yearFilterCtrl.text.isEmpty
          ? true
          : rec['year'].toString().contains(yearFilterCtrl.text.trim());

      return matchMonth && matchYear;
    }).toList();
  }

  void _toggleCell(String item, String day) {
    setState(() {
      tableData[item]!['days'][day] =
      !(tableData[item]!['days'][day] ?? false);
    });
  }

  // ------------------------ SAVE / UPDATE -----------------------
  void _saveRecord() {
    final monthOf = monthOfCtrl.text.trim();
    final yearOf = yearOfCtrl.text.trim();
    final person = personCtrl.text.trim();

    if (monthOf.isEmpty || yearOf.isEmpty || person.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter Month, Year and Person(s) Responsible"),
      ));
      return;
    }

    final details = <String, Map<String, dynamic>>{};
    for (var it in items) {
      details[it] = {
        'days':
        Map<String, bool>.from(tableData[it]!['days'] as Map<String, bool>)
      };
    }

    if (editingRecordId == null) {
      final rec = {
        'id': (_nextId++).toString(),
        'monthOf': monthOf,
        'year': yearOf,
        'person': person,
        'products': productsCtrl.text.trim(),
        'operator': operatorCtrl.text.trim(),     // NEW
        'inspector': inspectorCtrl.text.trim(),   // NEW
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() => savedReports.insert(0, rec));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Record saved")));
    } else {
      int index = savedReports.indexWhere((r) => r['id'] == editingRecordId);

      savedReports[index] = {
        'id': editingRecordId,
        'monthOf': monthOf,
        'year': yearOf,
        'person': person,
        'products': productsCtrl.text.trim(),
        'operator': operatorCtrl.text.trim(),     // NEW
        'inspector': inspectorCtrl.text.trim(),   // NEW
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      };

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Record updated")));

      editingRecordId = null;
    }

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      monthOfCtrl.clear();
      yearOfCtrl.clear();
      personCtrl.clear();
      productsCtrl.clear();
      operatorCtrl.clear();      // NEW
      inspectorCtrl.clear();     // NEW
      editingRecordId = null;
      _initTableData();
    });
  }

  void _clearCells() {
    setState(() {
      for (var it in items) {
        tableData[it]!['days'].updateAll((key, value) => false);
      }
    });
  }

  // ------------------------ EDIT ------------------------
  void _editRecord(int index) {
    final rec = savedReports[index];
    editingRecordId = rec['id'];

    monthOfCtrl.text = rec['monthOf'];
    yearOfCtrl.text = rec['year'];
    personCtrl.text = rec['person'];
    productsCtrl.text = rec['products'];
    operatorCtrl.text = rec['operator'] ?? "";     // NEW
    inspectorCtrl.text = rec['inspector'] ?? "";   // NEW

    final details = rec['details'] as Map<String, dynamic>;
    for (var it in items) {
      final raw = details[it]['days'] as Map;
      tableData[it]!['days'] = {
        for (var d in days)
          d: raw[d] == true || raw[d] == "true" || raw[d] == 1
      };
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Loaded for editing — press Update")));

    setState(() {});
  }

  void _deleteRecord(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content:
        const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              savedReports.removeAt(index);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  InputDecoration formDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _roundedCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  // --------------------- GRID TABLE ---------------------
  Widget _tableHeaderCell(String label, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        color: Colors.grey.shade200,
      ),
      alignment: Alignment.center,
      child: Text(label,
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildGridTable() {
    const double itemWidth = 250;
    const double dayWidth = 55;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              _tableHeaderCell("TASK", itemWidth),
              for (var d in days) _tableHeaderCell(d, dayWidth),
            ],
          ),

          for (var it in items)
            (() {
              if (it == "Procedure Reference" || it == "Temperatures: ") {
                return Row(
                  children: [
                    Container(
                      width: itemWidth,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Text(
                        it,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    for (var d in days)
                      Container(
                        width: dayWidth,
                        height: 42,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          color: Colors.grey.shade200,
                        ),
                      ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(8),
                    decoration:
                    BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: Text(it, style: const TextStyle(fontSize: 12)),
                  ),
                  for (var d in days)
                    GestureDetector(
                      onTap: () => _toggleCell(it, d),
                      child: Container(
                        width: dayWidth,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          color: tableData[it]!['days'][d] == true
                              ? Colors.green.withOpacity(0.3)
                              : Colors.white,
                        ),
                        child: tableData[it]!['days'][d] == true
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                ],
              );
            })(),
        ],
      ),
    );
  }

  void _applyFilter() => setState(() {});
  void _clearFilter() {
    monthFilterCtrl.clear();
    yearFilterCtrl.clear();
    setState(() {});
  }

  // ------------------- VIEW RECORD POPUP -------------------
  void _viewRecordDetails(Map<String, dynamic> rec) {
    final details = rec['details'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 900,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text("Record ID: ${rec['id']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold))),
                    Text(DateFormat("d MMM yyyy • hh:mm a")
                        .format(DateTime.parse(rec['timestamp']))),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close))
                  ],
                ),

                Text("Month: ${rec['monthOf']}  •  Year: ${rec['year']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Person: ${rec['person']}"),
                Text("Products: ${rec['products']}"),
                Text("Operator Initials: ${rec['operator']}"),      // NEW
                Text("Inspector Initials: ${rec['inspector']}"),    // NEW

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.black26),
                      defaultColumnWidth: const FixedColumnWidth(200),
                      children: [
                        TableRow(
                          decoration:
                          BoxDecoration(color: Colors.grey.shade300),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Item",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Selected Days",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ],
                        ),

                        ...items.map((it) {
                          if (it == "Procedure Reference" ||
                              it == "Temperatures: ") {
                            return TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    it,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(""),
                                )
                              ],
                            );
                          }

                          final d =
                          details[it]['days'] as Map<String, dynamic>;
                          final selected = d.entries
                              .where((e) => e.value == true)
                              .map((e) => e.key)
                              .toList();

                          return TableRow(children: [
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(it)),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(selected.isEmpty
                                  ? '-'
                                  : selected.join(", ")),
                            ),
                          ]);
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Close")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------- UI -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Sanitation / Temperature Task List",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ---------------- MAIN FORM ----------------
          _roundedCard(
            child: SizedBox(
              height: 650,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: monthOfCtrl,
                            decoration: formDecoration("MONTH OF"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: yearOfCtrl,
                            keyboardType: TextInputType.number,
                            decoration: formDecoration("YEAR"),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 14),
                    TextField(
                      controller: personCtrl,
                      decoration:
                      formDecoration("PERSON(S) RESPONSIBLE"),
                    ),

                    const SizedBox(height: 14),
                    TextField(
                      controller: productsCtrl,
                      decoration: formDecoration("PRODUCTS USED"),
                    ),

                    const SizedBox(height: 14),
                    TextField(
                      controller: operatorCtrl,
                      decoration:
                      formDecoration("Operator or Designate Initials"),
                    ),

                    const SizedBox(height: 14),
                    TextField(
                      controller: inspectorCtrl,
                      decoration:
                      formDecoration("Inspector’s Initials"),
                    ),

                    const SizedBox(height: 20),
                    _buildGridTable(),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _clearCells,
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear Cells"),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _saveRecord,
                          icon: const Icon(Icons.save),
                          label: Text(
                              editingRecordId == null
                                  ? "Save Record"
                                  : "Update"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          // ---------------- FILTER BOX ----------------
          _roundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("FILTER RECORDS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthFilterCtrl,
                        decoration: formDecoration("Month"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: yearFilterCtrl,
                        decoration: formDecoration("Year"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _clearFilter,
                      child: const Text("Clear Filter"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _applyFilter,
                      child: const Text("Apply Filter"),
                    ),
                  ],
                )
              ],
            ),
          ),

          // ---------------- SAVED RECORDS ----------------
          _roundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SAVED RECORDS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),

                if (filteredReports.isEmpty)
                  const Text("No records found",
                      style: TextStyle(color: Colors.grey)),

                ...filteredReports.map((rec) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                          "Month: ${rec['monthOf']}  •  Year: ${rec['year']}"),
                      subtitle: Text(
                        "Person: ${rec['person']}\nProducts: ${rec['products']}\n"
                            "Operator: ${rec['operator']}\nInspector: ${rec['inspector']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _viewRecordDetails(rec)),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              int idx = savedReports
                                  .indexWhere((r) => r['id'] == rec['id']);
                              _editRecord(idx);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              int idx = savedReports
                                  .indexWhere((r) => r['id'] == rec['id']);
                              _deleteRecord(idx);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
