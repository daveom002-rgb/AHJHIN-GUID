import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XiaomiSetupScreen extends StatefulWidget {
  @override
  _XiaomiSetupScreenState createState() => _XiaomiSetupScreenState();
}

class _XiaomiSetupScreenState extends State<XiaomiSetupScreen> {
  static const MethodChannel _channel = MethodChannel('com.maya.app/xiaomi_native');

  Future<void> _openAutostart() async {
    await _channel.invokeMethod('openMiuiAutostart');
  }

  Future<void> _openBatterySaver() async {
    await _channel.invokeMethod('openMiuiBatterySaver');
  }

  Future<void> _openBackgroundPopups() async {
    await _channel.invokeMethod('openMiuiBackgroundPopups');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("શાઓમી રેડમી સેટઅપ Guide"),
        backgroundColor: Color(0xFFFFF8F5),
        elevation: 0,
        foregroundColor: Color(0xFF2C221E),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "શાઓમી રેડમી ફોન સેટઅપ (Chirag Setup)",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD95D0F)),
            ),
            SizedBox(height: 8),
            Text(
              "માયા ફોન બંધ હોય ત્યારે પણ ચાલુ રહે તે માટે આ ૩ પરમિશન એક વાર ચાલુ કરો:",
              style: TextStyle(fontSize: 18, color: Color(0xFF2C221E)),
            ),
            SizedBox(height: 24),

            // Step 1: Autostart
            _buildSetupStep(
              stepNumber: "૧",
              title: "ઓટો-સ્ટાર્ટ ચાલુ કરો (Autostart)",
              description: "ફોન બંધ થઈને ચાલુ થાય ત્યારે માયા મેળે ચાલુ થઈ જશે.",
              buttonText: "ઓટો-સ્ટાર્ટ સેટિંગ ખોલો",
              onPressed: _openAutostart,
            ),
            SizedBox(height: 20),

            // Step 2: Battery Saver
            _buildSetupStep(
              stepNumber: "૨",
              title: "બેકગ્રાઉન્ડ સેટિંગ (No Restrictions)",
              description: "બેટરી સેવર માયા ને બંધ નહીં કરે.",
              buttonText: "બેટરી સેટિંગ ખોલો",
              onPressed: _openBatterySaver,
            ),
            SizedBox(height: 20),

            // Step 3: Display Popups
            _buildSetupStep(
              stepNumber: "૩",
              title: "બેકગ્રાઉન્ડ પોપ-અપ (Display Pop-ups)",
              description: "ઇમર્જન્સી માં સ્ક્રીન પર તુરંત મેસેજ બતાવશે.",
              buttonText: "પોપ-અપ સેટિંગ ખોલો",
              onPressed: _openBackgroundPopups,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep({
    required String stepNumber,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFF0E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFD95D0F),
                radius: 16,
                child: Text(stepNumber, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C221E))),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 15, color: Color(0xFF6E5E57))),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C221E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}