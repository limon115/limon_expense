import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text('Expense Breakdown', style: TextStyle(color: Colors.white70)),
            Expanded(
              child: GlassCard(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 40,
                    sections: _getSections(app, 'expense'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Income Breakdown', style: TextStyle(color: Colors.white70)),
            Expanded(
              child: GlassCard(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 40,
                    sections: _getSections(app, 'income'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(AppProvider app, String type) {
    final Map<String, double> data = {};
    for (var tx in app.transactions.where((t) => t.type == type)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }

    if (data.isEmpty) return [PieChartSectionData(value: 1, color: Colors.grey.withOpacity(0.2), title: 'None')];

    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    int i = 0;
    return data.entries.map((e) => PieChartSectionData(
      value: e.value,
      title: e.key,
      radius: 50,
      color: colors[i++ % colors.length],
      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
    )).toList();
  }
}