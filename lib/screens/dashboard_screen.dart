import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final currency = app.settings?.currency ?? '\$';
    
    double income = app.transactions.where((t) => t.type == 'income').fold(0.0, (a, b) => a + b.amount);
    double expense = app.transactions.where((t) => t.type == 'expense').fold(0.0, (a, b) => a + b.amount);
    double balance = income - expense;
    double budget = app.settings?.monthlyBudget ?? 0.0;
    double budgetProgress = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back', style: TextStyle(color: Colors.white70)),
                  Text(app.settings?.userName ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              GlassButton(
                onTap: () => _showWalletPicker(context, app),
                child: Text(app.activeWallet.name),
              )
            ],
          ),
          const SizedBox(height: 25),
          GlassCard(
            child: Column(
              children: [
                const Text('Total Balance', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                Text('$currency${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _statBox('Income', '+$currency${income.toStringAsFixed(2)}', Colors.greenAccent),
                    const SizedBox(width: 15),
                    _statBox('Expense', '-$currency${expense.toStringAsFixed(2)}', Colors.redAccent),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Budget Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: budgetProgress,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 25),
          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          ...app.transactions.map((tx) => _transactionItem(tx, currency, app)).toList(),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(dynamic tx, String cur, AppProvider app) {
    bool isInc = tx.type == 'income';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(isInc ? Icons.arrow_downward : Icons.arrow_upward, color: isInc ? Colors.greenAccent : Colors.redAccent)),
          title: Text(tx.title),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(tx.date)),
          trailing: Text('${isInc ? '+' : '-'}$cur${tx.amount.toStringAsFixed(2)}', 
            style: TextStyle(fontWeight: FontWeight.bold, color: isInc ? Colors.greenAccent : Colors.redAccent)),
          onLongPress: () => app.deleteTx(tx.id),
        ),
      ),
    );
  }

  void _showWalletPicker(BuildContext context, AppProvider app) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (_) => GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Switch Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ...app.wallets.asMap().entries.map((e) => ListTile(
              title: Text(e.value.name),
              onTap: () {
                app.setActiveWallet(e.key);
                Navigator.pop(context);
              },
            )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New Wallet'),
              onTap: () {
                Navigator.pop(context);
                // Trigger a simple dialog logic
              },
            )
          ],
        ),
      )
    );
  }
}