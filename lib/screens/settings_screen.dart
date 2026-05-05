import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../providers/app_provider.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final nameCtrl = TextEditingController(text: app.settings?.userName);
    final budgetCtrl = TextEditingController(text: app.settings?.monthlyBudget.toString());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.blueAccent, child: Icon(Icons.code_rounded, size: 40, color: Colors.white)),
                const SizedBox(height: 10),
                const Text('Khalid Hasan Limon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Lead Developer', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              children: [
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'Profile Name', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                  ),
                ),
                const SizedBox(height: 15),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: budgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Monthly Budget', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Mode'),
                    Switch(value: app.settings?.isDarkMode ?? false, onChanged: (v) => app.updateUserSettings(nameCtrl.text, app.settings!.currency, double.parse(budgetCtrl.text), v)),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => app.updateUserSettings(nameCtrl.text, app.settings!.currency, double.parse(budgetCtrl.text), app.settings!.isDarkMode),
                  child: const GlassCard(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _actionTile(Icons.copy_rounded, 'Backup Data', () {
            Clipboard.setData(ClipboardData(text: app.exportBackup()));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup copied to clipboard!')));
          }),
          _actionTile(Icons.picture_as_pdf_rounded, 'Export PDF Report', () {}),
          _actionTile(Icons.delete_forever_rounded, 'Reset Everything', () => app.resetAll(), color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.blueAccent),
          title: Text(title, style: TextStyle(color: color)),
          onTap: onTap,
        ),
      ),
    );
  }
}
