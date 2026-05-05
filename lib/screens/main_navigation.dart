import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'dashboard_screen.dart';
import 'trends_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';
import '../widgets/background_orbs.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TrendsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const BackgroundOrbs(),
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomBar(
        tabs: [
          GlassBottomBarTab(icon: const Icon(Icons.dashboard_rounded), label: 'Home'),
          GlassBottomBarTab(icon: const Icon(Icons.bar_chart_rounded), label: 'Trends'),
          GlassBottomBarTab(icon: const Icon(Icons.pie_chart_rounded), label: 'Analytics'),
          GlassBottomBarTab(icon: const Icon(Icons.settings_rounded), label: 'Settings'),
        ],
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
