// lib/admin_app/screens/admin_orders_screen.dart
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // Theme colors (same family as other screens)
  final Color navy = const Color(0xFF2C3E50);
  final Color gold = const Color(0xFFD6C28F);
  final Color background = const Color(0xFFF4EFE6);

  // Dummy sample customers and drivers (you can replace with your real data)
  final List<Map<String, String>> customers = [
    {"id": "CU001", "name": "Ali Raza", "address": "Lahore", "phone": "0300-1112223"},
    {"id": "CU002", "name": "Muniba", "address": "Karachi", "phone": "0311-1234567"},
  ];

  final List<Map<String, String>> drivers = [
    {"id": "DR001", "name": "Ahmed"},
    {"id": "DR002", "name": "Bilal"},
  ];

  // Orders storage (in-memory)
  final List<Map<String, dynamic>> orders = [
    {
      "orderId": "ORD-1001",
      "itemType": "Beef",
      "quantity": 5,
      "notes": "Keep frozen",
      "deliveryDate": DateTime.now().add(const Duration(hours: 5)),
      "customerId": "CU001",
      "customerName": "Ali Raza",
      "address": "Lahore",
      "driverId": "DR001",
      "driverName": "Ahmed",
      "status": "Pending",
      "createdAt": DateTime.now(),
      "customerSignature": null,
    },
    {
      "orderId": "ORD-1002",
      "itemType": "Lamb",
      "quantity": 3,
      "notes": "Urgent delivery",
      "deliveryDate": DateTime.now().add(const Duration(hours: 8)),
      "customerId": "CU002",
      "customerName": "Muniba",
      "address": "Karachi",
      "driverId": "DR002",
      "driverName": "Bilal",
      "status": "Assigned",
      "createdAt": DateTime.now(),
      "customerSignature": null,
    },
    {
      "orderId": "ORD-1003",
      "itemType": "Goat",
      "quantity": 2,
      "notes": "",
      "deliveryDate": DateTime.now().add(const Duration(days: 1)),
      "customerId": "CU001",
      "customerName": "Ali Raza",
      "address": "Lahore",
      "driverId": "",
      "driverName": null,
      "status": "Delivered",
      "createdAt": DateTime.now(),
      "customerSignature": null,
    }
  ];


  // Search controller for orders (optional)
  final TextEditingController orderSearchCtrl = TextEditingController();

  // ---------- Helper: Order statuses ----------
  final List<String> statuses = ["Pending", "Assigned", "In Transit", "Delivered", "Cancelled"];

  // ---------- UI: Main ----------
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> visibleOrders = orderSearchCtrl.text.isEmpty
        ? orders.reversed.toList()
        : orders
        .where((o) =>
    (o['orderId'] as String).toLowerCase().contains(orderSearchCtrl.text.toLowerCase()) ||
        (o['customerName'] as String).toLowerCase().contains(orderSearchCtrl.text.toLowerCase()))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order Management",
          style: GoogleFonts.poppins(fontSize: 20, color: navy, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrderDialog(),
        backgroundColor: gold,
        foregroundColor: Colors.black,
        label: Text("Create Order", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search box
            TextField(
              controller: orderSearchCtrl,
              decoration: InputDecoration(
                hintText: "Search by order ID or customer name...",
                prefixIcon: Icon(Icons.search, color: navy),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Summary
            Row(
              children: [
                _summaryCard("Total Orders", orders.length.toString()),
                const SizedBox(width: 10),
                _summaryCard("Pending", orders.where((o) => o['status'] == "Pending").length.toString()),
                const SizedBox(width: 10),
                _summaryCard("Delivered", orders.where((o) => o['status'] == "Delivered").length.toString()),
              ],
            ),
            const SizedBox(height: 12),

            // Orders list
            Expanded(
              child: visibleOrders.isEmpty
                  ? Center(
                child: Text(
                  orders.isEmpty ? "No orders yet. Tap 'Create Order'." : "No results.",
                  style: TextStyle(color: navy.withOpacity(0.7)),
                ),
              )
                  : ListView.separated(
                itemCount: visibleOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final o = visibleOrders[i];
                  return _orderCard(o);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gold.withOpacity(0.9)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: navy.withOpacity(0.8))),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            children: [
              Expanded(
                child: Text(
                  "${o['orderId']} • ${o['itemType']} x${o['quantity']}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: navy),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(o['status']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  o['status'],
                  style: TextStyle(color: _statusColor(o['status']), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // details grid
          Row(
            children: [
              Expanded(child: Text("Customer: ${o['customerName']}", style: TextStyle(color: navy.withOpacity(0.9)))),
              Text(DateFormat.yMMMd().add_jm().format(o['deliveryDate']), style: TextStyle(color: navy.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 6),
          Text("Driver: ${o['driverName'] ?? 'Unassigned'}", style: TextStyle(color: navy.withOpacity(0.8))),
          const SizedBox(height: 6),
          Text("Address: ${o['address']}", style: TextStyle(color: navy.withOpacity(0.8))),
          const SizedBox(height: 8),

          // actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _openEditOrderDialog(existing: o),
                icon: Icon(Icons.edit, color: navy),
                label: Text("Edit", style: TextStyle(color: navy)),
              ),
              TextButton.icon(
                onPressed: () => _changeStatusDialog(o),
                icon: Icon(Icons.sync, color: navy),
                label: Text("Status", style: TextStyle(color: navy)),
              ),
              TextButton.icon(
                onPressed: () => _viewInvoice(o),
                icon: Icon(Icons.receipt_long, color: navy),
                label: Text("Invoice", style: TextStyle(color: navy)),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () => _confirmDeleteOrder(o),
                tooltip: "Delete order",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange.shade800;
      case "Assigned":
        return Colors.blue.shade700;
      case "In Transit":
        return Colors.purple.shade700;
      case "Delivered":
        return Colors.green.shade700;
      case "Cancelled":
        return Colors.red.shade700;
      default:
        return navy;
    }
  }

  // ---------- CREATE ORDER DIALOG ----------
  void _openCreateOrderDialog() {
    _openOrderForm();
  }

  // ---------- EDIT ORDER ----------
  void _openEditOrderDialog({required Map<String, dynamic> existing}) {
    _openOrderForm(editOrder: existing);
  }

  void _openOrderForm({Map<String, dynamic>? editOrder}) {
    // form controllers
    final _formKey = GlobalKey<FormState>();
    String itemType = editOrder?['itemType'] ?? 'Beef';
    final TextEditingController qtyCtrl = TextEditingController(text: editOrder != null ? editOrder['quantity'].toString() : '');
    final TextEditingController notesCtrl = TextEditingController(text: editOrder?['notes'] ?? '');
    DateTime deliveryDate = editOrder != null ? editOrder['deliveryDate'] as DateTime : DateTime.now().add(const Duration(days: 1));
    TimeOfDay deliveryTime = editOrder != null ? TimeOfDay.fromDateTime(editOrder['deliveryDate']) : TimeOfDay.now();
    String selectedCustomerId = editOrder?['customerId'] ?? customers.first['id']!;
    String selectedDriverId = editOrder?['driverId'] ?? '';
    final TextEditingController addressCtrl = TextEditingController(text: editOrder?['address'] ?? customers.first['address']!);
    final SignatureController sigController = SignatureController(penStrokeWidth: 2, penColor: Colors.black);

    // if editing and signature exists, load? we store bytes only; for simplicity skip loading existing
    if (editOrder != null && editOrder['customerSignature'] != null) {
      // You could set a preview or skip - for now we leave signature blank for edit
    }

    void pickDate() async {
      final d = await showDatePicker(
        context: context,
        initialDate: deliveryDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d != null) {
        setState(() {
          deliveryDate = DateTime(d.year, d.month, d.day, deliveryDate.hour, deliveryDate.minute);
        });
      }
    }

    void pickTime() async {
      final t = await showTimePicker(context: context, initialTime: deliveryTime);
      if (t != null) {
        setState(() {
          deliveryTime = t;
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          // update combined deliveryDate inside dialog when time/date changes
          DateTime combinedDate() {
            final dt = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day, deliveryTime.hour, deliveryTime.minute);
            return dt;
          }

          bool formValid() {
            if ((qtyCtrl.text.trim()).isEmpty) return false;
            if (int.tryParse(qtyCtrl.text.trim()) == null) return false;
            if (addressCtrl.text.trim().isEmpty) return false;
            // signature required for create (but optional for edit)
            if (editOrder == null) {
              if (sigController.isEmpty) return false;
            }
            return true;
          }

          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              editOrder == null ? "Create New Order" : "Edit Order ${editOrder['orderId']}",
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: navy),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              sigController.dispose();
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      // customer selector
                      DropdownButtonFormField<String>(
                        value: selectedCustomerId,
                        decoration: InputDecoration(labelText: "Customer", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        items: customers
                            .map((c) => DropdownMenuItem(value: c['id'], child: Text("${c['name']} (${c['id']})")))
                            .toList(),
                        onChanged: (v) => setStateDialog(() {
                          selectedCustomerId = v!;
                          // update address to selected customer default
                          final cust = customers.firstWhere((c) => c['id'] == selectedCustomerId);
                          addressCtrl.text = cust['address']!;
                        }),
                      ),
                      const SizedBox(height: 10),

                      // item type & qty
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: itemType,
                              decoration: InputDecoration(labelText: "Item type", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              items: const [
                                DropdownMenuItem(value: "Beef", child: Text("Beef")),
                                DropdownMenuItem(value: "Lamb", child: Text("Lamb")),
                                DropdownMenuItem(value: "Goat", child: Text("Goat")),
                              ],
                              onChanged: (v) => setStateDialog(() => itemType = v ?? "Beef"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: "Quantity", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // driver dropdown
                      DropdownButtonFormField<String>(
                        value: selectedDriverId.isEmpty ? null : selectedDriverId,
                        decoration: InputDecoration(labelText: "Assign Driver (optional)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        items: drivers.map((d) => DropdownMenuItem(value: d['id'], child: Text("${d['name']} (${d['id']})"))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedDriverId = v ?? ''),
                      ),
                      const SizedBox(height: 10),

                      // notes
                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(labelText: "Vehicle / Driver notes", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 10),

                      // address
                      TextFormField(
                        controller: addressCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(labelText: "Delivery address", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 10),

                      // date & time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final d = await showDatePicker(context: context, initialDate: combinedDate(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                                if (d != null) setStateDialog(() => deliveryDate = d);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(labelText: "Delivery date", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                child: Text(DateFormat.yMMMd().format(combinedDate())),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: deliveryTime);
                                if (t != null) setStateDialog(() => deliveryTime = t);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(labelText: "Delivery time", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                child: Text(deliveryTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // signature
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer signature", style: TextStyle(color: navy, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                            child: Signature(
                              controller: sigController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => sigController.clear(),
                                icon: const Icon(Icons.clear),
                                label: const Text("Clear"),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                editOrder == null ? "Signature required to create" : "Signature optional when editing",
                                style: TextStyle(color: navy.withOpacity(0.7)),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // save
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                            onPressed: formValid()
                                ? () async {
                              // build order object
                              final combined = combinedDate();
                              Uint8List? sigBytes;
                              if (sigController.isNotEmpty) {
                                sigBytes = await sigController.toPngBytes();
                              }

                              // if no signature and creation mode => block (shouldn't happen due to formValid)
                              if (editOrder == null && (sigBytes == null || sigBytes.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please capture signature")));
                                return;
                              }

                              if (editOrder == null) {
                                final id = "ORD-${DateTime.now().millisecondsSinceEpoch % 100000}";
                                orders.add({
                                  "orderId": id,
                                  "itemType": itemType,
                                  "quantity": int.parse(qtyCtrl.text.trim()),
                                  "notes": notesCtrl.text.trim(),
                                  "deliveryDate": combined,
                                  "customerId": selectedCustomerId,
                                  "customerName": customers.firstWhere((c) => c['id'] == selectedCustomerId)['name'],
                                  "address": addressCtrl.text.trim(),
                                  "driverId": selectedDriverId,
                                  "driverName": selectedDriverId.isEmpty ? null : drivers.firstWhere((d) => d['id'] == selectedDriverId)['name'],
                                  "status": selectedDriverId.isEmpty ? "Pending" : "Assigned",
                                  "createdAt": DateTime.now(),
                                  "customerSignature": sigBytes,
                                });
                              } else {
                                // update
                                editOrder['itemType'] = itemType;
                                editOrder['quantity'] = int.parse(qtyCtrl.text.trim());
                                editOrder['notes'] = notesCtrl.text.trim();
                                editOrder['deliveryDate'] = combined;
                                editOrder['address'] = addressCtrl.text.trim();
                                editOrder['driverId'] = selectedDriverId;
                                editOrder['driverName'] = selectedDriverId.isEmpty ? null : drivers.firstWhere((d) => d['id'] == selectedDriverId)['name'];
                                if (sigBytes != null) editOrder['customerSignature'] = sigBytes;
                                if (editOrder['status'] == null) editOrder['status'] = "Pending";
                              }

                              setState(() {});
                              sigController.dispose();
                              Navigator.pop(context);
                            }
                                : null,
                            child: Text(editOrder == null ? "Create Order" : "Save Changes"),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              sigController.dispose();
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ---------- Change status ----------
  void _changeStatusDialog(Map<String, dynamic> order) {
    String current = order['status'] as String;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((s) {
              return ListTile(
                title: Text(s),
                leading: Radio<String>(
                  value: s,
                  groupValue: current,
                  onChanged: (v) => setState(() {
                    current = v!;
                    order['status'] = current;
                    Navigator.pop(context);
                  }),
                ),
                onTap: () => setState(() {
                  current = s;
                  order['status'] = current;
                  Navigator.pop(context);
                }),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ---------- Delete order confirm ----------
  void _confirmDeleteOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Order"),
        content: Text("Delete ${order['orderId']}? This action can't be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF344955),
              foregroundColor: Colors.white,),
            onPressed: () {
              orders.remove(order);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ---------- View invoice ----------
  void _viewInvoice(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("Invoice • ${order['orderId']}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: navy))),
                      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _invoiceRow("Customer", "${order['customerName']}"),
                  _invoiceRow("Driver", order['driverName'] ?? "Unassigned"),
                  _invoiceRow("Item Type", order['itemType']),
                  _invoiceRow("Quantity", "${order['quantity']}"),
                  _invoiceRow("Delivery", DateFormat.yMMMd().add_jm().format(order['deliveryDate'])),
                  const SizedBox(height: 12),
                  Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 6),
                  Text(order['notes'] ?? "-", style: TextStyle(color: navy.withOpacity(0.8))),
                  const SizedBox(height: 12),

                  // signature preview
                  if (order['customerSignature'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer signature", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                          padding: const EdgeInsets.all(8),
                          child: Image.memory(order['customerSignature'] as Uint8List, height: 120),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openPdfOptions(order),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Download / Print PDF"),
                        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ---------- PDF generation ----------
  Future<Uint8List> _generatePdfBytes(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final Uint8List? sig = order['customerSignature'] as Uint8List?;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(18),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Madina Meats",
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text("Invoice: ${order['orderId']}"),
                pw.SizedBox(height: 10),

                pw.Text("Customer: ${order['customerName']}"),
                pw.Text("Driver: ${order['driverName'] ?? 'Unassigned'}"),
                pw.SizedBox(height: 8),

                pw.Table.fromTextArray(
                  headers: ["Item", "Quantity"],
                  data: [
                    [order['itemType'], "${order['quantity']}"],
                  ],
                ),

                pw.SizedBox(height: 12),
                pw.Text("Delivery: ${DateFormat.yMMMd().add_jm().format(order['deliveryDate'])}"),
                pw.Text("Address: ${order['address']}"),
                pw.SizedBox(height: 12),

                pw.Text("Notes:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(order['notes'] ?? ""),

                pw.Spacer(),

                if (sig != null)
                  pw.Column(
                    children: [
                      pw.Text("Customer signature:"),
                      pw.SizedBox(height: 8),
                      pw.Image(pw.MemoryImage(sig), width: 200, height: 80),
                    ],
                  ),

                pw.SizedBox(height: 18),
                pw.Divider(),
                pw.Text(
                  "Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  void _openPdfOptions(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("PDF Options"),
        content: const Text("Do you want to download or print this invoice?"),
        actions: [
          TextButton(
            child: const Text("Download"),
            onPressed: () async {
              Navigator.pop(context);
              final bytes = await _generatePdfBytes(order);
              await Printing.sharePdf(
                bytes: bytes,
                filename: "${order['orderId']}.pdf",
              );
            },
          ),
          ElevatedButton(
            child: const Text("Print"),
            onPressed: () async {
              Navigator.pop(context);
              final bytes = await _generatePdfBytes(order);
              await Printing.layoutPdf(
                onLayout: (_) async => bytes,
              );
            },
          ),
        ],
      ),
    );
  }

}
