import 'package:flutter/material.dart';
import 'customer_order_details.dart';
import 'package:madina_meats/core/global/invoice_history.dart';
class CustomerHistoryOrdersScreen extends StatelessWidget {
  CustomerHistoryOrdersScreen({super.key});

  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);
  final orders = customerHistoryOrders;


  @override
  Widget build(BuildContext context) {
    final orders = customerHistoryOrders.reversed.toList(); // latest first
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
          "Order History",
          style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final order = orders[i];
            final id = order['id'] ?? "No ID";
            final type = order['type'] ?? "N/A";
            final qty = order['quantity']?.toString() ?? "0";
            final date = order['date'] ?? "No Date";
            final status = order['status'] ?? "Unknown";

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerOrderDetailsScreen(order: {
                      "id": order["id"] ?? "",
                      "customer": order["customer"] ?? "",
                      "address": order["address"] ?? "",
                      "type": order["type"] ?? order["items"]?.split(" ").first,
                      "quantity": order["quantity"] ?? order["items"],
                      "driverId": order["driverId"] ?? "",
                      "datetime": order["datetime"],
                      "status": order["status"] ?? "",
                      "image": order["image"],
                      "signature": order["signature"],
                      "deliveredAt": order["deliveredAt"],
                    }),

                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold, width: 1.2),
                ),

                child: Row(
                  children: [
                    // ICON...
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(id,
                              style: TextStyle(
                                color: navy,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 4),

                          Text("$type • $qty",
                              style: TextStyle(color: Colors.black87, fontSize: 16)),

                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 18, color: navy),
                              SizedBox(width: 6),
                              Text(date,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status,
                          style: TextStyle(
                              color: navy, fontWeight: FontWeight.bold)),
                    ),

                    SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 28),
                  ],
                ),
              ),
            );
          },

        ),
      ),
    );
  }
}
