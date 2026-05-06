import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../provider.dart';
import '../models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final txs = prov.activeWallet.transactions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      children: [
        const Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        _buildPieCard('Expense Categories', txs, 'expense', prov.state.currency),
        const SizedBox(height: 20),
        _buildPieCard('Income Categories', txs, 'income', prov.state.currency),
      ],
    );
  }

  Widget _buildPieCard(String title, List<Transaction> txs, String type, String currency) {
    Map<String, double> catAgg = {};
    for (var tx in txs) {
      if (tx.type == type) {
        catAgg[tx.category] = (catAgg[tx.category] ?? 0) + tx.amount;
      }
    }

    List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.cyan, Colors.indigo, Colors.teal, Colors.purple, Colors.orange];
    int colorIdx = 0;
    
    catAgg.forEach((cat, val) {
      sections.add(PieChartSectionData(
        value: val,
        title: cat,
        color: colors[colorIdx % colors.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      colorIdx++;
    });

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: sections.isEmpty 
              ? const Center(child: Text('No Data', style: TextStyle(color: Colors.white70)))
              : PieChart(PieChartData(sections: sections, centerSpaceRadius: 40)),
          ),
        ],
      ),
    );
  }
}
