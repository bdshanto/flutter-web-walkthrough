import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../services/version_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

    _versionService.updateAvailableStream.listen((updateAvailable) {
      if (updateAvailable && mounted) {
        setState(() => _updateAvailable = true);
        _showUpdateDialog();
      } else if (mounted) {
        setState(() => _updateAvailable = false);
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

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
    web.window.location.reload();
  }

  void _postponeUpdate() {
    _versionService.postponeUpdate();

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
            onPressed: _applyUpdate,
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    }
  }

  void _incrementCounter() => setState(() => _counter++);

  void _decrementCounter() => setState(() => _counter--);

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
        title: const Text('Dashboard'),
        actions: [
          if (_updateAvailable)
            IconButton(
              icon: const Icon(Icons.system_update, color: Colors.red),
              tooltip: 'Update Available',
              onPressed: _showUpdateDialog,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                final version = _versionService.currentVersion;
                final msg = version != null
                    ? 'Version: ${version.version} (${version.hash})'
                    : 'Version info not available';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Show Version'),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
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
