// lib/Equipment_Maintenance_Form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EquipmentMaintenanceScreen extends StatefulWidget {
  @override
  State<EquipmentMaintenanceScreen> createState() =>
      _EquipmentMaintenanceScreenState();
}

class _EquipmentMaintenanceScreenState
    extends State<EquipmentMaintenanceScreen> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController equipmentCtrl = TextEditingController();
  final TextEditingController technicianCtrl = TextEditingController();
  final TextEditingController workCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  List<Map<String, String>> savedRows = [
    {
      "date": "12/1/2025",
      "equipment": "Meat Cutter Machine",
      "technician": "Ali Raza",
      "work": "Blade sharpening and oiling performed.",
      "remark": "Running smoothly."
    },
    {
      "date": "15/3/2025",
      "equipment": "Digital Weighing Scale",
      "technician": "Muhammad Saad",
      "work": "Calibration done for weight accuracy.",
      "remark": "No issues."
    },
    {
      "date": "20/1/2025",
      "equipment": "Grinder Machine",
      "technician": "Danish Iqbal",
      "work": "Motor cleaned, replaced belt.",
      "remark": "Needs monthly service."
    },
  ];

  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5E8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF344955)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Equipment Maintenance Report",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF344955),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------------- FORM CARD ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFD6C28F), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field("Date", dateCtrl, context: context, isDate: true),
                  _field("Equipment Name", equipmentCtrl, context: context),
                  _field("Technician Name", technicianCtrl, context: context),
                  _field("Work Performed", workCtrl, context: context, maxLines: 2),
                  _field("Remarks (Optional)", remarkCtrl, context: context, maxLines: 2),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6C28F),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    onPressed: saveRecord,
                    child: Text(
                      editingIndex == null ? "Save Record" : "Update Record",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- SAVED TABLE ----------------------
            if (savedRows.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFD6C28F), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saved Records",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF344955),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ---------------- HORIZONTAL SCROLL ----------------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        border: TableBorder.all(color: Colors.black38),
                        columnWidths: const {
                          0: FixedColumnWidth(120),
                          1: FixedColumnWidth(200),
                          2: FixedColumnWidth(180),
                          3: FixedColumnWidth(260),
                          4: FixedColumnWidth(200),
                          5: FixedColumnWidth(120), // ACTION COLUMN
                        },
                        children: [
                          // ---------------- HEADER ----------------
                          TableRow(
                            decoration:
                            BoxDecoration(color: Color(0xFFE9E4D6)),
                            children: const [
                              _tableHeader("Date"),
                              _tableHeader("Equipment"),
                              _tableHeader("Technician"),
                              _tableHeader("Work Performed"),
                              _tableHeader("Remarks"),
                              _tableHeader("Action"),
                            ],
                          ),

                          // ---------------- DATA ROWS ----------------
                          for (int i = 0; i < savedRows.length; i++)
                            TableRow(
                              children: [
                                _tableCell(savedRows[i]["date"]!),
                                _tableCell(savedRows[i]["equipment"]!),
                                _tableCell(savedRows[i]["technician"]!),
                                _tableCell(savedRows[i]["work"]!),
                                _tableCell(savedRows[i]["remark"] ?? "N/A"),

                                // ACTION BUTTONS INSIDE TABLE
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => loadForEdit(i),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteRecord(i),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------- SAVE / UPDATE ----------------------
  void saveRecord() {
    if (dateCtrl.text.isEmpty ||
        equipmentCtrl.text.isEmpty ||
        technicianCtrl.text.isEmpty ||
        workCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    final newRecord = {
      "date": dateCtrl.text,
      "equipment": equipmentCtrl.text,
      "technician": technicianCtrl.text,
      "work": workCtrl.text,
      "remark": remarkCtrl.text.isEmpty ? "N/A" : remarkCtrl.text,
    };

    if (editingIndex == null) {
      savedRows.insert(0, newRecord);
    } else {
      savedRows[editingIndex!] = newRecord;
      editingIndex = null;
    }

    // SORT BY DATE (Newest first)
    savedRows.sort((a, b) {
      DateTime da = DateFormat('d/M/yyyy').parse(a["date"]!);
      DateTime db = DateFormat('d/M/yyyy').parse(b["date"]!);
      return db.compareTo(da);
    });

    clearFields();
    setState(() {});
  }

  // ---------------------- LOAD FOR EDIT ----------------------
  void loadForEdit(int index) {
    editingIndex = index;
    final row = savedRows[index];

    dateCtrl.text = row["date"]!;
    equipmentCtrl.text = row["equipment"]!;
    technicianCtrl.text = row["technician"]!;
    workCtrl.text = row["work"]!;
    remarkCtrl.text = row["remark"] == "N/A" ? "" : row["remark"]!;

    setState(() {});
  }

  // ---------------------- DELETE ----------------------
  void deleteRecord(int index) {
    savedRows.removeAt(index);
    setState(() {});
  }

  // ---------------------- CLEAR FIELDS ----------------------
  void clearFields() {
    dateCtrl.clear();
    equipmentCtrl.clear();
    technicianCtrl.clear();
    workCtrl.clear();
    remarkCtrl.clear();
  }
}

// ---------------------- INPUT FIELD ----------------------
Widget _field(
    String label,
    TextEditingController c, {
      required BuildContext context,
      bool isDate = false,
      int maxLines = 1,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      readOnly: isDate,
      maxLines: maxLines,
      onTap: () async {
        if (isDate) {
          DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (picked != null) {
            c.text = DateFormat('d/M/yyyy').format(picked);
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

// ---------------------- TABLE CELLS ----------------------
class _tableHeader extends StatelessWidget {
  final String text;
  const _tableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _tableCell extends StatelessWidget {
  final String text;
  const _tableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
