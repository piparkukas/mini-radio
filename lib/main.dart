import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:minimal_radio/screens/home.dart';
import 'package:minimal_radio/screens/no_connection.dart';
import 'package:minimal_radio/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final connectivityResult = await Connectivity().checkConnectivity();
  runApp(MyApp(hasConnection: connectivityResult != ConnectivityResult.none));
}

class MyApp extends StatelessWidget {
  final bool hasConnection;
  const MyApp({super.key, required this.hasConnection});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Radio',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: hasConnection ? const HomeScreen() : const NoConnectionScreen(),
    );
  }
}
