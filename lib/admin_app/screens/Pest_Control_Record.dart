// lib/Pest_Control_Screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PestControlScreen extends StatefulWidget {
  const PestControlScreen({super.key});

  @override
  State<PestControlScreen> createState() => _PestControlScreenState();
}

class _PestControlScreenState extends State<PestControlScreen> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();
  final TextEditingController verifyCtrl = TextEditingController();

  // NEW — Text field filters
  final TextEditingController monthFilterCtrl = TextEditingController();
  final TextEditingController yearFilterCtrl = TextEditingController();

  // ---------------- SAMPLE SAVED DATA ----------------
  List<Map<String, String>> savedRows = [
    {
      "date": "1/12/2025",
      "comments": "Rodent activity noticed near cold storage.",
      "verify": "Ahmed Khan"
    },
    {
      "date": "20/11/2025",
      "comments": "Placed glue traps in loading bay.",
      "verify": "Imran Ali"
    },
    {
      "date": "5/3/2025",
      "comments": "Routine spray; no visible pests.",
      "verify": "Sara Malik"
    },
    {
      "date": "15/3/2025",
      "comments": "Ant trails cleaned and spray applied.",
      "verify": "Usman Tariq"
    },
  ];

  @override
  void initState() {
    super.initState();
    _sortSavedRows();
  }

  // ---------------- SORT DATA NEWEST FIRST ----------------
  void _sortSavedRows() {
    savedRows.sort((a, b) {
      final da = DateFormat('d/M/yyyy').parse(a['date']!);
      final db = DateFormat('d/M/yyyy').parse(b['date']!);
      return db.compareTo(da);
    });
  }

  // ---------------- FILTER RESULT LIST ----------------
  List<Map<String, String>> get filteredRows {
    return savedRows.where((row) {
      DateTime dt = DateFormat('d/M/yyyy').parse(row["date"]!);

      // MONTH FILTER TEXT — supports March, mar, 3, 03
      bool matchMonth = true;
      if (monthFilterCtrl.text.isNotEmpty) {
        String userMonth = monthFilterCtrl.text.toLowerCase().trim();

        String full = DateFormat('MMMM').format(dt).toLowerCase();
        String short = DateFormat('MMM').format(dt).toLowerCase();
        String num = dt.month.toString();
        String num2 = dt.month.toString().padLeft(2, "0");

        matchMonth = (full.contains(userMonth) ||
            short.contains(userMonth) ||
            num == userMonth ||
            num2 == userMonth);
      }

      // YEAR FILTER TEXT
      bool matchYear = true;
      if (yearFilterCtrl.text.isNotEmpty) {
        matchYear = dt.year.toString().contains(yearFilterCtrl.text.trim());
      }

      return matchMonth && matchYear;
    }).toList();
  }

  // ---------------- SAVE NEW RECORD ----------------
  void saveRecord() {
    if (dateCtrl.text.isEmpty || commentsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Date and Comments")),
      );
      return;
    }

    setState(() {
      savedRows.insert(0, {
        "date": dateCtrl.text,
        "comments": commentsCtrl.text,
        "verify": verifyCtrl.text.isEmpty ? "N/A" : verifyCtrl.text,
      });

      _sortSavedRows();

      dateCtrl.clear();
      commentsCtrl.clear();
      verifyCtrl.clear();
    });
  }

  // ---------------- DELETE RECORD ----------------
  void _confirmDelete(int index) {
    final row = filteredRows[index];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  savedRows.removeWhere((r) =>
                  r['date'] == row['date'] &&
                      r['comments'] == row['comments'] &&
                      r['verify'] == row['verify']);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- EDIT RECORD ----------------
  void _showEditDialog(int index) {
    final row = filteredRows[index];
    int actualIndex = savedRows.indexWhere((r) =>
    r['date'] == row['date'] &&
        r['comments'] == row['comments'] &&
        r['verify'] == row['verify']);

    final TextEditingController editDate =
    TextEditingController(text: row['date']);
    final TextEditingController editComments =
    TextEditingController(text: row['comments']);
    final TextEditingController editVerify =
    TextEditingController(text: row['verify']);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogDateField("Date", editDate, ctx),
                const SizedBox(height: 8),
                TextField(
                  controller: editComments,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Comments",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: editVerify,
                  decoration: const InputDecoration(
                    labelText: "Verify By",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (editDate.text.isEmpty || editComments.text.isEmpty) return;

                setState(() {
                  savedRows[actualIndex] = {
                    "date": editDate.text,
                    "comments": editComments.text,
                    "verify":
                    editVerify.text.isEmpty ? "N/A" : editVerify.text,
                  };
                  _sortSavedRows();
                });

                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- UI START ----------------
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
          "Pest Control 2025",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF344955),
          ),
        ),
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text(
            "Pest Control Entry Form",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF344955),
            ),
          ),
          const SizedBox(height: 8),

          // FORM BOX
          _buildFormBox(),

          const SizedBox(height: 20),

          // FILTER BOX — NEW (with text inputs)
          _buildFilterBox(),

          const SizedBox(height: 20),

          _buildSavedTable(),
        ]),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldDate("Date", dateCtrl, context),
          _field("Comments", commentsCtrl, maxLines: 3),
          _field("Verify By", verifyCtrl),

          Row(children: [
            ElevatedButton(
              onPressed: saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD6C28F),
                foregroundColor: Colors.black,
              ),
              child: const Text("Save Record"),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                dateCtrl.clear();
                commentsCtrl.clear();
                verifyCtrl.clear();
              },
              child: const Text("Clear"),
            ),
          ]),
        ],
      ),
    );
  }

  // ---------------- FILTER BOX — UPDATED ----------------
  Widget _buildFilterBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD6C28F), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filters (Type Month / Year)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF344955),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: monthFilterCtrl,
                  decoration: const InputDecoration(
                    labelText: "Month (e.g. March / Mar / 3)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: yearFilterCtrl,
                  decoration: const InputDecoration(
                    labelText: "Year (e.g. 2025)",
                    border: OutlineInputBorder(),
                  ),
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
          ),
        ],
      ),
    );
  }

  // ---------------- SAVED TABLE ----------------
  Widget _buildSavedTable() {
    if (filteredRows.isEmpty) {
      return const Text("No Data Found");
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6C28F), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Saved Records",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF344955),
                fontSize: 18),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: Colors.black26),
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(280),
                2: FixedColumnWidth(160),
                3: FixedColumnWidth(140),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE9E4D6)),
                  children: [
                    _tableHeader("Date"),
                    _tableHeader("Comments"),
                    _tableHeader("Verify"),
                    _tableHeader("Actions"),
                  ],
                ),

                for (int i = 0; i < filteredRows.length; i++)
                  TableRow(
                    children: [
                      _tableCell(filteredRows[i]['date']!),
                      _tableCell(filteredRows[i]['comments']!),
                      _tableCell(filteredRows[i]['verify']!),

                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF344955)),
                              onPressed: () => _showEditDialog(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(i),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ HELPERS --------------------

Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Widget _fieldDate(String label, TextEditingController c, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
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

Widget _dialogDateField(
    String label, TextEditingController c, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateFormat('d/M/yyyy')
              .parse(c.text.isNotEmpty ? c.text : "1/1/2025"),
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

class _tableHeader extends StatelessWidget {
  final String text;
  const _tableHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _tableCell extends StatelessWidget {
  final String text;
  const _tableCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
