import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ReelGuardApp());

const lavender = Color(0xFFB9A2FF);
const bg = Color(0xFF111019);
const native = MethodChannel('reelguard/blocker');

class ReelGuardApp extends StatelessWidget {
  const ReelGuardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ReelGuard',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: bg, colorScheme: ColorScheme.fromSeed(seedColor: lavender, brightness: Brightness.dark)),
    home: const Dashboard(),
  );
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool enabled = false;
  bool instagram = true;
  bool youtube = true;
  int dailyLimit = 30;
  int focusMinutes = 25;
  String status = 'Accessibility permission needed';

  Future<void> _sync() async {
    try {
      await native.invokeMethod('setBlocking', {
        'enabled': enabled,
        'packages': [if (instagram) 'com.instagram.android', if (youtube) 'com.google.android.youtube'],
      });
      setState(() => status = enabled ? 'Blocking is enabled' : 'Blocking is paused');
    } on PlatformException catch (e) {
      setState(() => status = e.message ?? 'Could not update blocker');
    } on MissingPluginException {
      setState(() => status = 'Install the Android native files from this bundle');
    }
  }

  Future<void> _openAccessibility() async {
    try { await native.invokeMethod('openAccessibilitySettings'); }
    on PlatformException { setState(() => status = 'Open Android Settings → Accessibility → ReelGuard'); }
    on MissingPluginException { setState(() => status = 'Open Android Settings → Accessibility → ReelGuard'); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('reelguard', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5)),
      actions: [IconButton(onPressed: _openAccessibility, icon: const Icon(Icons.settings_accessibility))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF34265D), Color(0xFF1D1A2B)]), borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.shield_moon_outlined, size: 34, color: lavender), const SizedBox(height: 18),
        const Text('Take back\nyour attention.', style: TextStyle(fontSize: 30, height: 1.12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10), Text(status, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 18),
        Row(children: [Expanded(child: Text(enabled ? 'BLOCKER ON' : 'BLOCKER OFF', style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold))), Switch(value: enabled, activeColor: lavender, onChanged: (v) async { setState(() => enabled = v); await _sync(); })]),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _openAccessibility, icon: const Icon(Icons.lock_open), label: const Text('Set up Android permission'))),
      ])),
      const SizedBox(height: 24),
      const Text('Apps to block', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      _appTile('Instagram', 'Reels and Instagram scrolling', Icons.camera_alt_outlined, instagram, (v) async { setState(() => instagram = v); await _sync(); }),
      _appTile('YouTube', 'Shorts and YouTube browsing', Icons.smart_display_outlined, youtube, (v) async { setState(() => youtube = v); await _sync(); }),
      const SizedBox(height: 20),
      _section('Daily scrolling limit', '$dailyLimit minutes', Icons.hourglass_bottom, Column(children: [Slider(value: dailyLimit.toDouble(), min: 5, max: 120, divisions: 23, activeColor: lavender, label: '$dailyLimit min', onChanged: (v) => setState(() => dailyLimit = v.round())), const Text('Starter setting only — daily usage accounting is not wired up yet.', style: TextStyle(color: Colors.white54, fontSize: 12))])),
      const SizedBox(height: 14),
      _section(
        'Focus session',
        '$focusMinutes min',
        Icons.center_focus_strong,
        Column(
          children: [
            Slider(
              value: focusMinutes.toDouble(),
              min: 5,
              max: 90,
              divisions: 17,
              activeColor: lavender,
              label: '$focusMinutes min',
              onChanged: (v) => setState(() => focusMinutes = v.round()),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Focus session'),
                    content: Text(
                      'Your planned focus session is $focusMinutes minutes. Enable the blocker above to block selected apps.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start focus session'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22), const Text('Privacy first', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('ReelGuard uses Android Accessibility Service to detect when a selected app opens. It does not read messages or collect your content. Blocking works only after you enable the service in Android Settings.', style: TextStyle(color: Colors.white60, height: 1.45)),
    ]),
  );

  Widget _appTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) => Card(color: const Color(0xFF1C1A27), child: SwitchListTile(secondary: Container(width: 44, height: 44, decoration: BoxDecoration(color: lavender.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: lavender)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)), value: value, activeColor: lavender, onChanged: onChanged));
  Widget _section(String title, String value, IconData icon, Widget child) => Card(color: const Color(0xFF1C1A27), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: lavender), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(value, style: const TextStyle(color: lavender, fontWeight: FontWeight.bold))]), const SizedBox(height: 12), child])));
}
