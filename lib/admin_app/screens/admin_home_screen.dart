
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_drivers_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_reports_screen.dart';

class AdminHomeDashboard extends StatefulWidget {
  const AdminHomeDashboard({super.key});

  @override
  State<AdminHomeDashboard> createState() => _AdminHomeDashboardState();
}

class _AdminHomeDashboardState extends State<AdminHomeDashboard> {
  final Color navy = const Color(0xFF2C3E50);
  final Color gold = const Color(0xFFD4AF37);
  final Color background = const Color(0xFFF4EFE6);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> driverList = [
    {"id": "DR001", "name": "Ali Khan", "phone": "0301-1234567"},
    {"id": "DR002", "name": "Ahmed", "phone": "0302-7654321"},
    {"id": "DR003", "name": "Bilal", "phone": "0305-9988776"},
    {"id": "DR004", "name": "Sana", "phone": "0303-5551112"},
  ];

  final List<Map<String, String>> customerList = [
    {"id": "CU001", "name": "Fatima", "phone": "0311-1112223"},
    {"id": "CU002", "name": "Hira", "phone": "0321-2223334"},
    {"id": "CU003", "name": "Zainab", "phone": "0331-3334445"},
    {"id": "CU004", "name": "Bilquis", "phone": "0341-4445556"},
  ];

  final List<Map<String, String>> orderList = [
    {"orderId": "ORD-1001", "customer": "Fatima", "status": "Delivered"},
    {"orderId": "ORD-1002", "customer": "Hira", "status": "Pending"},
    {"orderId": "ORD-1003", "customer": "Zainab", "status": "Shipped"},
    {"orderId": "ORD-1004", "customer": "Ali Khan", "status": "Cancelled"},
  ];

  final List<Map<String, String>> reportList = [
    {"id": "R001", "title": "Daily Sales Report"},
    {"id": "R002", "title": "Monthly Revenue Report"},
    {"id": "R003", "title": "Driver Performance Report"},
  ];

  late final List<Map<String, Object>> tileData;
  final List<double> flipAngles = [0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    tileData = [
      {
        "icon": Icons.local_shipping_rounded,
        "title": "Drivers",
        "desc": "Manage driver accounts and details.",
        "screen": const AdminDriversScreen(),
      },
      {
        "icon": Icons.people_alt_rounded,
        "title": "Customers",
        "desc": "View and manage customer records.",
        "screen": const AdminCustomersScreen(),
      },
      {
        "icon": Icons.shopping_cart_checkout_rounded,
        "title": "Orders",
        "desc": "Track and manage all orders & invoices.",
        "screen": const AdminOrdersScreen(),
      },
      {
        "icon": Icons.bar_chart_rounded,
        "title": "Reports",
        "desc": "Generate business insights and reports.",
        "screen": const AdminReportsScreen(),
      },
    ];
  }

  void toggleFlip(int index) {
    setState(() {
      flipAngles[index] = flipAngles[index] == 0 ? pi : 0;
    });
  }

  // ---------------- GLOBAL SEARCH ----------------
  List<Map<String, dynamic>> get globalResults {
    final q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return [];

    final List<Map<String, dynamic>> results = [];

    for (final item in tileData) {
      final title = (item['title'] as String).toLowerCase();
      final desc = (item['desc'] as String).toLowerCase();
      if (title.contains(q) || desc.contains(q)) {
        results.add({
          "type": "Dashboard",
          "title": item['title'],
          "subtitle": item['desc'],
          "screen": item['screen'],
        });
      }
    }

    for (final d in driverList) {
      if (d['name']!.toLowerCase().contains(q) ||
          d['phone']!.toLowerCase().contains(q) ||
          d['id']!.toLowerCase().contains(q)) {
        results.add({
          "type": "Driver",
          "title": d['name']!,
          "subtitle": "${d['id']} • ${d['phone']}",
          "screen": const AdminDriversScreen(),
        });
      }
    }

    for (final c in customerList) {
      if (c['name']!.toLowerCase().contains(q) ||
          c['phone']!.toLowerCase().contains(q) ||
          c['id']!.toLowerCase().contains(q)) {
        results.add({
          "type": "Customer",
          "title": c['name']!,
          "subtitle": "${c['id']} • ${c['phone']}",
          "screen": const AdminCustomersScreen(),
        });
      }
    }

    for (final o in orderList) {
      if (o['orderId']!.toLowerCase().contains(q) ||
          o['customer']!.toLowerCase().contains(q)) {
        results.add({
          "type": "Order",
          "title": o['orderId']!,
          "subtitle": "${o['customer']} • ${o['status']}",
          "screen": const AdminOrdersScreen(),
        });
      }
    }

    for (final r in reportList) {
      if (r['title']!.toLowerCase().contains(q)) {
        results.add({
          "type": "Report",
          "title": r['title']!,
          "subtitle": "",
          "screen": const AdminReportsScreen(),
        });
      }
    }

    return results;
  }

  // ---------------- FLIP CARD ----------------
  Widget buildFlipTile(int index) {
    final double angle = flipAngles[index];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: angle),
      duration: const Duration(milliseconds: 360),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => tileData[index]['screen'] as Widget));
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
                      icon: Icon(Icons.rotate_left,
                          color: gold, size: 22),
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final results = globalResults;

    return Scaffold(
      backgroundColor: background,

      // ⭐ NEW BACK BUTTON ADDED HERE
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
                "Admin Panel",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: navy),
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
                hintText:
                "Search Drivers, Customers, Orders, Reports...",
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
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
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
                  border:
                  Border.all(color: gold.withOpacity(0.9)),
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
                  separatorBuilder: (_, __) =>
                  const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final item = results[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        navy.withOpacity(0.08),
                        child: Text(
                          (item['type'] as String)[0],
                          style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: (item['subtitle'] as String)
                          .isNotEmpty
                          ? Text(item['subtitle'] as String)
                          : null,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['type'] as String,
                          style: TextStyle(
                              color: gold,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              item['screen'] as Widget),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

          // GRID
          if (results.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: GridView.builder(
                  itemCount: tileData.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
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
