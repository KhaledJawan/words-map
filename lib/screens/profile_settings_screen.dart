import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_map_app/services/app_state.dart';
import 'package:word_map_app/ui/ios_card.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Guest';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoURL;
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = appState.appLocale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ColoredBox(
        color: Colors.white,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              IosCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _iosTile(
                    icon: Icons.language,
                    title: "Language",
                    subtitle: currentLocale == 'fa' ? "فارسی" : "English",
                    onTap: () {},
                  ),
                  _divider(),
                  _iosTile(
                    icon: Icons.notifications_none,
                    title: "Notifications",
                    onTap: () {},
                  ),
                  _divider(),
                  _iosSwitchTile(
                    title: "Dark Mode",
                    value: isDark,
                    onChanged: (v) {
                      appState
                          .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              IosCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                    title: Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.red.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/sign-in', (r) => false);
                      }
                    },
                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade300);

  Widget _iosTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade500))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _iosSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      activeColor: const Color(0xFF34C759),
      contentPadding: EdgeInsets.zero,
    );
  }
}
