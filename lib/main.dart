import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/tournament_provider.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(FixturaApp(hasSeenOnboarding: hasSeenOnboarding));
}

class FixturaApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const FixturaApp({super.key, this.hasSeenOnboarding = true});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: MaterialApp(
        title: 'Fixtura',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: hasSeenOnboarding ? const DashboardScreen() : const OnboardingScreen(),
      ),
    );
  }
}

