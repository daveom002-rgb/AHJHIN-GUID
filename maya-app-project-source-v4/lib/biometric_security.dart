import 'package:flutter/services.dart';

enum UserRole { mother, adminSon, unauthorizedGuest, temporaryGuest }

class BiometricSecurityService {
  static const MethodChannel _channel = MethodChannel('com.maya.app/biometric');

  static bool _guestAccessAllowed = false;
  static DateTime? _guestAccessExpiry;

  /// Performs instant dual-biometric scan (Voiceprint + Camera Eye/Iris Scan)
  static Future<UserRole> verifyBiometricIdentity() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('scanBiometrics');
      final String detectedRole = result['role'] ?? 'unauthorized';
      final double confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;

      if (confidence < 0.82) {
        return _guestAccessAllowed ? UserRole.temporaryGuest : UserRole.unauthorizedGuest;
      }

      switch (detectedRole) {
        case 'mother':
          return UserRole.mother;
        case 'admin_son':
          return UserRole.adminSon;
        default:
          if (_guestAccessAllowed && _isGuestAccessValid()) {
            return UserRole.temporaryGuest;
          }
          return UserRole.unauthorizedGuest;
      }
    } on PlatformException catch (e) {
      print("Biometric Scan Error: ${e.message}");
      return _guestAccessAllowed ? UserRole.temporaryGuest : UserRole.unauthorizedGuest;
    }
  }

  /// Toggles temporary guest access (e.g. for doctor, nurse, or visiting relative)
  static void grantGuestAccess({required Duration duration}) {
    _guestAccessAllowed = true;
    _guestAccessExpiry = DateTime.now().add(duration);
    print("Guest access granted for ${duration.inHours} hours.");
  }

  static void revokeGuestAccess() {
    _guestAccessAllowed = false;
    _guestAccessExpiry = null;
  }

  static bool _isGuestAccessValid() {
    if (_guestAccessExpiry == null) return false;
    if (DateTime.now().isAfter(_guestAccessExpiry!)) {
      _guestAccessAllowed = false;
      return false;
    }
    return true;
  }
}
