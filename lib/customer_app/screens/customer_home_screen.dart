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
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        // Responsive values
        double cardPadding = width < 360 ? 14 : 20;
        double iconSize = width < 360 ? 35 : 45;
        double titleSize = width < 360 ? 17 : 20;
        double subtitleSize = width < 360 ? 13 : 15;
        double spacing = width < 360 ? 12 : 18;

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Customer Panel",
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
                fontSize: width < 360 ? 18 : 22,
              ),
            ),
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
                      MaterialPageRoute(
                        builder: (_) => const CustomerOngoingOrdersScreen(),
                      ),
                    );
                  },
                  cardPadding: cardPadding,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  subtitleSize: subtitleSize,
                ),

                SizedBox(height: spacing),

                _taskCard(
                  context,
                  title: "Order History",
                  subtitle: "View all completed and past orders",
                  icon: Icons.history_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerHistoryOrdersScreen(),
                      ),
                    );
                  },
                  cardPadding: cardPadding,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  subtitleSize: subtitleSize,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _taskCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
        required double cardPadding,
        required double iconSize,
        required double titleSize,
        required double subtitleSize,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold, width: 1.2),
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
            Icon(icon, size: iconSize, color: navy),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.black54,
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
}
