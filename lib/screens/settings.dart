import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import '../provider.dart';
import '../models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final state = prov.state;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.cyan, child: Icon(Icons.code, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Khalid Hasan Limon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const Text('Lead Developer', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _settingInput('Profile Name', state.user, (v) => prov.updateSettings(name: v)),
              _settingDropdown('Currency', state.currency, ['\$', '€', '£', '₹', '¥', 'TK'], (v) => prov.updateSettings(currency: v)),
              _settingInput('Monthly Budget', prov.activeWallet.budget.toString(), (v) => prov.updateSettings(budget: double.tryParse(v) ?? 0), isNum: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _actionBtn('Backup Data (Clipboard)', () => _export(context, prov)),
        const SizedBox(height: 12),
        _actionBtn('Restore Data (Clipboard)', () => _import(context, prov)),
        const SizedBox(height: 12),
        _actionBtn('Download PDF Report', () => _generatePdf(prov), color: Colors.cyan),
        const SizedBox(height: 12),
        _actionBtn('Reset Everything', prov.resetAll, color: Colors.redAccent),
      ],
    );
  }

  Widget _settingInput(String label, String val, Function(String) onSave, {bool isNum = false}) {
    final ctrl = TextEditingController(text: val);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        GlassCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: ctrl,
            onSubmitted: onSave,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
      ]),
    );
  }

  Widget _settingDropdown(String label, String val, List<String> items, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: val,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.blueGrey[900],
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: (v) => onSave(v!),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.white))),
      ),
    );
  }

  void _export(BuildContext context, AppProvider prov) {
    final jsonStr = jsonEncode(prov.state.toJson());
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup copied to clipboard!')));
  }

  void _import(BuildContext context, AppProvider prov) async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      try {
        prov.restoreFromJson(data!.text!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data restored successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid backup data.')));
      }
    }
  }

  Future<void> _generatePdf(AppProvider prov) async {
    final pdf = pw.Document();
    final state = prov.state;
    final txs = prov.activeWallet.transactions;

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('User: ${state.user}'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            context: context,
            data: [
              ['Date', 'Title', 'Category', 'Type', 'Amount'],
              ...txs.map((t) => [t.date.toString().substring(0, 10), t.title, t.category, t.type, '${state.currency}${t.amount}'])
            ],
          ),
        ],
      ),
    ));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
