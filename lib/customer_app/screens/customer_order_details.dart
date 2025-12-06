import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CustomerOrderDetailsScreen extends StatelessWidget {
  final Map order;

  CustomerOrderDetailsScreen({super.key, required this.order});

  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color background = const Color(0xFFF8F5E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Details",
          style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detail("Order ID", order["id"]),
                  _detail("Type", order["type"]),
                  _detail("Quantity", order["quantity"] ?? order["qty"]),
                  _detail(
                    "Delivery Time",
                    order["deliveredAt"] != null
                        ? DateFormat('dd MMM yyyy – hh:mm a').format(order["deliveredAt"])
                        : "Pending",
                  ),
                  _detail("Delivery Address", order["deliveryAddress"] ?? "N/A"),
                  _detail("Driver ID", order["driverId"]),
                ],
              ),
            ),



            const SizedBox(height: 20),

            Text("Customer Signature", style: _titleStyle()),
            const SizedBox(height: 6),

            _infoBox(
              height: 140,
              child: order["signature"] == null
                  ? const Center(
                child: Text("Signature Image Here",
                    style: TextStyle(color: Colors.black54)),
              )
                  : Image.memory(
                order["signature"],
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            Text("Invoice Image (Uploaded by Driver)", style: _titleStyle()),
            const SizedBox(height: 6),

            _infoBox(
              height: 180,
              child: order["image"] == null
                  ? const Center(child: Text("No Invoice Image"))
                  : Image.memory(order["image"], fit: BoxFit.cover),
            ),



            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: _btnStyle(),
                    onPressed: () async {
                      final pdfBytes = await _generatePdf(order);

                      await savePdfLocally(pdfBytes, "${order['id']}.pdf");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("PDF Downloaded Successfully!")),
                      );
                    },

                    child: const Text("Download PDF"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: _btnStyle(),
                    onPressed: () {
                      Printing.layoutPdf(
                        onLayout: (format) async => await _generatePdf(order),
                      );
                    },
                    child: const Text("Print Invoice"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------------- PDF GENERATION -------------------------------


  Future<void> savePdfLocally(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/$fileName";

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    print("PDF Saved at: $filePath");
  }

  Future<Uint8List> _generatePdf(Map order) async {
    final pdf = pw.Document();



    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Order Invoice",
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),

                pw.SizedBox(height: 20),

                pw.Text("Order ID: ${order['id']}"),
                /// ⭐ Add this line
                pw.Text("Customer Name: ${order['customerName'] ?? 'N/A'}"),
                pw.Text("Type: ${order['type'] ?? 'N/A'}"),
                pw.Text("Quantity: ${order['quantity'] ?? '0'}"),

                pw.Text(
                  "Delivery Time: ${order['deliveredAt'] != null
                      ? DateFormat('dd MMM yyyy – hh:mm a').format(order['deliveredAt'])
                      : 'No Date'}",
                ),

                pw.Text("Delivery Address: ${order['address'] ?? 'N/A'}"),



                pw.Text("Driver ID: ${order['driverId'] ?? 'N/A'}"),


                pw.SizedBox(height: 20),
                pw.Text("Signature:", style: pw.TextStyle(fontSize: 16)),
                pw.Container(
                  height: 80,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                  ),
                  child: pw.Center(child: pw.Text("Signature Here")),
                ),

                pw.SizedBox(height: 20),
                pw.Text("Invoice Image:", style: pw.TextStyle(fontSize: 16)),
                order["image"] == null
                    ? pw.Text("No Invoice Image")
                    : pw.Container(
                  height: 200,
                  child: pw.Image(
                    pw.MemoryImage(order["image"]),
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ------------------------------- UI HELPERS -------------------------------

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: gold,
      foregroundColor: navy,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: navy, width: 1),
      ),
    );
  }

  Widget _detail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: navy, fontWeight: FontWeight.bold, fontSize: 15)),
          Text((value ?? "").toString(),
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }


  TextStyle _titleStyle() {
    return TextStyle(
      color: navy,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _infoBox({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
