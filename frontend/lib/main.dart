// Temporarily disabled Firebase due to web compatibility issues
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Temporarily disabled Firebase initialization due to web compatibility issues
  debugPrint("Firebase initialization skipped temporarily");

  runApp(
    // Wrap the app with ProviderScope for state management
    const ProviderScope(
      child: HexTheAddHubApp(),
    ),
  );
}
