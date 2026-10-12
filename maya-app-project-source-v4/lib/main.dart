import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'xiaomi_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MayaXiaomiApp());
}

class MayaXiaomiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'માયા (Maya)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansGujarati',
        primaryColor: Color(0xFFD95D0F), // Saffron
        scaffoldBackgroundColor: Color(0xFFFFF8F5), // Warm Cream
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFD95D0F),
          secondary: Color(0xFF2E7D32),
        ),
      ),
      home: MayaHomeScreen(),
    );
  }
}

class MayaHomeScreen extends StatefulWidget {
  @override
  _MayaHomeScreenState createState() => _MayaHomeScreenState();
}

class _MayaHomeScreenState extends State<MayaHomeScreen> {
  static const MethodChannel _nativeChannel = MethodChannel('com.maya.app/xiaomi_native');
  bool _isFinderActive = false;

  @override
  void initState() {
    super.initState();
    _startPersistentXiaomiService();
  }

  Future<void> _startPersistentXiaomiService() async {
    try {
      await _nativeChannel.invokeMethod('startForegroundService');
    } catch (e) {
      print("Failed to start Xiaomi foreground service: $e");
    }
  }

  Future<void> _triggerPhoneFinder() async {
    setState(() => _isFinderActive = true);
    try {
      await _nativeChannel.invokeMethod('triggerPhoneFinder', {'durationSeconds': 30});
    } catch (e) {
      print("Phone finder error: $e");
    }
  }

  Future<void> _stopPhoneFinder() async {
    setState(() => _isFinderActive = false);
    try {
      await _nativeChannel.invokeMethod('stopPhoneFinder');
    } catch (e) {
      print("Stop phone finder error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF8F5),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "માયા",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD95D0F),
              ),
            ),
            Spacer(),
            // Xiaomi Redmi MIUI Setup Assistant Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => XiaomiSetupScreen()),
                );
              },
              icon: Icon(Icons.settings_phone, size: 20, color: Colors.white),
              label: Text("શાઓમી સેટઅપ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: Size(120, 44),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting Banner Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFF0E2DA)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "જય શ્રી કૃષ્ણ, મમ્મી! 🙏",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2C221E)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "હું તમારી માયા છું. આજે હું તમારી શું મદદ કરું?",
                    style: TextStyle(fontSize: 18, color: Color(0xFF6E5E57)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Action Cards
            _buildActionCard(
              title: "દવા નો સમય",
              subtitle: "સવારની બીપી ની દવા (૧ ગોળી)",
              icon: Icons.medication,
              color: Color(0xFFD95D0F),
              onTap: () {},
            ),
            SizedBox(height: 16),

            _buildActionCard(
              title: "ચિરાગ ને ફોન કરો",
              subtitle: "એક ટચ માં વાત કરો",
              icon: Icons.call,
              color: Color(0xFF2E7D32),
              onTap: () {},
            ),
            SizedBox(height: 16),

            // Find My Phone Manual Test Card
            _buildActionCard(
              title: _isFinderActive ? "ફોન અવાજ બંધ કરો" : "ફોન શોધો (ટેસ્ટ)",
              subtitle: "મોટો અવાજ અને ફ્લેશ લાઈટ ચાલુ થશે",
              icon: _isFinderActive ? Icons.volume_off : Icons.phonelink_ring,
              color: _isFinderActive ? Color(0xFFC62828) : Color(0xFF0288D1),
              onTap: _isFinderActive ? _stopPhoneFinder : _triggerPhoneFinder,
            ),
          ],
        ),
      ),

      // Central Push-To-Talk Microphone Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 84,
        height: 84,
        child: FloatingActionButton(
          onPressed: () {
            // Initiate full-duplex speech recognition
          },
          backgroundColor: Color(0xFFD95D0F),
          elevation: 8,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, size: 40, color: Colors.white),
              Text(
                "બોલો",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFF0E2DA)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C221E))),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 16, color: Color(0xFF6E5E57))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: Color(0xFF6E5E57)),
          ],
        ),
      ),
    );
  }
}