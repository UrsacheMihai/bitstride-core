// Entry point of the app that initializes Firebase and runs the main widget.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './config/firebase_options.dart';
import './providers/app/app_state.dart';
import './theme/app_theme.dart';
import './screens/dashboard/home_screen.dart';
import './screens/auth/auth_screen.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const BitStrideApp(),
    ),
  );
}

// Bootstraps the app with theme, providers, locale, and routing.
class BitStrideApp extends StatelessWidget {
  const BitStrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.isLoading) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(appState.language),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code_rounded, size: 64, color: Color(0xFF00E5FF)),
                SizedBox(height: 16),
                Text(
                  'BitStride',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(appState.language),
      title: 'BitStride',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: appState.isAuthenticated ? const HomeScreen() : const AuthScreen(),
    );
  }
}
