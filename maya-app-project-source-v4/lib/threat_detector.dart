import 'package:flutter/services.dart';

enum ThreatSeverity { safe, suspicious, criticalScam }

class ThreatDetectorService {
  static const MethodChannel _channel = MethodChannel('com.maya.app/threat_protection');

  /// Scans incoming phone numbers against local & online scam databases
  static Future<Map<String, dynamic>> scanIncomingCall(String phoneNumber) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('analyzeIncomingCall', {
        'phone': phoneNumber,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Call threat scan failed: ${e.message}");
      return {'isScam': false, 'threatScore': 0.0, 'warningText': ''};
    }
  }

  /// Scans incoming SMS or WhatsApp text messages for phishing links
  static Future<Map<String, dynamic>> scanMessageText(String messageText, String sender) async {
    final bool containsPhishingUrl = RegExp(r'(bit\.ly|tinyurl|apk-download|banking-verify|reward-claim)', caseSensitive: false)
        .hasMatch(messageText);
    
    if (containsPhishingUrl) {
      return {
        'isThreat': true,
        'severity': ThreatSeverity.criticalScam,
        'warningGujarati': "મમ્મી જી, આ મેસેજમાં નકલી લિંક છે. આના પર ક્લિક ના કરતા. આ છેતરપિંડી હોઈ શકે છે.",
      };
    }

    return {'isThreat': false, 'severity': ThreatSeverity.safe, 'warningGujarati': ''};
  }
}
