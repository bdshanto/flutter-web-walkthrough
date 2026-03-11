import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'services/version_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Walkthrough',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CounterPage(title: 'Flutter Web Version Checker'),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  final VersionService _versionService = VersionService();
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeVersionService();
  }

  Future<void> _initializeVersionService() async {
    await _versionService.initialize();

    // Listen for update notifications
    _versionService.updateAvailableStream.listen((updateAvailable) {
      if (updateAvailable && mounted) {
        setState(() {
          _updateAvailable = true;
        });
        _showUpdateDialog();
      } else if (mounted) {
        setState(() {
          _updateAvailable = false;
        });
      }
    });
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.update, color: Colors.blue),
              SizedBox(width: 8),
              Text('Update Available'),
            ],
          ),
          content: const Text(
            'A new version of the application is available. '
            'Would you like to update now? This will reload the page and clear all caches.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _postponeUpdate();
              },
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyUpdate();
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyUpdate() async {
    await _versionService.applyUpdate();

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Clear browser cache and reload
    await Future.delayed(const Duration(milliseconds: 500));
    html.window.location.reload();
  }

  void _postponeUpdate() {
    _versionService.postponeUpdate();

    // Show snackbar notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Update postponed. You will be reminded later.'),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Update Now',
            textColor: Colors.yellow,
            onPressed: () {
              _applyUpdate();
            },
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  void dispose() {
    _versionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final versionInfo = _versionService.currentVersion;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          if (_updateAvailable)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.system_update, color: Colors.red),
                tooltip: 'Update Available',
                onPressed: _showUpdateDialog,
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_updateAvailable)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade700),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.update, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'New version available!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const Text(
              'Counter Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show version info in a snackbar
                final version = _versionService.currentVersion;
                if (version != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Version: ${version.version} (${version.hash})'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Version info not available'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Show'),
            ),
            const SizedBox(height: 40),
            if (versionInfo != null)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Version Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Version: ${versionInfo.version}'),
                      Text('Hash: ${versionInfo.hash}'),
                      Text(
                        'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(versionInfo.timestamp)}',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
