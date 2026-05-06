import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../provider.dart';
import '../models.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final txs = prov.activeWallet.transactions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      children: [
        const Text('Daily Trends', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        _buildChartCard('Expense Trends', txs, 'expense', Colors.redAccent, prov.state.currency),
        const SizedBox(height: 20),
        _buildChartCard('Income Trends', txs, 'income', Colors.cyan, prov.state.currency),
      ],
    );
  }

  Widget _buildChartCard(String title, List<Transaction> txs, String type, Color color, String currency) {
    final now = DateTime.now();
    Map<int, double> dailyAgg = {};
    for (int i = 0; i < 7; i++) {
      dailyAgg[now.subtract(Duration(days: i)).day] = 0;
    }

    for (var tx in txs) {
      if (tx.type == type && now.difference(tx.date).inDays < 7) {
        dailyAgg[tx.date.day] = (dailyAgg[tx.date.day] ?? 0) + tx.amount;
      }
    }

    List<BarChartGroupData> groups = [];
    List<int> sortedDays = dailyAgg.keys.toList()..sort();
    for (int i = 0; i < sortedDays.length; i++) {
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: dailyAgg[sortedDays[i]]!, color: color, width: 16, borderRadius: BorderRadius.circular(4))
      ]));
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const Text('Last 7 Days', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
