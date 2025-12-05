// lib/pre_slaughter_status_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

enum CheckState { tick, cross, none }

class PreSlaughterStatusScreen extends StatefulWidget {
  const PreSlaughterStatusScreen({super.key});

  @override
  State<PreSlaughterStatusScreen> createState() =>
      _PreSlaughterStatusScreenState();
}

class _PreSlaughterStatusScreenState extends State<PreSlaughterStatusScreen> {
  // Theme
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color bg = const Color(0xFFF8F5E8);

  // Scroll controller → used to jump to the form when editing
  final ScrollController scrollController = ScrollController();

  // Form controllers
  final TextEditingController dateCtrl = TextEditingController();
  final SignatureController signController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final List<String> temperatureItems = [
    'Sanitizer 1 (Inspection Table)',
    'Sanitizer 2 (Skinning Room)',
    'Sanitizer 3 (Knock Box)',
    'Chill Cooler',
    'Hold Cooler',
    'Freezer (Chest) #1',
    'Freezer (Chest) #2',
    'Freezer (Walk In)',
    'UV Light',
    'Intervention Tank',
  ];

  final List<String> sanitationItems = [
    'All equipment/utensils/rooms clean',
    'Employees wearing proper attire',
    'Pest control program functional',
    'All garbage removed / properly stored',
    'Foot bath in place',
    'There is sufficient hot/cold water',
    'Washrooms are stocked and clean',
    'Intervention PPM',
  ];

  late List<CheckState> temperatureStates;
  late List<CheckState> sanitationStates;

  // Saved Reports List
  final List<Map<String, dynamic>> savedReports = [];

  // Editing index
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    temperatureStates =
        List.generate(temperatureItems.length, (_) => CheckState.none);
    sanitationStates =
        List.generate(sanitationItems.length, (_) => CheckState.none);
  }

  @override
  void dispose() {
    scrollController.dispose();
    dateCtrl.dispose();
    signController.dispose();
    super.dispose();
  }

  // Cycle through states
  CheckState _nextState(CheckState s) {
    switch (s) {
      case CheckState.none:
        return CheckState.tick;
      case CheckState.tick:
        return CheckState.cross;
      case CheckState.cross:
        return CheckState.none;
    }
  }

  Color _stateColor(CheckState s) {
    switch (s) {
      case CheckState.tick:
        return Colors.green;
      case CheckState.cross:
        return Colors.red;
      case CheckState.none:
        return Colors.grey.shade600;
    }
  }

  IconData _stateIcon(CheckState s) {
    switch (s) {
      case CheckState.tick:
        return Icons.check_circle;
      case CheckState.cross:
        return Icons.cancel;
      case CheckState.none:
        return Icons.remove_circle_outline;
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateCtrl.text = DateFormat('d/M/yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _saveReport() async {
    if (dateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select report date')),
      );
      return;
    }

    Uint8List? sigBytes;
    if (!signController.isEmpty) {
      sigBytes = await signController.toPngBytes();
    }

    final id = 'REP-${DateTime.now().millisecondsSinceEpoch}';

    final Map<String, dynamic> report = {
      'id': id,
      'date': dateCtrl.text,
      'temp': temperatureStates.map((e) => e.index).toList(),
      'sani': sanitationStates.map((e) => e.index).toList(),
      'signature': sigBytes,
    };

    setState(() {
      if (editingIndex == null) {
        savedReports.insert(0, report);
      } else {
        report['id'] = savedReports[editingIndex!]['id'];
        savedReports[editingIndex!] = report;
        editingIndex = null;
      }
      _resetForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report saved successfully")),
    );
  }

  void _resetForm() {
    dateCtrl.clear();
    signController.clear();
    editingIndex = null;
    temperatureStates =
        List.generate(temperatureItems.length, (_) => CheckState.none);
    sanitationStates =
        List.generate(sanitationItems.length, (_) => CheckState.none);
    setState(() {});
  }

  // LOAD EDITED REPORT → MOVE FORM TO TOP
  void _loadReportForEdit(int index) {
    final r = savedReports[index];
    editingIndex = index;

    dateCtrl.text = r['date'];
    temperatureStates =
        (r['temp'] as List).map((i) => CheckState.values[i]).toList();
    sanitationStates =
        (r['sani'] as List).map((i) => CheckState.values[i]).toList();

    signController.clear();

    setState(() {});

    // SCROLL INSTANTLY TO TOP FORM
    Future.delayed(const Duration(milliseconds: 200), () {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _deleteReport(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                savedReports.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  Map<String, int> _counts(List<int> t, List<int> s) {
    int tick = 0, cross = 0, none = 0;
    for (var i in [...t, ...s]) {
      if (i == CheckState.tick.index) tick++;
      else if (i == CheckState.cross.index) cross++;
      else none++;
    }
    return {"tick": tick, "cross": cross, "none": none};
  }

  Widget _statusCell(CheckState s) {
    return Row(
      children: [
        Icon(_stateIcon(s), color: _stateColor(s), size: 18),
        const SizedBox(width: 4),
        Text(
          s == CheckState.tick ? "Tick" : s == CheckState.cross ? "Cross" : "Null",
          style: TextStyle(color: _stateColor(s)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          width: 220, // <- Width limit so title wraps in 2 lines
          child: Text(
            "Pre-Slaughter Operational Status Report",
            textAlign: TextAlign.center,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1.2,
            ),
          ),
        ),
      ),


      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- FORM HEADING A ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Form",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
            ),
            const SizedBox(height: 10),

            // ---------------- FORM CARD ----------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DATE
                  TextField(
                    controller: dateCtrl,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: "Report Date",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ------------ Temperature --------------
                  Text("Temperature", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 6),
                  _buildItemsTable(temperatureItems, temperatureStates, (i) {
                    setState(() => temperatureStates[i] = _nextState(temperatureStates[i]));
                  }),
                  const SizedBox(height: 12),

                  // ------------ Sanitation --------------
                  Text("Sanitation / Protocols",
                      style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 6),
                  _buildItemsTable(sanitationItems, sanitationStates, (i) {
                    setState(() => sanitationStates[i] = _nextState(sanitationStates[i]));
                  }),
                  const SizedBox(height: 12),

                  // SIGNATURE
                  Text("Signature",
                      style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 6),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: Signature(controller: signController, backgroundColor: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => signController.clear(),
                        child: const Text("Clear Signature"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _resetForm,
                        child: const Text("Reset Form"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: gold),
                      onPressed: _saveReport,
                      child: Text(
                        editingIndex == null ? "Save Report" : "Update Report",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- FILTER HEADING 2 ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Saved Reports",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
            ),
            const SizedBox(height: 10),

            savedReports.isEmpty
                ? Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: gold),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("No reports saved yet"),
            )
                : Column(
              children: List.generate(savedReports.length, (i) {
                return _buildReportCard(i, savedReports[i]);
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(
      List<String> labels, List<CheckState> states, Function(int) onTap) {
    return Column(
      children: List.generate(labels.length, (i) {
        return InkWell(
          onTap: () => onTap(i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: i.isOdd ? Colors.grey.shade100 : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(child: Text(labels[i])),
                SizedBox(width: 120, child: _statusCell(states[i])),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReportCard(int idx, Map<String, dynamic> r) {
    final t = List<int>.from(r['temp']);
    final s = List<int>.from(r['sani']);
    final counts = _counts(t, s);
    final Uint8List? sig = r['signature'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text("Report ID: ${r['id']}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
              ),
              Text(r['date'], style: const TextStyle(color: Colors.black54)),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Chip(label: Text("✔ ${counts['tick']}")),
              const SizedBox(width: 6),
              Chip(label: Text("✘ ${counts['cross']}")),
              const SizedBox(width: 6),
              Chip(label: Text("— ${counts['none']}")),
              const Spacer(),
              IconButton(
                  onPressed: () => _loadReportForEdit(idx),
                  icon: const Icon(Icons.edit, color: Colors.blue)),
              IconButton(
                  onPressed: () => _deleteReport(idx),
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),

          const SizedBox(height: 12),

          // Temperature table
          Text("Temperature",
              style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
            child: Column(
              children: List.generate(temperatureItems.length, (i) {
                final st = CheckState.values[t[i]];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(temperatureItems[i])),
                      SizedBox(width: 120, child: _statusCell(st)),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          Text("Sanitation / Protocols",
              style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
            child: Column(
              children: List.generate(sanitationItems.length, (i) {
                final st = CheckState.values[s[i]];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(sanitationItems[i])),
                      SizedBox(width: 120, child: _statusCell(st)),
                    ],
                  ),
                );
              }),
            ),
          ),

          if (sig != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Text("Signature: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Container(
                    width: 140,
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26)),
                    child: Image.memory(sig, fit: BoxFit.contain),
                  )
                ],
              ),
            ),
        ]),
      ),
    );
  }
}
