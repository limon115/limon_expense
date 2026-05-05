import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Trends', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Expenses (Last 7 Days)', style: TextStyle(opacity: 0.7)),
            const SizedBox(height: 10),
            Expanded(
              child: GlassCard(
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barGroups: _getBarGroups(app, 'expense'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Income (Last 7 Days)', style: TextStyle(opacity: 0.7)),
            const SizedBox(height: 10),
            Expanded(
              child: GlassCard(
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barGroups: _getBarGroups(app, 'income'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(AppProvider app, String type) {
    // Logic to aggregate last 7 days from app.transactions
    return List.generate(7, (i) => BarChartGroupData(
      x: i,
      barRods: [BarChartRodData(toY: (i + 1) * 10.0, color: type == 'expense' ? Colors.redAccent : Colors.greenAccent, width: 15)],
    ));
  }
}