import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentVersion = '';
  bool _checking = false;

  static const otaConfigUrl =
      "https://raw.githubusercontent.com/MgThiha-Coding/pico-mart/refs/heads/production/version.json?token=GHSAT0AAAAAADFHIBLUOQ5WHAOG54GO3VFC2IHZCZA";

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _currentVersion = info.version);
  }

  Future<void> _checkForUpdate() async {
    setState(() => _checking = true);
    try {
      final response = await http.get(Uri.parse(otaConfigUrl));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final latestVersion = data['version'] as String;
      final apkUrl = data['url'] as String;
      final changelog = data['changelog'] as String? ?? '';
      final forceUpdate = data['force_update'] as bool? ?? false;

      if (_isNewerVersion(latestVersion, _currentVersion)) {
        _showUpdateDialog(apkUrl, latestVersion, changelog, forceUpdate);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('App is up to date!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to check updates: $e')));
    } finally {
      setState(() => _checking = false);
    }
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i])
        return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog(
    String apkUrl,
    String version,
    String changelog,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          changelog.isNotEmpty ? changelog : 'A new version is available.',
        ),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startOtaUpdate(apkUrl, version);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _startOtaUpdate(String apkUrl, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        double progress = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            OtaUpdate()
                .execute(
                  apkUrl,
                  destinationFilename: 'app_update_v$version.apk',
                )
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors.textSecondary,
            fontSize: responsive.subHeading,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                'Current Version',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: Responsive(context).body,
                ),
              ),
              trailing: Text(
                _currentVersion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Card(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.system_update),
              title: Text(
                'Check for Update',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: Responsive(context).body,
                ),
              ),
              trailing: _checking ? SpinKitCircle(size: 10) : null,
              onTap: _checking ? null : _checkForUpdate,
            ),
          ),
        ],
      ),
    );
  }
}
