import 'package:flutter/material.dart';
import 'customer_order_details.dart';

class CustomerOngoingOrdersScreen extends StatefulWidget {
  const CustomerOngoingOrdersScreen({super.key});

  @override
  State<CustomerOngoingOrdersScreen> createState() =>
      _CustomerOngoingOrdersScreenState();
}

class _CustomerOngoingOrdersScreenState
    extends State<CustomerOngoingOrdersScreen> {
  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);

  final TextEditingController searchController = TextEditingController();

  /// ALL ORDERS
  List<Map<String, dynamic>> orders = [
    {
      "id": "ORD-101",
      "type": "Beef",
      "qty": "5 KG",
      "status": "Pending",
      "date": "11 Jan 2025 - 3:00 PM",
    },
    {
      "id": "ORD-102",
      "type": "Goat",
      "qty": "2 KG",
      "status": "In Process",
      "date": "12 Jan 2025 - 6:30 PM",
    },
  ];

  /// STATIC SUGGESTION LIST (DUMMY DATA)
  List<String> allSuggestions = [
    "ORD-101 • Beef",
    "ORD-102 • Goat",
    "ORD-110 • Lamb",
    "ORD-205 • Beef",
    "ORD-330 • Chicken",
    "ORD-500 • Mutton",
  ];

  /// FILTERED SUGGESTIONS
  List<String> suggestions = [];

  List<Map<String, dynamic>> filteredOrders = [];
  String selectedStatus = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredOrders = List.from(orders);
  }

  // 🔍 APPLY FILTERS
  void applyFilters() {
    setState(() {
      filteredOrders = orders.where((order) {
        final matchesSearch =
            order['id'].toLowerCase().contains(searchQuery.toLowerCase()) ||
                order['type']
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                order['status']
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());

        final matchesStatus =
        selectedStatus == "All" ? true : order['status'] == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  // 🔍 SEARCH + SHOW SUGGESTIONS IMMEDIATELY
  void searchOrder(String query) {
    searchQuery = query;
    applyFilters();

    setState(() {
      if (query.isEmpty) {
        suggestions = [];
      } else {
        suggestions = allSuggestions
            .where((item) =>
            item.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }
    });
  }

  void filterByStatus(String status) {
    selectedStatus = status;
    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navy, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ongoing Orders",
          style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // 🔍 SEARCH FIELD
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: gold, width: 1.2),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: searchOrder,
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: navy),
                            hintText: "Search orders...",
                            hintStyle: TextStyle(color: navy.withOpacity(0.6)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // 🔽 SUGGESTION BOX
                      if (suggestions.isNotEmpty)
                        Positioned(
                          top: 55,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: gold),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              itemBuilder: (_, index) {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    suggestions[index],
                                    style: TextStyle(color: navy),
                                  ),
                                  onTap: () {
                                    String id = suggestions[index].split(" • ")[0];
                                    searchController.text = id;

                                    searchOrder(id);

                                    setState(() => suggestions = []);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 🔽 STATUS FILTER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gold, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      icon: Icon(Icons.filter_list, color: navy),
                      items: [
                        "All",
                        "Pending",
                        "In Process",
                        "Delivered",
                        "Cancelled"
                      ].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status, style: TextStyle(color: navy)),
                        );
                      }).toList(),
                      onChanged: (value) => filterByStatus(value!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📦 ORDER LIST
            Expanded(
              child: ListView.separated(
                itemCount: filteredOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final order = filteredOrders[i];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerOrderDetailsScreen(order: order),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: gold, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withOpacity(0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: extraGold.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_shipping_rounded,
                                size: 35, color: navy),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['id'],
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${order['type']} • ${order['qty']}",
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 18, color: navy),
                                    const SizedBox(width: 6),
                                    Text(
                                      order['date'],
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: navy, width: 1),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(
                                  color: navy, fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, size: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
