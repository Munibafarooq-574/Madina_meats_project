// lib/admin_ante_mortem_form.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

  // Form controllers
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _owner = TextEditingController();
  String _meatType = "Beef";
  final TextEditingController _inspector = TextEditingController();

  // Signature controller from package
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  // Local storage of saved entries (in-memory for now)
  final List<Map<String, dynamic>> _savedEntries = [];

  @override
  void dispose() {
    _owner.dispose();
    _inspector.dispose();
    _signatureController.dispose();
    super.dispose();
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
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  // Save locally (in-memory) and simulate autosync
  Future<void> _saveEntry({bool autoSync = false}) async {
    if (!_formKey.currentState!.validate()) return;

    // get signature bytes
    final Uint8List? signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide inspector signature.")));
      return;
    }

    final entry = {
      "date": _selectedDate,
      "time": _selectedTime.format(context),
      "owner": _owner.text.trim(),
      "meatType": _meatType,
      "inspector": _inspector.text.trim(),
      "signature": signatureBytes,
      "createdAt": DateTime.now(),
    };

    setState(() => _savedEntries.add(entry));

    if (autoSync) {
      // simulate sync
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Auto-synced to server (simulated).")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved locally.")));
    }

    // optional: clear form (but keep signature to show)
    // _owner.clear(); _inspector.clear(); _signatureController.clear();
  }

  // Export a single entry to PDF and open print/save dialog
  Future<void> _exportEntryToPdf(Map<String, dynamic> entry) async {
    final pdf = pw.Document();
    final sigBytes = entry['signature'] as Uint8List;

    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) => pw.Container(
          padding: const pw.EdgeInsets.all(18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Ante Mortem Record Form", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Date: ${DateFormat.yMMMd().format(entry['date'] as DateTime)}"),
              pw.Text("Time: ${entry['time']}"),
              pw.Text("Owner Name: ${entry['owner']}"),
              pw.Text("Meat Type: ${entry['meatType']}"),
              pw.Text("Inspector Name: ${entry['inspector']}"),
              pw.SizedBox(height: 16),
              pw.Text("Inspector Signature:"),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(sigBytes), width: 200, height: 100),
              pw.SizedBox(height: 18),
              pw.Text("Recorded At: ${DateFormat.yMd().add_jm().format(entry['createdAt'] as DateTime)}"),
            ],
          ),
        ),
      ),
    );

    final pdfBytes = await pdf.save();

    // show print/save/share dialog
    await Printing.layoutPdf(onLayout: (format) => pdfBytes);
  }

  // UI helper to show saved entries list
  Widget _buildSavedEntryCard(Map<String, dynamic> e, int idx) {
    final dt = e['date'] as DateTime;
    final time = e['time'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 1.3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${DateFormat.yMMMd().format(dt)} • $time", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
              const SizedBox(height: 6),
              Text("Owner: ${e['owner']}"),
              Text("Meat: ${e['meatType']}"),
              Text("Inspector: ${e['inspector']}"),
            ]),
          ),
          Column(children: [
            IconButton(
              onPressed: () => _exportEntryToPdf(e),
              icon: Icon(Icons.picture_as_pdf, color: navy),
              tooltip: "Export to PDF",
            ),
            IconButton(
              onPressed: () {
                // simple delete
                setState(() => _savedEntries.removeAt(idx));
              },
              icon: Icon(Icons.delete_forever, color: Colors.red),
              tooltip: "Delete",
            ),
          ]),
        ],
      ),
    );
  }

  // Build the form UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text("Ante Mortem Form", style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: navy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold, width: 1.4),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Date & time row
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Date"),
                              subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                              trailing: IconButton(
                                icon: Icon(Icons.calendar_month, color: navy),
                                onPressed: _pickDate,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Time"),
                              subtitle: Text(_selectedTime.format(context)),
                              trailing: IconButton(
                                icon: Icon(Icons.access_time, color: navy),
                                onPressed: _pickTime,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Owner
                      TextFormField(
                        controller: _owner,
                        decoration: InputDecoration(
                          labelText: "Owner name",
                          labelStyle: TextStyle(color: navy),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold, width: 2)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter owner name" : null,
                      ),

                      const SizedBox(height: 12),

                      // Meat type dropdown
                      DropdownButtonFormField<String>(
                        value: _meatType,
                        decoration: InputDecoration(
                          labelText: "Meat type",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold, width: 2)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Beef", child: Text("Beef")),
                          DropdownMenuItem(value: "Lamb", child: Text("Lamb")),
                          DropdownMenuItem(value: "Goat", child: Text("Goat")),
                        ],
                        onChanged: (v) => setState(() => _meatType = v ?? "Beef"),
                      ),

                      const SizedBox(height: 12),

                      // Inspector name
                      TextFormField(
                        controller: _inspector,
                        decoration: InputDecoration(
                          labelText: "Inspector name",
                          labelStyle: TextStyle(color: navy),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold, width: 2)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter inspector name" : null,
                      ),

                      const SizedBox(height: 14),

                      // Signature pad
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Inspector signature (draw below)"),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: navy.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child: Signature(
                              controller: _signatureController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _signatureController.clear(),
                                icon: const Icon(Icons.clear),
                                label: const Text("Clear"),
                                style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _saveEntry(autoSync: false);
                                },
                                icon: const Icon(Icons.save),
                                label: const Text("Save"),
                                style: ElevatedButton.styleFrom(backgroundColor: navy),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _saveEntry(autoSync: true);
                                },
                                icon: const Icon(Icons.sync),
                                label: const Text("Save & Sync"),
                                style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Saved entries list
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Saved Records", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
              ),
              const SizedBox(height: 8),

              if (_savedEntries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: gold)),
                  child: const Text("No records yet."),
                )
              else
                Column(
                  children: List.generate(_savedEntries.length, (i) => _buildSavedEntryCard(_savedEntries[i], i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
