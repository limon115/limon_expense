import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:intl/intl.dart';
import '../provider.dart';
import '../models.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<String>> _categories = {
    'expense': ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Utilities', 'Other'],
    'income': ['Salary', 'Allowance', 'Business', 'Freelance', 'Investment', 'Gift', 'Bonus', 'Other']
  };

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueGrey, Colors.black], begin: Alignment.topLeft))),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))]),
                const Text('Add Transaction', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _typeBtn('expense', 'Expense', Colors.redAccent),
                          const SizedBox(width: 12),
                          _typeBtn('income', 'Income', Colors.cyan),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _inputField('Amount', _amountCtrl, isNumber: true, prefix: prov.state.currency),
                      _inputField('Title', _titleCtrl, isNumber: false),
                      const SizedBox(height: 16),
                      _label('Category'),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.blueGrey[900],
                          items: _categories[_type]!.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Date'),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                          if (d != null) setState(() => _selectedDate = d);
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _save,
                        child: const GlassCard(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: Text('Save Transaction', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String t, String label, Color color) {
    final active = _type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _type = t; _category = _categories[t]![0]; }),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Text(label, style: TextStyle(color: active ? color : Colors.white70, fontWeight: active ? FontWeight.bold : null))),
        ),
      ),
    );
  }

  Widget _label(String l) => Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(bottom: 8), child: Text(l.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)));

  Widget _inputField(String l, TextEditingController c, {bool isNumber = false, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l),
        GlassCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: c,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixText: prefix != null ? '$prefix ' : null,
              prefixStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _save() {
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt <= 0 || _titleCtrl.text.isEmpty) return;

    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amt,
      title: _titleCtrl.text,
      category: _category,
      date: _selectedDate,
    );

    context.read<AppProvider>().addTransaction(tx);
    Navigator.pop(context);
  }
}
