import 'package:flutter/material.dart';

class SrmTagRecordScreen extends StatefulWidget {
  @override
  State<SrmTagRecordScreen> createState() => _SrmTagRecordScreenState();
}

class _SrmTagRecordScreenState extends State<SrmTagRecordScreen> {
  final TextEditingController speciesCtrl = TextEditingController();
  final TextEditingController tagCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();

  String? over30Value;

  // ---------------------- DUMMY DATA ----------------------
  List<Map<String, String>> savedRows = [
    {
      "species": "Beef",
      "tag": "A-1021",
      "over30": "Yes",
      "customer": "John Smith"
    },
    {
      "species": "Lamb",
      "tag": "L-554",
      "over30": "No",
      "customer": "David Miller"
    },
    {
      "species": "Goat",
      "tag": "G-887",
      "over30": "No",
      "customer": "Sarah Lee"
    },
  ];

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
          "SRM/TAG RECORD",
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
                  _field("Species", speciesCtrl),
                  _field("Tag #", tagCtrl),
                  _dropdownField(),
                  _field("Customer Name", customerCtrl),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6C28F),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                    onPressed: saveRecord,
                    child: const Text("Save Record"),
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

                    const SizedBox(height: 12),

                    // --------- HORIZONTAL SCROLLABLE TABLE ----------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        border: TableBorder.all(color: Colors.black38),
                        columnWidths: const {
                          0: FixedColumnWidth(140),
                          1: FixedColumnWidth(140),
                          2: FixedColumnWidth(140),
                          3: FixedColumnWidth(200),
                          4: FixedColumnWidth(120),
                        },
                        children: [
                          // Header Row
                          TableRow(
                            decoration: BoxDecoration(color: Color(0xFFE9E4D6)),
                            children: const [
                              _tableHeader("Species"),
                              _tableHeader("Tag #"),
                              _tableHeader("Over 30 Month"),
                              _tableHeader("Customer Name"),
                              _tableHeader("Actions"),
                            ],
                          ),

                          // Data Rows
                          for (int i = 0; i < savedRows.length; i++)
                            TableRow(
                              children: [
                                _tableCell(savedRows[i]["species"]!),
                                _tableCell(savedRows[i]["tag"]!),
                                _tableCell(savedRows[i]["over30"]!),
                                _tableCell(savedRows[i]["customer"]!),

                                // ACTION BUTTONS
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Color(0xFF344955)),
                                        onPressed: () =>
                                            _showEditDialog(i),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _confirmDelete(i),
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

  // ---------------------- SAVE FUNCTION ----------------------
  void saveRecord() {
    if (speciesCtrl.text.isEmpty ||
        tagCtrl.text.isEmpty ||
        over30Value == null ||
        customerCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      savedRows.insert(0, {
        "species": speciesCtrl.text,
        "tag": tagCtrl.text,
        "over30": over30Value!,
        "customer": customerCtrl.text,
      });

      // Clear form
      speciesCtrl.clear();
      tagCtrl.clear();
      customerCtrl.clear();
      over30Value = null;
    });
  }

  // ---------------------- EDIT DIALOG ----------------------
  void _showEditDialog(int index) {
    var row = savedRows[index];

    TextEditingController species = TextEditingController(text: row["species"]);
    TextEditingController tag = TextEditingController(text: row["tag"]);
    TextEditingController customer = TextEditingController(text: row["customer"]);
    String? over30 = row["over30"];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Edit Record"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogField("Species", species),
                _dialogField("Tag #", tag),

                DropdownButtonFormField<String>(
                  value: over30,
                  decoration: InputDecoration(
                    labelText: "Over 30 Month",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Yes", "No"]
                      .map((e) => DropdownMenuItem(
                      value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => over30 = v,
                ),
                const SizedBox(height: 10),

                _dialogField("Customer", customer),
              ],
            ),
          ),

          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  savedRows[index] = {
                    "species": species.text,
                    "tag": tag.text,
                    "over30": over30 ?? "No",
                    "customer": customer.text,
                  };
                });

                Navigator.pop(ctx);
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }

  // ---------------------- DELETE CONFIRM ----------------------
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Record"),
        content: Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => savedRows.removeAt(index));
              Navigator.pop(ctx);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ---------------------- BASIC TEXT FIELD ----------------------
  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ---------------------- DROPDOWN Yes/No ----------------------
  Widget _dropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: over30Value,
        decoration: InputDecoration(
          labelText: "Over 30 Month (Yes / No)",
          border: OutlineInputBorder(),
        ),
        items: ["Yes", "No"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => over30Value = v),
      ),
    );
  }
}

// ---------------------- TABLE HELPERS ----------------------
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
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
