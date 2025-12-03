// lib/admin_reports_screen.dart
import 'package:flutter/material.dart';
import 'admin_ante_mortem_form.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  final Color navy = const Color(0xFF344955);
  final Color gold = const Color(0xFFD6C28F);
  final Color background = const Color(0xFFF8F5E8);

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: navy),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: navy, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text("Will implement later."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reports = [
      {"title": "Ante Mortem Record Form", "icon": Icons.pets, "route": "ante"},
      {"title": "Pre-Slaughter Operational Status Report", "icon": Icons.report, "route": "soon"},
      {"title": "Equipment Maintenance Report", "icon": Icons.build_circle, "route": "soon"},
      {"title": "Sanitation/Temperature Tasklist", "icon": Icons.thermostat, "route": "soon"},
      {"title": "Pre Operational Checklist", "icon": Icons.checklist_rtl, "route": "soon"},
      {"title": "Pest Control", "icon": Icons.bug_report, "route": "soon"},
      {"title": "Shipping Records", "icon": Icons.local_shipping, "route": "soon"},
      {"title": "Preventive Maintenance Schedule", "icon": Icons.schedule, "route": "soon"},
      {"title": "SRT/Tag Record", "icon": Icons.label_important, "route": "soon"},
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Report Management",
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: navy,
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: reports.map((r) {
            return _buildTile(
              context: context,
              icon: r["icon"],
              title: r["title"],
              onTap: () {
                if (r["route"] == "ante") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAnteMortemForm()),
                  );
                } else {
                  _showComingSoon(context, r["title"]);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
