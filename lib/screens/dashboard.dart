import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:intl/intl.dart';
import '../provider.dart';
import '../models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final state = prov.state;
    final wallet = prov.activeWallet;
    final transactions = wallet.transactions;

    double income = 0;
    double expense = 0;
    double monthExpense = 0;
    final now = DateTime.now();

    for (var tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expense += tx.amount;
        if (tx.date.month == now.month && tx.date.year == now.year) {
          monthExpense += tx.amount;
        }
      }
    }

    double balance = income - expense;
    double budgetProgress = (wallet.budget > 0) ? (monthExpense / wallet.budget) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(state.user, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            GestureDetector(
              onTap: () => _showWalletSwitcher(context, prov),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wallet, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(wallet.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                '${state.currency}${balance.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _statItem('Income', '+${state.currency}${income.toStringAsFixed(2)}', Colors.greenAccent),
                  const SizedBox(width: 12),
                  _statItem('Expense', '-${state.currency}${expense.toStringAsFixed(2)}', Colors.redAccent),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('${(budgetProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: budgetProgress.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wallet.budget > 0 
                  ? '${state.currency}${(wallet.budget - monthExpense).toStringAsFixed(2)} remaining'
                  : 'Set budget in settings',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Center(padding: EdgeInsets.all(40), child: Text('No transactions yet', style: TextStyle(color: Colors.white70))),
        ...transactions.reversed.take(20).map((tx) => _txItem(context, tx, state.currency, prov)).toList(),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _txItem(BuildContext context, Transaction tx, String currency, AppProvider prov) {
    final isInc = tx.type == 'income';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(isInc ? Icons.arrow_downward : Icons.arrow_upward, color: isInc ? Colors.cyan : Colors.redAccent)),
          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text('${DateFormat('MMM dd').format(tx.date)} • ${tx.category}', style: const TextStyle(color: Colors.white70)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isInc ? "+" : "-"}$currency${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(color: isInc ? Colors.cyan : Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => prov.deleteTransaction(tx.id), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletSwitcher(BuildContext context, AppProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Switch Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const Divider(color: Colors.white24),
            ...prov.state.wallets.values.map((w) => ListTile(
              title: Text(w.name, style: const TextStyle(color: Colors.white)),
              trailing: prov.state.activeWalletId == w.id ? const Icon(Icons.check_circle, color: Colors.cyan) : null,
              onTap: () { prov.switchWallet(w.id); Navigator.pop(context); },
            )),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Create New Wallet', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showCreateWallet(context, prov);
              },
            )
          ],
        ),
      ),
    );
  }

  void _showCreateWallet(BuildContext context, AppProvider prov) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text('New Wallet', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Wallet Name', hintStyle: TextStyle(color: Colors.white54))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () { prov.createWallet(ctrl.text); Navigator.pop(context); }, child: const Text('Create', style: TextStyle(color: Colors.cyan))),
        ],
      ),
    );
  }
}
