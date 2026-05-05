import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String? _category;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    final cats = _type == 'expense' ? app.expenseCategories : app.incomeCategories;
    _category ??= cats.first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueGrey, Colors.black], begin: Alignment.topLeft))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))]),
                  const Text('Add Transaction', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 30),
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _type = 'expense'),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(child: Text('Expense', style: TextStyle(color: _type == 'expense' ? Colors.redAccent : Colors.white))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _type = 'income'),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(child: Text('Income', style: TextStyle(color: _type == 'income' ? Colors.greenAccent : Colors.white))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Amount', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(hintText: 'Description', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          dropdownColor: Colors.black87,
                          items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (v) => setState(() => _category = v),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (d != null) setState(() => _date = d);
                          },
                          child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), 
                            child: Row(children: [const Icon(Icons.calendar_month, size: 18), const SizedBox(width: 10), Text(DateFormat('yyyy-MM-dd').format(_date))])),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            app.addTx(_titleCtrl.text, double.parse(_amountCtrl.text), _category!, _type, _date);
                            Navigator.pop(context);
                          },
                          child: const GlassCard(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: Text('Save Transaction', style: TextStyle(fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
