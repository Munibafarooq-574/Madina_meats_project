// lib/driver_dashboard.dart
import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:madina_meats/driver_app/screens/InvoicePreviewScreen.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:madina_meats/core/global/invoice_history.dart';
/// DRIVER DASHBOARD (Admin-style flip tiles, Navy + Gold theme)
/// Single-file demo with dummy orders, signature capture, image upload,
/// complete flow and invoice preview. No backend.

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  // Theme colors (matching admin)
  final Color navy = const Color(0xFF2C3E50);
  final Color gold = const Color(0xFFD6C28F) ;
  final Color background = const Color(0xFFF4EFE6);

  final TextEditingController searchController = TextEditingController();

  // flip angles for 4 tiles (current, today, upcoming, completed)
  final List<double> flipAngles = [0, 0, 0, 0, 0];

  // Dummy orders shared by all screens (local mutable)
  final List<Map<String, dynamic>> orders = [
    {
      "id": "ORD-101",
      "customer": "Ali Khan",
      "address": "Street 12, Lahore",
      "type": "Beef",
      "quantity": "5kg",
      "datetime": DateTime.now(),
      "status": "current",
      "signature": null,
      "image": null,
      "driverId": "DR001",
    },
    {
      "id": "ORD-102",
      "customer": "Sara",
      "address": "Johar Town, Lahore",
      "type": "Mutton",
      "quantity": "3kg",
      "datetime": DateTime.now(),
      "status": "today",
      "signature": null,
      "image": null,
      "driverId": "DR001",
    },
    {
      "id": "ORD-103",
      "customer": "Hamza",
      "address": "DHA Phase 5",
      "type": "Beef",
      "quantity": "2kg",
      "datetime": DateTime.now().add(const Duration(days: 1)),
      "status": "upcoming",
      "signature": null,
      "image": null,
      "driverId": "DR001",
    },
    {
      "id": "ORD-104",
      "customer": "Ali Raza",
      "address": "Bahria Town",
      "type": "Beef",
      "quantity": "1kg",
      "datetime": DateTime.now().subtract(const Duration(days: 1)),
      "status": "completed",
      "signature": null,
      "image": null,
      "driverId": "DR001",
    },
    {
      "id": "ORD-105",
      "customer": "Bilal",
      "address": "Gulberg",
      "type": "Chicken",
      "quantity": "2kg",
      "datetime": DateTime.now().subtract(const Duration(days: 2)),
      "status": "cancelled",
      "signature": null,
      "image": null,
      "driverId": "DR001",
    },
  ];


  late final List<Map<String, Object>> tileData;

  @override
  void initState() {
    super.initState();
    tileData = [
      {
        "icon": Icons.local_shipping_rounded,
        "title": "Current",
        "desc": "Deliveries you must do right now.",
        "filter": "current",
      },
      {
        "icon": Icons.today,
        "title": "Today",
        "desc": "Deliveries scheduled for today.",
        "filter": "today",
      },
      {
        "icon": Icons.upcoming,
        "title": "Upcoming",
        "desc": "Scheduled for later / future.",
        "filter": "upcoming",
      },
      {
        "icon": Icons.check_circle_rounded,
        "title": "Completed",
        "desc": "Completed deliveries & invoices.",
        "filter": "completed",
      },
      {
        "icon": Icons.cancel_rounded,
        "title": "Cancelled",
        "desc": "Orders cancelled by admin or system.",
        "filter": "cancelled",
      },
    ];

  }

  void toggleFlip(int index) {
    setState(() {
      flipAngles[index] = flipAngles[index] == 0 ? pi : 0;
    });
  }

  List<Map<String, dynamic>> get filteredResults {
    final q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final o in orders) {
      if (o['id'].toLowerCase().contains(q) ||
          (o['customer'] as String).toLowerCase().contains(q) ||
          (o['address'] as String).toLowerCase().contains(q) ||
          (o['type'] as String).toLowerCase().contains(q)
          ) {
        results.add(o);
      }
    }
    return results;
  }

  Widget buildFlipTile(int index) {
    final double angle = flipAngles[index];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: angle),
      duration: const Duration(milliseconds: 400),
      builder: (context, val, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(val);
        final bool showingFront = val.abs() < (pi / 2);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              if (showingFront) {
                // navigate to list screen for this filter
                final filter = tileData[index]['filter'] as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrdersListScreen(
                      title: tileData[index]['title'] as String,
                      orders: orders,
                      filter: filter,
                      onUpdate: () {
                        setState(() {});
                      },
                    ),
                  ),
                ).then((_) => setState(() {}));
              } else {
                // tapped back side (do nothing)
              }
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: showingFront
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tileData[index]['icon'] as IconData,
                      size: 54, color: navy),
                  const SizedBox(height: 12),
                  Text(tileData[index]['title'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: navy)),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () => toggleFlip(index),
                      child: Icon(Icons.info_outline,
                          color: gold, size: 22),
                    ),
                  ),
                ],
              )
                  : Transform(
                transform: Matrix4.rotationY(pi),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tileData[index]['desc'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: navy)),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: Icon(Icons.rotate_left, color: gold, size: 22),
                      onPressed: () => toggleFlip(index),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // helper to get orders by status
  List<Map<String, dynamic>> getByStatus(String status) {
    return orders.where((o) => o['status'] == status).toList();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final results = filteredResults;

    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: navy, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Colors.white.withOpacity(0.36),
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Driver Panel",
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold, color: navy),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search orders, customer, address...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SEARCH RESULTS
          if (results.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gold.withOpacity(0.9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final o = results[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: navy.withOpacity(0.08),
                        child: Text(
                          (o['customer'] as String)[0],
                          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(o['id'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text("${o['customer']} • ${o['address']}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          o['status'].toString().toUpperCase(),
                          style: TextStyle(
                            color: o['status'] == 'cancelled'
                                ? Colors.red
                                : gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DriverOrderDetailScreen(
                              order: o,
                              onUpdate: (updated) {
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

          // GRID of flip tiles
          if (results.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: GridView.builder(
                  itemCount: tileData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    return buildFlipTile(index);
                  },
                ),
              ),
            ),
        ],
      ),

    );
  }
}

/// -------------------- ORDERS LIST SCREEN --------------------
class OrdersListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> orders;
  final String filter;
  final void Function() onUpdate;

  const OrdersListScreen({
    super.key,
    required this.title,
    required this.orders,
    required this.filter,
    required this.onUpdate,
  });

  List<Map<String, dynamic>> get filtered {
    if (filter == 'all') return orders;
    return orders.where((o) => o['status'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: list.isEmpty
          ? const Center(
        child: Text(
          "No orders here",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final o = list[i];
          final Color navy = const Color(0xFF2C3E50);
          final Color gold = const Color(0xFFD4AF37);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              leading: CircleAvatar(
                radius: 24,
                backgroundColor: navy.withOpacity(0.08),
                child: Text(
                  (o['customer'] as String)[0],
                  style: TextStyle(
                      color: navy, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              title: Text(
                o['id'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: navy,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "${o['customer']} • ${o['address']}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),

              trailing: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: gold, width: 1),
                ),
                child: Text(
                  o['status'].toString().toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: gold,
                  ),
                ),
              ),

              onTap: () {
                if (o['status'] == 'completed') {
                  // DIRECT OPEN INVOICE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoicePreviewScreen(order: o),
                    ),
                  );
                  return;
                }

                // NORMAL: open detail screen for pending orders
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverOrderDetailScreen(
                      order: o,
                      onUpdate: (updatedOrder) {
                        onUpdate();
                      },
                    ),
                  ),
                ).then((result) {
                  if (result == true) {
                    onUpdate(); // refresh after update
                  }
                });
              },




            ),
          );
        },
      ),

    );
  }
}

/// -------------------- DRIVER ORDER DETAIL --------------------
/// shows order details, signature capture, image, and complete button
class DriverOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final void Function(Map<String, dynamic>) onUpdate;

  const DriverOrderDetailScreen({
    super.key,
    required this.order,
    required this.onUpdate,
  });

  @override
  State<DriverOrderDetailScreen> createState() => _DriverOrderDetailScreenState();
}

class _DriverOrderDetailScreenState extends State<DriverOrderDetailScreen> {
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  Uint8List? selectedImage;
  Uint8List? signatureBytes;

  Future<void> pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final XFile? img =
    await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);

    if (img != null) {
      selectedImage = await img.readAsBytes();
      setState(() {});
    }
  }

  Future<void> completeDelivery() async {
    if (!signatureController.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture customer signature")),
      );
      return;
    }

    signatureBytes = await signatureController.toPngBytes();

    widget.order["status"] = "completed";
    widget.order["signature"] = signatureBytes;
    widget.order["image"] = selectedImage;
    widget.order["deliveredAt"] = DateTime.now();
    widget.order["date"] =
        DateFormat('dd MMM yyyy – hh:mm a').format(DateTime.now());

    // Save to customer app history
    customerHistoryOrders.removeWhere((e) => e["id"] == widget.order["id"]);
    customerHistoryOrders.add({...widget.order});

    // ⭐ THIS IS THE IMPORTANT LINE
    widget.onUpdate(widget.order);

    setState(() {});

    // Go to invoice
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(order: widget.order),
      ),
    );
  }


  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Order ${o['id']}",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F5E8),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          Text("Customer:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text(o['customer'], style: GoogleFonts.poppins()),
          const SizedBox(height: 10),

          Text("Address:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text(o['address'], style: GoogleFonts.poppins()),
          const SizedBox(height: 10),

          Text("Items:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text("${o['type']} – ${o['quantity']}", style: GoogleFonts.poppins()),
          const SizedBox(height: 10),

          Text("Date:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text(DateFormat('dd MMM yyyy – hh:mm a').format(o['datetime']),
              style: GoogleFonts.poppins()),
          const SizedBox(height: 20),

          Text("Customer Signature:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(controller: signatureController),
          ),
          TextButton(
            onPressed: () => signatureController.clear(),
            child: const Text("Clear Signature"),
          ),

          const SizedBox(height: 18),
          Text("Delivery Image (optional):",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => pickImage(true),
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: Text("Camera",
                    style: GoogleFonts.poppins(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6C28F),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => pickImage(false),
                icon: const Icon(Icons.photo, color: Colors.black),
                label: Text("Gallery",
                    style: GoogleFonts.poppins(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6C28F),
                ),
              ),
            ],
          ),

          if (selectedImage != null) ...[
            const SizedBox(height: 12),
            Image.memory(selectedImage!, height: 150),
          ],

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (!signatureController.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please capture customer signature")),
                );
                return;
              }

              signatureBytes = await signatureController.toPngBytes();

              widget.order["status"] = "completed";
              widget.order["signature"] = signatureBytes;
              widget.order["image"] = selectedImage;
              widget.order["deliveredAt"] = DateTime.now();
              widget.order["date"] =
                  DateFormat('dd MMM yyyy – hh:mm a').format(DateTime.now());

              // Save to customer history
              customerHistoryOrders.removeWhere((e) => e["id"] == widget.order["id"]);
              customerHistoryOrders.add({...widget.order});

              // Return TRUE so list screen updates
              Navigator.pop(context, true);
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6C28F),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              "Complete Delivery",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (o['status'] == 'completed')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoicePreviewScreen(order: o),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6C28F),
              ),
              child: Text(
                "View Invoice",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}



/// ----------------- ENTRY/MAIN -----------------
/// You can launch this DriverDashboard from your app main (example below).
/// If you want to run this file directly, use this main():
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DriverDashboard(),
  ));
}
