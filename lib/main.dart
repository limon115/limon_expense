import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'providers/app_provider.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  
  final provider = AppProvider();
  await provider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const LimonExpenseApp(),
    ),
  );
}

class LimonExpenseApp extends StatelessWidget {
  const LimonExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().settings?.isDarkMode ?? false;

    return LiquidGlassWidgets.wrap(
      MaterialApp(
        title: 'Limon Expense Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          fontFamily: 'Sora',
          useMaterial3: true,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}