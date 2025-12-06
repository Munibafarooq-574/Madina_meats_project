import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:madina_meats/driver_app/screens/driver_home_screens.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:madina_meats/core/global/invoice_history.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const InvoicePreviewScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final sig = order['signature'] as Uint8List?;
    final img = order['image'] as Uint8List?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5E8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DriverDashboard()),
                (route) => false,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Invoice Preview",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Invoice Detail",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          Text("Order ID: ${order['id']}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          /// CUSTOMER NAME
          _buildBoldField("Customer: ", order['customer']),
          _buildBoldField("Address: ", order['address']),
          const SizedBox(height: 6),
          _buildBoldField("Type: ", "${order['type']}"),
          _buildBoldField("Quantity: ", "${order['quantity']}"),
          _buildBoldField("Driver ID: ", "${order['driverId']}"),
          const SizedBox(height: 6),

          /// DELIVERY DATE
          _buildBoldField(
            "Delivered At: ",
            order['deliveredAt'] != null
                ? DateFormat('dd MMM yyyy – hh:mm a')
                .format(order['deliveredAt'])
                : "Pending",
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD6C28F)),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer Signature:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                sig != null
                    ? Image.memory(sig, height: 150)
                    : Text("No signature",
                    style: GoogleFonts.poppins(color: Colors.grey)),

                const SizedBox(height: 12),

                if (img != null) ...[
                  Text("Delivery Image:",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Image.memory(img, height: 150),
                ],

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// SAVE INVOICE
                    ElevatedButton(
                      onPressed: () {
                        // Mark order completed
                        order["status"] = "completed";

// Add to history list
                        customerHistoryOrders.add(order);

// Return the updated order to Driver Dashboard
                        Navigator.pop(context, order);

// Confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invoice saved to history")),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6C28F),
                        foregroundColor: Colors.black,
                      ),
                      child: Text("Save Invoice",
                          style: GoogleFonts.poppins()),
                    ),

                    /// DOWNLOAD PDF
                    ElevatedButton(
                      onPressed: () async {
                        final pdf = await _generatePdf(order, sig, img);
                        await Printing.layoutPdf(
                            onLayout: (format) async => pdf);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF344955),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Download PDF",
                          style: GoogleFonts.poppins()),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BOLD / NORMAL FIELD WIDGET
  Widget _buildBoldField(String title, String value) {
    return RichText(
      text: TextSpan(
        text: title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// PDF GENERATOR
  Future<Uint8List> _generatePdf(
      Map<String, dynamic> order, Uint8List? sig, Uint8List? img) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Madina Meats Invoice",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            pw.Text("Customer: ${order['customer']}"),
            pw.Text("Address: ${order['address']}"),
            pw.Text("Type: ${order['type']}"),
            pw.Text("Driver ID: ${order['driverId']}"),
            pw.Text("Quantity: ${order['quantity']}"),
            pw.Text("Delivered At: ${order['deliveredAt']}"),

            pw.SizedBox(height: 20),

            if (sig != null) pw.Image(pw.MemoryImage(sig), height: 120),
            pw.SizedBox(height: 20),
            if (img != null) pw.Image(pw.MemoryImage(img), height: 120),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
