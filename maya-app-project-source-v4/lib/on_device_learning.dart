import 'package:shared_preferences/shared_preferences.dart';

class OnDeviceLearningEngine {
  static const String _nicknameKeyPrefix = "learned_nickname_";
  static const String _routineKeyPrefix = "learned_routine_";

  /// Learns and associates custom Gujarati family nicknames with contacts
  static Future<void> learnNickname(String nickname, String actualContactName, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_nicknameKeyPrefix$nickname', '$actualContactName|$phoneNumber');
    print("Learned new contact association: $nickname -> $actualContactName ($phoneNumber)");
  }

  /// Resolves a spoken Gujarati nickname (e.g., "મોટા દીકરા", "ગીતાબેન") to contact details
  static Future<Map<String, String>?> resolveNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('$_nicknameKeyPrefix$nickname');
    if (data != null && data.contains('|')) {
      final parts = data.split('|');
      return {'contactName': parts[0], 'phone': parts[1]};
    }
    return null;
  }

  /// Learns daily user habits and customized medication or care rules
  static Future<void> learnUserHabit(String habitKey, String ruleDescription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_routineKeyPrefix$habitKey', ruleDescription);
  }
}
