import 'package:flutter/services.dart';
import 'on_device_learning.dart';

class WhatsAppService {
  static const MethodChannel _channel = MethodChannel('com.maya.app/whatsapp_bridge');

  /// Sends a WhatsApp message via Android Accessibility Bridge
  static Future<bool> sendWhatsAppMessage({
    required String contactOrNickname,
    required String messageText,
  }) async {
    try {
      // Check if contact is a learned nickname first
      final learnedContact = await OnDeviceLearningEngine.resolveNickname(contactOrNickname);
      final String targetPhoneOrName = learnedContact?['phone'] ?? contactOrNickname;

      final bool success = await _channel.invokeMethod('sendWhatsAppMessage', {
        'target': targetPhoneOrName,
        'message': messageText,
      });
      return success;
    } on PlatformException catch (e) {
      print("WhatsApp automation error: ${e.message}");
      return false;
    }
  }

  /// Announces incoming call/message sender details in Gujarati when asked ("કોનો કોલ છે?" / "કોનો મેસેજ છે?")
  static Future<String> getCallerOrSenderInfo({required bool isCall}) async {
    try {
      final Map<dynamic, dynamic> info = await _channel.invokeMethod('getLastNotificationDetails');
      final String senderName = info['sender'] ?? 'અજાણ્યો નંબર';
      final String textContent = info['text'] ?? '';

      if (isCall) {
        return "મમ્મી જી, આ $senderName નો કોલ આવે છે.";
      } else {
        return "મમ્મી જી, આ $senderName નો મેસેજ આવ્યો છે: $textContent";
      }
    } on PlatformException catch (e) {
      print("Notification query error: ${e.message}");
      return "મમ્મી જી, કોઈ માહિતી મળી શકી નથી.";
    }
  }

  /// Launches any app on Mummy's phone by voice command
  static Future<bool> launchAppByVoice(String appNameGujarati) async {
    try {
      final bool result = await _channel.invokeMethod('launchApp', {
        'appName': appNameGujarati,
      });
      return result;
    } on PlatformException catch (e) {
      print("Launch app error: ${e.message}");
      return false;
    }
  }
}
