// lib/admin_ante_mortem_form.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminAnteMortemForm extends StatefulWidget {
  const AdminAnteMortemForm({super.key});

  @override
  State<AdminAnteMortemForm> createState() => _AdminAnteMortemFormState();
}

class _AdminAnteMortemFormState extends State<AdminAnteMortemForm> {
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color background = const Color(0xFFF8F5E8);

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _beefQty = TextEditingController();
  final TextEditingController _lambQty = TextEditingController();
  final TextEditingController _goatQty = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // TEXT FIELD CONTROLLERS
  final TextEditingController _owner = TextEditingController();
  final TextEditingController _inspector = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  String _formatMeat(Map meatMap) {
    List<String> items = [];

    meatMap.forEach((type, qty) {
      if (qty != null && qty.toString().trim().isNotEmpty) {
        items.add("$type: $qty");
      }
    });

    if (items.isEmpty) return "None";

    return items.join(", ");
  }

  final List<Map<String, dynamic>> _savedEntries = [];

  @override
  void dispose() {
    _owner.dispose();
    _inspector.dispose();
    _signatureController.dispose();
    _scrollController.dispose();
    _beefQty.dispose();
    _lambQty.dispose();
    _goatQty.dispose();

    super.dispose();
  }

  // ✅ CLEAR ALL FIELDS FUNCTION
  void _clearAllFields() {
    _owner.clear();
    _inspector.clear();

    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();

    });

    _signatureController.clear();
  }

  @override
  void initState() {
    super.initState();

    final Uint8List fakeSignature = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x10,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0xF3, 0xFF,
      0x61, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
      0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0xCB, 0xD2,
      0xA1, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
      0x44, 0xAE, 0x42, 0x60, 0x82
    ]);

    _savedEntries.addAll([
      {
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "time": "10:30 AM",
        "owner": "Muhammad Ali",
        "meatType": {
          "Beef": "10",
          "Lamb": "",
          "Goat": ""
        },
        "inspector": "Dr. Ahmed",
        "signature": fakeSignature,
        "createdAt":
        DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        "date": DateTime.now().subtract(const Duration(days: 2)),
        "time": "03:45 PM",
        "owner": "Zainab Farm",
        "meatType": {
          "Beef": "",
          "Lamb": "",
          "Goat": "5"
        },
        "inspector": "Inspector Bilal",
        "signature": fakeSignature,
        "createdAt":
        DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      },
      {
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "time": "09:10 AM",
        "owner": "Al-Madina Traders",
        "meatType": {
          "Beef": "",
          "Lamb": "3",
          "Goat": ""
        },
        "inspector": "Dr. Sana",
        "signature": fakeSignature,
        "createdAt":
        DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      },
    ]);

  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _saveEntry({bool autoSync = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final Uint8List? signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide inspector signature.")),
      );
      return;
    }

    final Map<String, String> meatMap = {
      "Beef": _beefQty.text.trim(),
      "Lamb": _lambQty.text.trim(),
      "Goat": _goatQty.text.trim(),
    };

    final entry = {
      "date": _selectedDate,
      "time": _selectedTime.format(context),
      "owner": _owner.text.trim(),
      "meatType": meatMap,
      "inspector": _inspector.text.trim(),
      "signature": signatureBytes,
      "createdAt": DateTime.now(),
    };


    setState(() => _savedEntries.add(entry));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(autoSync ? "Auto-synced (simulated)." : "Record saved."),
      ),
    );
  }

  Future<Uint8List> _generatePdf(Map<String, dynamic> entry) async {
    final pdf = pw.Document();
    final Uint8List sigBytes = entry["signature"];

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Ante Mortem Report",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Date: ${DateFormat.yMMMd().format(entry['date'])}"),
              pw.Text("Time: ${entry['time']}"),
              pw.Text("Owner Name: ${entry['owner']}"),
              pw.Text(
                "Meat Type: ${_formatMeat(entry['meatType'])}",
              ),

              pw.Text("Inspector Name: ${entry['inspector']}"),
              pw.SizedBox(height: 20),
              pw.Text("Inspector Signature:"),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(sigBytes), width: 200, height: 80),
              pw.SizedBox(height: 20),
              pw.Text(
                "Recorded At: ${DateFormat.yMd().add_jm().format(entry['createdAt'])}",
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Widget _buildMeatRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void _showPdfOptions(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
                child: Text(
                  "Choose Action",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),


              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          content: const Text("What do you want to do with the PDF?"),

          actions: [
            TextButton(
              child: const Text("Download PDF"),
              onPressed: () async {
                Navigator.pop(context);
                final bytes = await _generatePdf(entry);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename:
                  "AnteMortem_${DateTime.now().millisecondsSinceEpoch}.pdf",
                );
              },
            ),
            TextButton(
              child: const Text("Print PDF"),
              onPressed: () async {
                Navigator.pop(context);
                final bytes = await _generatePdf(entry);
                await Printing.layoutPdf(onLayout: (_) => bytes);
              },
            ),
          ],
        );
      },
    );
  }



  Widget _buildSavedEntryCard(Map<String, dynamic> entry, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: gold),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${DateFormat.yMMMd().format(entry["date"])} • ${entry['time']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Owner: ${entry['owner']}"),
                Text("Meat: ${_formatMeat(entry['meatType'])}"),
                Text("Inspector: ${entry['inspector']}"),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.picture_as_pdf, color: navy),
                onPressed: () => _showPdfOptions(entry),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _savedEntries.removeAt(index)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Ante Mortem Report",
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: navy),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: gold),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, color: navy),
                                const SizedBox(width: 10),

                                const Text(
                                  "Date : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text(DateFormat.yMMMd().format(_selectedDate)),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: navy),
                                const SizedBox(width: 10),

                                const Text(
                                  "Time : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text(_selectedTime.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _owner,
                      decoration: const InputDecoration(
                        labelText: "Owner Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Enter owner name" : null,
                    ),

                    const SizedBox(height: 14),

                    // --------------- CUSTOM MEAT TYPE WITH QUANTITY ---------------
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Meat Type & Quantity",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildMeatRow("Beef", _beefQty),
                          const SizedBox(height: 10),

                          _buildMeatRow("Lamb", _lambQty),
                          const SizedBox(height: 10),

                          _buildMeatRow("Goat", _goatQty),
                        ],
                      ),
                    ),


                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _inspector,
                      decoration: const InputDecoration(
                        labelText: "Inspector Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Enter inspector name" : null,
                    ),

                    const SizedBox(height: 16),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Inspector Signature:"),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: navy),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Signature(
                        controller: _signatureController,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _clearAllFields,
                          child: const Text("Clear"),
                        ),
                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: Colors.black),
                          onPressed: () => _saveEntry(autoSync: false),
                          child: const Text("Save"),
                        ),
                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => _saveEntry(autoSync: true),
                          child: const Text("Save & Sync"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Records",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: navy,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),

            _savedEntries.isEmpty
                ? Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold),
              ),
              child: const Text("No records added yet."),
            )
                : Column(
              children: List.generate(
                _savedEntries.length,
                    (i) => _buildSavedEntryCard(_savedEntries[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
