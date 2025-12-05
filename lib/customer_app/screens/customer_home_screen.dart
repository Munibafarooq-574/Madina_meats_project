import 'package:flutter/material.dart';
import 'customer_ongoing_orders.dart';
import 'customer_history_orders.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color extraGold = const Color(0xFFE8D3A2);
  final Color background = const Color(0xFFF8F5E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("Customer Home", style: TextStyle(color: navy)),
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _taskCard(
              context,
              title: "Ongoing Orders",
              subtitle: "Track your active delivery orders",
              icon: Icons.local_shipping_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerOngoingOrdersScreen()),
                );
              },
            ),

            const SizedBox(height: 18),

            _taskCard(
              context,
              title: "Order History",
              subtitle: "View all completed and past orders",
              icon: Icons.history_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  CustomerHistoryOrdersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 45, color: navy),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    )),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: TextStyle(fontSize: 15, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
