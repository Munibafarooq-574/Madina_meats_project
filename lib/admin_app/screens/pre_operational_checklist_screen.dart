// lib/PreOperationalChecklistScreen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class PreOperationalChecklistScreen extends StatefulWidget {
  const PreOperationalChecklistScreen({super.key});

  @override
  State<PreOperationalChecklistScreen> createState() =>
      _PreOperationalChecklistScreenState();
}

class _PreOperationalChecklistScreenState
    extends State<PreOperationalChecklistScreen> {
  final TextEditingController plantCtrl = TextEditingController();
  final TextEditingController monthCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  final TextEditingController initialsCtrl = TextEditingController();

  String? editingRecordId;

  // ---------------- UPDATED ITEMS LIST WITH HEADINGS ----------------
  final List<Map<String, dynamic>> items = [
    {"text": "Cutting Room", "isHeader": true},
    {"text": "Walls, floors, ceiling", "isHeader": false},
    {"text": "Sink", "isHeader": false},
    {"text": "Sanitizers", "isHeader": false},
    {"text": "Utensils", "isHeader": false},
    {"text": "Tables", "isHeader": false},
    {"text": "Grinder", "isHeader": false},
    {"text": "Garbage", "isHeader": false},
    {"text": "Non Contact Surfaces", "isHeader": false},
    {"text": "UV Light", "isHeader": false},

    {"text": "Coolers", "isHeader": true},
    {"text": "Walls, floors, ceiling", "isHeader": false},
    {"text": "Shelves & Drains", "isHeader": false},
    {"text": "Separation between species", "isHeader": false},
    {"text": "Washroom", "isHeader": false},
    {"text": "Lunch Room", "isHeader": false},
    {"text": "Dry Storage", "isHeader": false},
    {"text": "Shipping (operational Control through the Kill Floor)", "isHeader": false},

    {"text": "Kill Floor", "isHeader": true},
    {"text": "Walls, floors, ceiling", "isHeader": false},
    {"text": "Sink", "isHeader": false},
    {"text": "Kill Floor Equipment", "isHeader": false},

    {"text": "Shipping Vestibule", "isHeader": true},
    {"text": "Walls, floors, ceiling", "isHeader": false},
  ];

  Map<int, bool> acceptable = {};
  Map<int, bool> unacceptable = {};

  List<Map<String, String>> correctiveLogs = [];
  List<Map<String, dynamic>> savedRecords = [];

  @override
  void initState() {
    super.initState();

    // ------------------ ADD 2 DUMMY RECORDS ------------------
    savedRecords = [
      {
        "id": "1001",
        "plant": "Plant A",
        "month": "January",
        "time": "10:30 AM",
        "initials": "MK",
        "acceptable": {1: true, 3: true},
        "unacceptable": {2: true},
        "corrective": [
          {
            "date": "2025-01-01",
            "time": "11:00 AM",
            "deviation": "Floor Wet",
            "action": "Cleaned & Sanitized",
            "inspection": "Checked again",
            "initials": "MK"
          }
        ],
      },
      {
        "id": "1002",
        "plant": "Plant B",
        "month": "February",
        "time": "02:15 PM",
        "initials": "AR",
        "acceptable": {4: true},
        "unacceptable": {5: true},
        "corrective": [
          {
            "date": "2025-02-10",
            "time": "03:40 PM",
            "deviation": "Improper Separation",
            "action": "Re-arranged Storage",
            "inspection": "Verified OK",
            "initials": "AR"
          }
        ],
      }
    ];
  }

  // Add Corrective Row
  void addCorrectiveRow() {
    correctiveLogs.add({
      "date": "",
      "time": "",
      "deviation": "",
      "action": "",
      "inspection": "",
      "initials": "",
    });
    setState(() {});
  }

  void deleteCorrectiveRow(int index) {
    correctiveLogs.removeAt(index);
    setState(() {});
  }

  // Pick Date
  Future<void> pickDate(int index) async {
    final res = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (res != null) {
      correctiveLogs[index]["date"] =
      "${res.year}-${res.month.toString().padLeft(2, '0')}-${res.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // Pick Time
  Future<void> pickTime(int index) async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (res != null) {
      correctiveLogs[index]["time"] = res.format(context);
      setState(() {});
    }
  }

  Future<void> pickMainTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (res != null) {
      timeCtrl.text = res.format(context);
      setState(() {});
    }
  }

  // Save Record
  void saveRecord() {
    final newRecord = {
      "id": Random().nextInt(999999).toString(),
      "plant": plantCtrl.text,
      "month": monthCtrl.text,
      "time": timeCtrl.text,
      "initials": initialsCtrl.text,
      "acceptable": Map<int, bool>.from(acceptable),
      "unacceptable": Map<int, bool>.from(unacceptable),
      "corrective": List<Map<String, String>>.from(correctiveLogs),
    };

    savedRecords.add(newRecord);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Record saved!")));

    clearForm();
  }

  // Update Record
  void updateRecord() {
    final index = savedRecords.indexWhere((e) => e["id"] == editingRecordId);
    if (index == -1) return;

    savedRecords[index] = {
      "id": editingRecordId,
      "plant": plantCtrl.text,
      "month": monthCtrl.text,
      "time": timeCtrl.text,
      "initials": initialsCtrl.text,
      "acceptable": Map<int, bool>.from(acceptable),
      "unacceptable": Map<int, bool>.from(unacceptable),
      "corrective": List<Map<String, String>>.from(correctiveLogs),
    };

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Record updated!")));

    editingRecordId = null;
    clearForm();
  }

  // Delete Record
  void deleteRecord(String id) {
    savedRecords.removeWhere((r) => r["id"] == id);
    setState(() {});
  }

  // Edit Record
  void editRecord(Map<String, dynamic> rec) {
    editingRecordId = rec["id"];

    plantCtrl.text = rec["plant"];
    monthCtrl.text = rec["month"];
    timeCtrl.text = rec["time"];
    initialsCtrl.text = rec["initials"];

    acceptable = Map<int, bool>.from(rec["acceptable"]);
    unacceptable = Map<int, bool>.from(rec["unacceptable"]);
    correctiveLogs = List<Map<String, String>>.from(rec["corrective"]);

    setState(() {});
  }

  void clearForm() {
    plantCtrl.clear();
    monthCtrl.clear();
    timeCtrl.clear();
    initialsCtrl.clear();

    acceptable = {};
    unacceptable = {};
    correctiveLogs = [];
    setState(() {});
  }

  @override
  void dispose() {
    plantCtrl.dispose();
    monthCtrl.dispose();
    timeCtrl.dispose();
    initialsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xfff8f5e8);

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
        title: const Column(
          children: [
            Text(
              "Pre-Operational Checklist",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Cutting & Shipping",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formSection(),
              const SizedBox(height: 20),

              _checklistBox(),
              const SizedBox(height: 30),

              _correctiveHeader(),
              const SizedBox(height: 10),
              _correctiveTable(),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD6C28F),
                    foregroundColor: Colors.black,
                  ),
                  onPressed:
                  editingRecordId == null ? saveRecord : updateRecord,
                  child: Text(editingRecordId == null
                      ? "Save Record"
                      : "Update Record"),
                ),
              ),

              if (editingRecordId != null)
                Center(
                  child: TextButton(
                    onPressed: clearForm,
                    child: const Text("Cancel Editing"),
                  ),
                ),

              const SizedBox(height: 30),
              _savedRecordsSection(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FORM SECTION ----------------
  Widget _formSection() {
    return Column(
      children: [
        _field("Plant #", plantCtrl),
        const SizedBox(height: 12),
        _field("Month", monthCtrl),
        const SizedBox(height: 12),
        _timeField(),
        const SizedBox(height: 12),
        _field("Initials", initialsCtrl),
      ],
    );
  }

  // Time Picker Field
  Widget _timeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: pickMainTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.brown),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeCtrl.text.isEmpty ? "Select Time" : timeCtrl.text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        )
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.brown),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: ctrl,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  // ---------------- CHECKLIST ----------------
  Widget _checklistBox() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Area")),
            DataColumn(label: Text("✓")),
            DataColumn(label: Text("X")),
          ],
          rows: List.generate(
            items.length,
                (i) {
              final isHeader = items[i]["isHeader"] == true;
              final text = items[i]["text"];

              return DataRow(
                cells: [
                  // AREA TEXT (bold if header)
                  DataCell(
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight:
                        isHeader ? FontWeight.bold : FontWeight.normal,
                        fontSize: isHeader ? 15 : 14,
                      ),
                    ),
                  ),

                  // ✓ CHECKBOX — only for normal rows
                  DataCell(
                    isHeader
                        ? const SizedBox() // EMPTY FOR HEADERS
                        : Checkbox(
                      value: acceptable[i] == true,
                      onChanged: (v) {
                        setState(() {
                          acceptable[i] = v ?? false;
                          if (v == true) unacceptable[i] = false;
                        });
                      },
                    ),
                  ),

                  // X CHECKBOX — only for normal rows
                  DataCell(
                    isHeader
                        ? const SizedBox()
                        : Checkbox(
                      value: unacceptable[i] == true,
                      onChanged: (v) {
                        setState(() {
                          unacceptable[i] = v ?? false;
                          if (v == true) acceptable[i] = false;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- CORRECTIVE TABLE ----------------
  Widget _correctiveHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Corrective Action Log Sheet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: addCorrectiveRow,
          child: const Text("Add Row"),
        )
      ],
    );
  }

  Widget _correctiveTable() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(10),
      ),
      child: correctiveLogs.isEmpty
          ? const Center(child: Text("No rows added."))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Time")),
            DataColumn(label: Text("Deviation")),
            DataColumn(label: Text("Action")),
            DataColumn(label: Text("Re-Inspect")),
            DataColumn(label: Text("Initials")),
            DataColumn(label: Text("Delete")),
          ],
          rows: List.generate(correctiveLogs.length, (i) {
            return DataRow(
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: () => pickDate(i),
                    child: Text(
                      correctiveLogs[i]["date"]!.isEmpty
                          ? "Select Date"
                          : correctiveLogs[i]["date"]!,
                    ),
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () => pickTime(i),
                    child: Text(
                      correctiveLogs[i]["time"]!.isEmpty
                          ? "Select Time"
                          : correctiveLogs[i]["time"]!,
                    ),
                  ),
                ),
                _editCell(i, "deviation"),
                _editCell(i, "action"),
                _editCell(i, "inspection"),
                _editCell(i, "initials"),
                DataCell(
                  IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteCorrectiveRow(i),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  DataCell _editCell(int row, String key) {
    return DataCell(
      SizedBox(
        width: 160,
        child: TextField(
          controller:
          TextEditingController(text: correctiveLogs[row][key]),
          onChanged: (v) => correctiveLogs[row][key] = v,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  // ---------------- SAVED RECORDS ----------------
  Widget _savedRecordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Saved Records",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        savedRecords.isEmpty
            ? const Text("No records saved yet.")
            : Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Month")),
                DataColumn(label: Text("Time")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Delete")),
              ],

              // 🔥 FIXED: SAFELY HANDLE MAP<String, dynamic>
              rows: List.generate(savedRecords.length, (index) {
                final rec = savedRecords[index] as Map<String, dynamic>;

                return DataRow(
                  cells: [
                    DataCell(Text(rec["id"]?.toString() ?? "")),
                    DataCell(Text(rec["month"]?.toString() ?? "")),
                    DataCell(Text(rec["time"]?.toString() ?? "")),

                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editRecord(rec),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteRecord(rec["id"]),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

}
