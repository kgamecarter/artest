import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ar_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PermissionCheckScreen(),
    );
  }
}

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({super.key});

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ARScannerScreen()),
        );
      }
    } else {
      // Handle permission denied
      // For now, just show a text
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const CircularProgressIndicator(),
             const SizedBox(height: 20),
             const Text("Requesting Camera Permission..."),
             const SizedBox(height: 20),
             ElevatedButton(
               onPressed: _checkPermissions,
               child: const Text("Retry Permission"),
             )
          ],
        ),
      ),
    );
  }
}
