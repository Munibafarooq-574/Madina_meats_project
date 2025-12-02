import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);

  // Dummy Orders List
  List<Map<String, dynamic>> orders = [
    {
      "id": "ORD-1001",
      "date": "2025-01-25 3:45 PM",
      "type": "Beef",
      "quantity": "2",
      "notes": "No fat",
      "status": "Pending",
      "customer": "Ali Raza",
      "address": "Lahore"
    },
    {
      "id": "ORD-1002",
      "date": "2025-01-26 1:15 PM",
      "type": "Goat",
      "quantity": "1",
      "notes": "Well cleaned",
      "status": "Completed",
      "customer": "Hina Khan",
      "address": "Islamabad"
    }
  ];

  // Update Order Status
  void updateStatus(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Update Status",
                    style: TextStyle(
                        fontSize: 22,
                        color: navy,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Status Buttons
                Wrap(
                  spacing: 12,
                  children: [
                    statusButton("Pending", index),
                    statusButton("Completed", index),
                    statusButton("Cancel", index),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget statusButton(String text, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          orders[index]["status"] = text;
        });
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }

  // Generate Invoice PDF
  Future<Uint8List> generateInvoicePDF(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("INVOICE",
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 15),

              pw.Text("Order ID: ${order["id"]}"),
              pw.Text("Customer: ${order["customer"]}"),
              pw.Text("Address: ${order["address"]}"),
              pw.Text("Date: ${order["date"]}"),

              pw.SizedBox(height: 20),

              pw.Text("Order Details:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),

              pw.Text("Meat Type: ${order["type"]}"),
              pw.Text("Quantity: ${order["quantity"]}"),
              pw.Text("Notes: ${order["notes"]}"),
              pw.Text("Status: ${order["status"]}"),

              pw.SizedBox(height: 30),
              pw.Text("Customer Signature: ________________"),
              pw.Text("Driver ID: DRV-001"),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // Invoice Popup (View & Download)
  void openInvoice(Map<String, dynamic> order) {
    Printing.layoutPdf(onLayout: (_) => generateInvoicePDF(order));
  }

  // Order Details Dialog
  void viewOrderDetails(Map<String, dynamic> order, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order Details",
                    style: TextStyle(
                        fontSize: 24,
                        color: navy,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                detailText("Order ID", order["id"]),
                detailText("Customer", order["customer"]),
                detailText("Address", order["address"]),
                detailText("Date", order["date"]),
                detailText("Type", order["type"]),
                detailText("Quantity", order["quantity"]),
                detailText("Notes", order["notes"]),
                detailText("Status", order["status"]),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => updateStatus(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Update Status",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => openInvoice(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Invoice PDF",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "$title: $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("Orders",
            style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: navy),
      ),

      // ORDER LIST
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold, width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: navy.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              title: Text(order["id"],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: navy)),
              subtitle: Text(
                "Customer: ${order["customer"]}\nMeat: ${order["type"]} | Qty: ${order["quantity"]}\nStatus: ${order["status"]}",
              ),
              onTap: () => viewOrderDetails(order, index),
            ),
          );
        },
      ),
    );
  }
}
