import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class VersionChecker {
  // Remote manifest for update checks
  static const String _versionUrl =
      'https://raw.githubusercontent.com/KhaledJawan/words-map/refs/heads/main/wordmap_version.json';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final res = await http.get(Uri.parse(_versionUrl));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      final latest = data['latest'] as String;
      final androidUrl = data['androidUrl'] as String;
      final iosUrl = data['iosUrl'] as String;

      if (!_isVersionLower(currentVersion, latest)) return;
      if (!context.mounted) return;

      _showUpdateDialog(context, androidUrl, iosUrl);
    } catch (e) {
      debugPrint('Version check error: $e');
    }
  }

  static bool _isVersionLower(String a, String b) {
    final pa = a.split('.').map(int.parse).toList();
    final pb = b.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va < vb) return true;
      if (va > vb) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context, String androidUrl, String iosUrl) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.updateAvailableTitle),
        content: Text(loc.updateAvailableBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.updateAvailableLater),
          ),
          TextButton(
            onPressed: () async {
              final platform = Theme.of(context).platform;
              final url = platform == TargetPlatform.android
                  ? androidUrl
                  : iosUrl;

              Navigator.of(context).pop();

              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(loc.updateAvailableUpdate),
          ),
        ],
      ),
    );
  }
}
