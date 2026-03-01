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
}