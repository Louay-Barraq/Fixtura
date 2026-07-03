import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tournament_provider.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ElBoutoulaApp());
}

class ElBoutoulaApp extends StatelessWidget {
  const ElBoutoulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: MaterialApp(
        title: 'El Boutoula',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}
