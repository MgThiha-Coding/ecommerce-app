import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OtaUpdateService {
  static const otaConfigUrl =
      "https://raw.githubusercontent.com/MgThiha-Coding/pico-mart/production/version.json";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest version JSON
      final response = await http.get(Uri.parse(otaConfigUrl));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final latestVersion = data['version'] as String;
      final apkUrl = data['url'] as String;
      final changelog = data['changelog'] as String? ?? '';
      final forceUpdate = data['force_update'] as bool? ?? false;

      // 3. Compare versions
      if (_isNewerVersion(latestVersion, currentVersion)) {
        _showUpdateDialog(context, apkUrl, changelog, forceUpdate);
      }
    } catch (e) {
      print('OTA Update check error: $e');
    }
  }

  // Compare semantic versions
  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context, String apkUrl, String changelog, bool forceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(changelog.isNotEmpty ? changelog : 'A new version is available.'),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startOtaUpdate(context, apkUrl);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  static void _startOtaUpdate(BuildContext context, String apkUrl) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          double progress = 0;
          return StatefulBuilder(builder: (context, setState) {
            OtaUpdate()
                .execute(apkUrl, destinationFilename: 'app_update.apk')
                .listen((event) {
              if (event.status == OtaStatus.DOWNLOADING) {
                setState(() {
                  progress = double.tryParse(event.value ?? '0') ?? 0;
                });
              } else if (event.status == OtaStatus.INSTALLING) {
                setState(() {
                  progress = 100;
                });
              }
            });

            return AlertDialog(
              title: const Text('Downloading Update'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress / 100),
                  const SizedBox(height: 8),
                  Text('${progress.toStringAsFixed(0)}%'),
                ],
              ),
            );
          });
        },
      );
    } catch (e) {
      print('OTA Update failed: $e');
    }
  }
}
