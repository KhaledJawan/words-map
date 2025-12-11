import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _notificationsKey = 'settings_app_notifications';
  static const _dailyReminderKey = 'settings_daily_reminder';

  Future<bool> loadAppNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<bool> loadDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderKey) ?? false;
  }

  Future<void> setAppNotifications(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, isEnabled);
  }

  Future<void> setDailyReminder(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, isEnabled);
  }
}
