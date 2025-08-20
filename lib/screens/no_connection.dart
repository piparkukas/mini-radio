// ignore_for_file: use_build_context_synchronously
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Нет соединения с интернетом',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final connectivityResult = await Connectivity()
                    .checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                  ); // Или перезапуск app
                }
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
