import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'provider.dart';
import 'screens/dashboard.dart';
import 'screens/trends.dart';
import 'screens/analytics.dart';
import 'screens/settings.dart';
import 'screens/add_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const ExpenseApp(),
    ),
  );
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().state.isDarkMode;
    return LiquidGlassWidgets.wrap(
      MaterialApp(
        title: 'Limon Manager',
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Sora',
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Sora',
          useMaterial3: true,
        ),
        home: const NavigationShell(),
      ),
    );
  }
}

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
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
          Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueGrey, Colors.black], begin: Alignment.topLeft))),
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: GlassBottomBar(
        selectedIndex: _currentIndex,
        onTabSelected: (i) => setState(() => _currentIndex = i),
        tabs: [
          GlassBottomBarTab(icon: const Icon(Icons.home_rounded), label: 'Home'),
          GlassBottomBarTab(icon: const Icon(Icons.bar_chart_rounded), label: 'Trends'),
          GlassBottomBarTab(icon: const Icon(Icons.pie_chart_rounded), label: 'Analytics'),
          GlassBottomBarTab(icon: const Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ),
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
