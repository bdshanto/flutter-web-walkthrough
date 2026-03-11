import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VersionInfo {
  final String version;
  final String hash;
  final int timestamp;

  VersionInfo({
    required this.version,
    required this.hash,
    required this.timestamp,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String,
      hash: json['hash'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'version': version, 'hash': hash, 'timestamp': timestamp};
  }
}

class VersionService {
  static const String _versionUrl = 'version.json';
  static const String _storageKey = 'cached_version_info';
  static const Duration _checkInterval = Duration(minutes: 5);

  Timer? _timer;
  VersionInfo? _currentVersion;
  final StreamController<bool> _updateAvailableController =
      StreamController<bool>.broadcast();

  Stream<bool> get updateAvailableStream => _updateAvailableController.stream;

  /// Initialize the version service
  Future<void> initialize() async {
    // Load cached version info
    await _loadCachedVersion();

    // Check for updates immediately
    await checkForUpdates();

    // Start periodic checking
    startPeriodicCheck();
  }

  /// Load cached version from local storage
  Future<void> _loadCachedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_storageKey);

      if (cachedData != null) {
        final json = jsonDecode(cachedData);
        _currentVersion = VersionInfo.fromJson(json);
      }
    } catch (e) {
      print('Error loading cached version: $e');
    }
  }

  /// Save version info to local storage
  Future<void> _saveCachedVersion(VersionInfo version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(version.toJson()));
      _currentVersion = version;
    } catch (e) {
      print('Error saving cached version: $e');
    }
  }

  /// Fetch version info from server
  Future<VersionInfo?> fetchVersionInfo() async {
    try {
      // Add cache-busting parameter
      final url = '$_versionUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return VersionInfo.fromJson(json);
      }
    } catch (e) {
      print('Error fetching version info: $e');
    }
    return null;
  }

  /// Check if a new version is available
  Future<bool> checkForUpdates() async {
    final serverVersion = await fetchVersionInfo();

    if (serverVersion == null) {
      return false;
    }

    // If no cached version, save the current one
    if (_currentVersion == null) {
      await _saveCachedVersion(serverVersion);
      return false;
    }

    // Compare hashes to detect changes
    if (_currentVersion!.hash != serverVersion.hash) {
      _updateAvailableController.add(true);
      return true;
    }

    return false;
  }

  /// Start periodic version checking
  void startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) async {
      await checkForUpdates();
    });
  }

  /// Stop periodic version checking
  void stopPeriodicCheck() {
    _timer?.cancel();
  }

  /// Apply update by reloading the page and clearing cache
  Future<void> applyUpdate() async {
    try {
      // Clear cached version
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      // In web, we need to use dart:html window.location.reload(true)
      // But for cross-platform compatibility, we'll just use a simple approach
      // The actual reload will be handled by the UI layer using dart:html
    } catch (e) {
      print('Error applying update: $e');
    }
  }

  /// Postpone update notification
  Future<void> postponeUpdate() async {
    // Update will be checked again in the next interval
    _updateAvailableController.add(false);
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _updateAvailableController.close();
  }

  /// Get current version info
  VersionInfo? get currentVersion => _currentVersion;
}
