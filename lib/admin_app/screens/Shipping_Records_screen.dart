// lib/shipping_record_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShippingRecordScreen extends StatefulWidget {
  const ShippingRecordScreen({super.key});

  @override
  State<ShippingRecordScreen> createState() => _ShippingRecordScreenState();
}

class _ShippingRecordScreenState extends State<ShippingRecordScreen> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  final TextEditingController coolerTempCtrl = TextEditingController();
  final TextEditingController carcassTempCtrl = TextEditingController();

  final TextEditingController monthFilterCtrl = TextEditingController();
  final TextEditingController yearFilterCtrl = TextEditingController();

  // ------------------ LEGEND-BASED DUMMY DATA ------------------
  List<Map<String, String>> savedRows = [
    {"date": "05/12/2025", "time": "10:30 AM", "cooler": "C", "carcass": "BHH"},
    {"date": "03/12/2025", "time": "02:15 PM", "cooler": "H", "carcass": "BSH"},
    {"date": "28/11/2025", "time": "09:40 AM", "cooler": "C", "carcass": "L"},
    {"date": "20/11/2025", "time": "04:20 PM", "cooler": "H", "carcass": "G"},
    {"date": "12/11/2025", "time": "08:15 AM", "cooler": "C", "carcass": "BHH"},
    {"date": "03/11/2025", "time": "06:50 PM", "cooler": "H", "carcass": "BSH"},
    {"date": "28/10/2025", "time": "11:10 AM", "cooler": "C", "carcass": "L"},
    {"date": "18/10/2025", "time": "09:40 PM", "cooler": "H", "carcass": "G"},
    {"date": "05/10/2025", "time": "07:05 AM", "cooler": "C", "carcass": "BSH"},
    {"date": "25/09/2025", "time": "04:45 PM", "cooler": "H", "carcass": "BHH"},
  ];

  @override
  void initState() {
    super.initState();
    _sortSavedRows();
  }

  void _sortSavedRows() {
    savedRows.sort((a, b) {
      final da = DateFormat('d/M/yyyy').parse(a['date']!);
      final db = DateFormat('d/M/yyyy').parse(b['date']!);
      return db.compareTo(da);
    });
  }

  // ---------------- FILTERED LIST ----------------
  List<Map<String, String>> get filteredRows {
    return savedRows.where((row) {
      DateTime dt = DateFormat('d/M/yyyy').parse(row["date"]!);

      bool matchMonth = true;
      if (monthFilterCtrl.text.isNotEmpty) {
        String m = monthFilterCtrl.text.toLowerCase();
        matchMonth =
            DateFormat('MMMM').format(dt).toLowerCase().contains(m) ||
                DateFormat('MMM').format(dt).toLowerCase().contains(m) ||
                dt.month.toString() == m ||
                dt.month.toString().padLeft(2, "0") == m;
      }

      bool matchYear = true;
      if (yearFilterCtrl.text.isNotEmpty) {
        matchYear = dt.year.toString().contains(yearFilterCtrl.text.trim());
      }

      return matchMonth && matchYear;
    }).toList();
  }

  // ---------------- SAVE ----------------
  void saveRecord() {
    if (dateCtrl.text.isEmpty ||
        timeCtrl.text.isEmpty ||
        coolerTempCtrl.text.isEmpty ||
        carcassTempCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      savedRows.insert(0, {
        "date": dateCtrl.text,
        "time": timeCtrl.text,
        "cooler": coolerTempCtrl.text,
        "carcass": carcassTempCtrl.text,
      });
      _sortSavedRows();

      dateCtrl.clear();
      timeCtrl.clear();
      coolerTempCtrl.clear();
      carcassTempCtrl.clear();
    });
  }

  // ---------------- DELETE ----------------
  void _confirmDelete(int index) {
    final row = filteredRows[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                savedRows.removeWhere((r) =>
                r['date'] == row['date'] &&
                    r['time'] == row['time'] &&
                    r['cooler'] == row['cooler'] &&
                    r['carcass'] == row['carcass']);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------------- EDIT ----------------
  void _showEditDialog(int index) {
    final row = filteredRows[index];

    int actualIndex = savedRows.indexWhere((r) =>
    r['date'] == row['date'] &&
        r['time'] == row['time'] &&
        r['cooler'] == row['cooler'] &&
        r['carcass'] == row['carcass']);

    final TextEditingController editDate = TextEditingController(text: row['date']);
    final TextEditingController editTime = TextEditingController(text: row['time']);
    final TextEditingController editCooler = TextEditingController(text: row['cooler']);
    final TextEditingController editCarcass = TextEditingController(text: row['carcass']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Record'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _dateField(editDate),
              const SizedBox(height: 8),
              _timeField(editTime),
              _simpleField("Cooler's Temp", editCooler),
              _simpleField("Carcass Temp", editCarcass),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                savedRows[actualIndex] = {
                  "date": editDate.text,
                  "time": editTime.text,
                  "cooler": editCooler.text,
                  "carcass": editCarcass.text,
                };
                _sortSavedRows();
              });

              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
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
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF344955)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Legend",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                    SizedBox(height: 6),
                    Text("C : Chill Cooler"),
                    Text("H : Hold Cooler"),
                    Text("BHH : Beef Hip High Temp"),
                    Text("BSH : Beef Shoulder High Temp"),
                    Text("L : Lamb"),
                    Text("G : Goat"),
                  ],
                ),
              ),
            ],
          )
        ],
        title: const Text(
          "Shipping Records",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF344955)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Shipping Entry Form",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFormBox(),
            const SizedBox(height: 20),
            _buildFilterBox(),
            const SizedBox(height: 20),
            _buildSavedTable(),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM BOX ----------------
  Widget _buildFormBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD6C28F), width: 2),
      ),
      child: Column(
        children: [
          _dateField(dateCtrl),
          _timeField(timeCtrl),
          _simpleField("Cooler's Temp", coolerTempCtrl),
          _simpleField("Carcass Temp", carcassTempCtrl),
          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                onPressed: saveRecord,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD6C28F), foregroundColor: Colors.black),
                child: const Text("Save Record"),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  dateCtrl.clear();
                  timeCtrl.clear();
                  coolerTempCtrl.clear();
                  carcassTempCtrl.clear();
                },
                child: const Text("Clear"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- FILTER BOX ----------------
  Widget _buildFilterBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD6C28F), width: 2),
      ),
      child: Column(children: [
        const Text(
          "Filters (Type Month / Year)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: monthFilterCtrl,
                decoration: const InputDecoration(
                    labelText: "Month (March / Mar / 3)",
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: yearFilterCtrl,
                decoration: const InputDecoration(
                    labelText: "Year (2025)", border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: () {
            monthFilterCtrl.clear();
            yearFilterCtrl.clear();
            setState(() {});
          },
          icon: const Icon(Icons.clear),
          label: const Text("Reset Filters"),
        )
      ]),
    );
  }

  // ---------------- TABLE ----------------
  Widget _buildSavedTable() {
    if (filteredRows.isEmpty) {
      return const Text("No Data Found");
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD6C28F), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Saved Records",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: Colors.black26),
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(150),
                2: FixedColumnWidth(140),
                3: FixedColumnWidth(200),
                4: FixedColumnWidth(140),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE9E4D6)),
                  children: [
                    _tableHeader("Date"),
                    _tableHeader("Time"),
                    _tableHeader("Cooler"),
                    _tableHeader("Carcass"),
                    _tableHeader("Actions"),
                  ],
                ),

                for (int i = 0; i < filteredRows.length; i++)
                  TableRow(
                    children: [
                      _tableCell(filteredRows[i]['date']!),
                      _tableCell(filteredRows[i]['time']!),
                      _tableCell(filteredRows[i]['cooler']!),
                      _tableCell(filteredRows[i]['carcass']!),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF344955)),
                                onPressed: () => _showEditDialog(i)),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(i)),
                          ],
                        ),
                      )
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------- INPUT HELPERS ----------------
  Widget _simpleField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  // DATE PICKER
  Widget _dateField(TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: true,
        decoration: const InputDecoration(
            labelText: "Date",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_month)),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            c.text = DateFormat('d/M/yyyy').format(picked);
          }
        },
      ),
    );
  }

  // TIME PICKER
  Widget _timeField(TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: true,
        decoration: const InputDecoration(
            labelText: "Time of Shipping",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time)),
        onTap: () async {
          TimeOfDay? picked =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

          if (picked != null) {
            final now = DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
            c.text = DateFormat("hh:mm a").format(dt);
          }
        },
      ),
    );
  }
}

// ---------------- TABLE CELL WIDGETS ----------------
class _tableHeader extends StatelessWidget {
  final String text;
  const _tableHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text,
          textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _tableCell extends StatelessWidget {
  final String text;
  const _tableCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
