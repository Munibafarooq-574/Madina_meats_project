// lib/preventive_maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PreventiveMaintenanceScreen extends StatefulWidget {
  const PreventiveMaintenanceScreen({super.key});

  @override
  State<PreventiveMaintenanceScreen> createState() =>
      _PreventiveMaintenanceScreenState();
}

class _PreventiveMaintenanceScreenState
    extends State<PreventiveMaintenanceScreen> {
  // Theme
  final Color gold = const Color(0xFFD6C28F);
  final Color background = const Color(0xFFF8F5E8);

  // Months and items
  final List<String> monthShort = const [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  final List<String> items = [
    "Thermometer calibration",
    "Refrig. units",
    "Rails & ceiling",
    "Fan & heating units",
    "Rollers",
    "Sanitizers",
    "All walls",
    "All doors",
    "Knock box",
    "Lights (all rooms)",
    "UV system",
    "Stunners",
    "Biro saw",
    "Barns & pens",
    "Propane System",
    "Fire Extinguisher",
    "Hoists",
    "First aid kit",
    "Pest Control",
  ];

  // Controllers / state
  final TextEditingController filledByCtrl = TextEditingController();
  final TextEditingController yearFilterCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // tableData[item] -> { 'frequency': String, 'months': { 'Jan': bool, ... } }
  late Map<String, Map<String, dynamic>> tableData;

  // savedRecords: list of records (deep copies)
  final List<Map<String, dynamic>> savedRecords = [];
  int _nextId = 1;

  // Filters (UI / applied)
  String? filterMonth;
  String? appliedMonth;
  String? appliedYear;
  int? editingId;
  // Frequency color map
  final Map<String, Color> freqColors = {
    'M': Colors.red,
    '3M': Colors.black,
    '6M': Colors.green,
    'Y': Colors.blue,
  };

  @override
  void initState() {
    super.initState();

    // ------------------ ADD DUMMY SAVED RECORDS ------------------
    savedRecords.addAll([
      {
        'id': _nextId++,
        'filledBy': "Ali Raza",
        'date': DateTime(2025, 01, 10).toIso8601String(),
        'year': "2025",
        'details': {
          for (var it in items)
            it: {
              'frequency': 'M',
              'months': {
                for (var m in monthShort)
                  m: (m == "Jan" || m == "Feb") // Just sample selected months
              }
            }
        }
      },
      {
        'id': _nextId++,
        'filledBy': "Hamza Khan",
        'date': DateTime(2025, 02, 18).toIso8601String(),
        'year': "2025",
        'details': {
          for (var it in items)
            it: {
              'frequency': '6M',
              'months': {
                for (var m in monthShort)
                  m: (m == "Mar" || m == "Apr") // Sample ticks
              }
            }
        }
      }
    ]);

    // Reset form after adding dummy
    _resetForm();
  }

  @override
  void dispose() {
    filledByCtrl.dispose();
    yearFilterCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    editingId = null;
    tableData = {
      for (var it in items)
        it: {
          'frequency': '',
          'months': {for (var m in monthShort) m: false},
        }
    };
    filledByCtrl.clear();
    selectedDate = DateTime.now();
    setState(() {});
  }

  void _toggleMonth(String item, String month) {
    setState(() {
      final months = tableData[item]!['months'] as Map<String, bool>;
      months[month] = !(months[month] ?? false);
    });
  }

  void _saveRecord() {
    final filledBy = filledByCtrl.text.trim();
    if (filledBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter 'Filled By'")),
      );
      return;
    }

    final details = <String, Map<String, dynamic>>{};
    for (var it in items) {
      final freq = (tableData[it]!['frequency'] ?? '') as String;
      final months = Map<String, bool>.from(tableData[it]!['months'] as Map);
      details[it] = {'frequency': freq, 'months': months};
    }

    // ⭐ IF EDITING → UPDATE RECORD
    if (editingId != null) {
      final index = savedRecords.indexWhere((e) => e['id'] == editingId);

      if (index != -1) {
        savedRecords[index] = {
          'id': editingId, // keep same ID
          'filledBy': filledBy,
          'date': selectedDate.toIso8601String(),
          'year': selectedDate.year.toString(),
          'details': details,
        };
      }
    }
    // ⭐ ELSE CREATE NEW RECORD
    else {
      savedRecords.insert(0, {
        'id': _nextId++,
        'filledBy': filledBy,
        'date': selectedDate.toIso8601String(),
        'year': selectedDate.year.toString(),
        'details': details,
      });
    }

    _resetForm();
    setState(() {});
  }

  void _loadRecordForEditing(Map<String, dynamic> rec) {
    editingId = rec['id'];
    filledByCtrl.text = rec['filledBy'];
    selectedDate = DateTime.parse(rec['date']);

    final details = rec['details'] as Map<String, dynamic>;
    for (var it in items) {
      tableData[it]!['frequency'] = details[it]!['frequency'];
      tableData[it]!['months'] =
      Map<String, bool>.from(details[it]!['months']);
    }

    setState(() {});
  }

  void _deleteRecord(int id) {
    savedRecords.removeWhere((e) => e['id'] == id);
    setState(() {});
  }

  // FILTERING
  List<Map<String, dynamic>> get filteredRecords {
    final String? month = appliedMonth;
    final String year = appliedYear ?? '';

    return savedRecords.where((rec) {
      bool monthMatch = true;
      bool yearMatch = true;

      if (month != null && month.isNotEmpty) {
        monthMatch = false;
        final details = rec['details'] as Map<String, dynamic>;
        for (var it in details.keys) {
          final itemMonths = (details[it]!['months'] ?? {}) as Map;
          if (itemMonths.containsKey(month) && itemMonths[month] == true) {
            monthMatch = true;
            break;
          }
        }
      }

      if (year.isNotEmpty) {
        yearMatch = (rec['year'] as String? ?? '') == year;
      }

      return monthMatch && yearMatch;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // ⭐ SHOW RECORD DETAILS (NEW)
  void _showRecordDetails(Map<String, dynamic> rec) {
    final details = rec['details'] as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Text(
                  "Record Details",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Text("Filled By: ${rec['filledBy']}",
                    style: const TextStyle(fontSize: 16)),
                Text(
                  "Date: ${DateFormat('d MMM yyyy').format(DateTime.parse(rec['date']))}",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),
                const Divider(),

                const Text(
                  "Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: items.map((it) {
                      final freq = details[it]!['frequency'];
                      final months = details[it]!['months'] as Map<String, bool>;

                      final selectedMonths = months.entries
                          .where((e) => e.value == true)
                          .map((e) => e.key)
                          .join(", ");

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 4),
                            Text("Frequency: $freq"),
                            Text("Months: ${selectedMonths.isEmpty ? "None" : selectedMonths}"),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // UI building -------------------------------------------------------
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
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Preventive Maintenance",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Schedule Form",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildFormBox(),
          const SizedBox(height: 20),
          _buildFilterBox(),
          const SizedBox(height: 20),
          _buildSavedRecordBox(),
        ]),
      ),
    );
  }

  Widget _buildFormBox() {
    return Container(
      height: 470,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: gold, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Form",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            flex: 6,
            child: TextField(
              controller: filledByCtrl,
              decoration: InputDecoration(
                labelText: 'Filled By',
                prefixIcon: const Icon(Icons.person),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                child: Text(DateFormat('d MMM yyyy').format(selectedDate)),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 14),

        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 6),
                  Column(
                      children:
                      items.map((it) => _buildTableRow(it)).toList()),
                ]),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _resetForm,
              style: ElevatedButton.styleFrom(backgroundColor: gold),
              child: const Text("Clear Form",
                  style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveRecord,
              icon: const Icon(Icons.save),
              label: const Text('Save Record'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: gold, foregroundColor: Colors.black),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildHeaderRow() {
    return Row(children: [
      _headerCell("Item", 180),
      _headerCell("Freq", 70),
      ...monthShort.map((m) => _headerCell(m, 75)).toList(),
    ]);
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      height: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(text,
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTableRow(String item) {
    final freq = tableData[item]!['frequency'] as String;
    final Color cellColor = freqColors[freq] ?? Colors.grey.shade200;

    return Row(children: [
      Container(
        width: 180,
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(item),
      ),

      // Frequency dropdown
      Container(
        width: 70,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: freq.isEmpty ? null : freq,
            items: ['M', '3M', '6M', 'Y']
                .map((f) =>
                DropdownMenuItem(value: f, child: Center(child: Text(f))))
                .toList(),
            onChanged: (v) {
              setState(() => tableData[item]!['frequency'] = v ?? '');
            },
            hint: const SizedBox.shrink(),
          ),
        ),
      ),

      ...monthShort.map((m) {
        final bool isTick =
            (tableData[item]!['months'] as Map<String, bool>)[m] ?? false;
        return GestureDetector(
          onTap: () => _toggleMonth(item, m),
          child: Container(
            width: 75,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isTick ? cellColor.withOpacity(0.25) : Colors.transparent,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: isTick
                  ? const Icon(Icons.check, size: 18)
                  : const SizedBox.shrink(),
            ),
          ),
        );
      }).toList(),
    ]);
  }

  Widget _buildFilterBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "Filter Saved Records",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: filterMonth,
              decoration: const InputDecoration(
                labelText: "Month",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text("All")),
                ...monthShort.map(
                      (m) => DropdownMenuItem(value: m, child: Text(m)),
                ),
              ],
              onChanged: (v) {
                setState(() => filterMonth = v);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: yearFilterCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Year",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ]),

        const SizedBox(height: 10),

        Row(children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                appliedMonth = filterMonth;
                appliedYear = yearFilterCtrl.text.trim().isEmpty
                    ? null
                    : yearFilterCtrl.text.trim();
              });
            },
            child: const Text("Apply Filter"),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              setState(() {
                filterMonth = null;
                yearFilterCtrl.clear();
                appliedMonth = null;
                appliedYear = null;
              });
            },
            child: const Text("Clear Filter"),
          ),
        ]),
      ]),
    );
  }

  // ⭐ UPDATED: CARD WITH TAP TO OPEN DETAILS
  Widget _buildSavedRecordBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: gold, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saved Records",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (filteredRecords.isEmpty)
            const Text("No records found",
                style: TextStyle(fontSize: 16, color: Colors.grey)),

          ...filteredRecords.map((rec) {
            return GestureDetector(
              onTap: () => _showRecordDetails(rec),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ID: ${rec['id']}  |  ${rec['filledBy']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('d MMM yyyy')
                              .format(DateTime.parse(rec['date'])),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // EDIT + DELETE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _loadRecordForEditing(rec);
                          },
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text("Edit",
                              style: TextStyle(color: Colors.blue)),
                        ),
                        const SizedBox(width: 6),
                        TextButton.icon(
                          onPressed: () {
                            _deleteRecord(rec['id']);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
