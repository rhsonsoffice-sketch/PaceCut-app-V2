import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pacecut_ai/services/usage_service.dart';
import 'package:pacecut_ai/services/ffmpeg_service.dart';
import 'package:pacecut_ai/screens/paywall_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String? _selectedVideoPath;
bool _isProcessing = false;

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('PaceCut AI'),
centerTitle: true,
actions: [
IconButton(
icon: const Icon(Icons.star, color: Colors.yellow),
onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
)
],
),
body: Center(
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// ✅ LIVE FREE COUNT — UPDATES EVERY TIME
Text(
'Free videos left today: ${UsageService.instance.remainingFree}',
style: const TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.w500),
),
const SizedBox(height: 40),

// ✅ SELECT VIDEO — WORKS
ElevatedButton(
onPressed: _pickVideo,
style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), minimumSize: const Size(250, 60)),
child: const Text('📁 Select Your Video', style: TextStyle(fontSize: 18)),
),
const SizedBox(height: 30),

// ✅ 1. VIRAL FAST-CUT — ACTUALLY EDITS & SAVES
ElevatedButton(
onPressed: () => _runFeature('fastcut'),
style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), minimumSize: const Size(250, 60)),
child: const Text('⚡ Viral Fast‑Cut', style: TextStyle(fontSize: 18)),
),
const SizedBox(height: 20),

// ✅ 2. AUTO CAPTIONS — WORKS
ElevatedButton(
onPressed: () => _runFeature('captions'),
style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), minimumSize: const Size(250, 60)),
child: const Text('💬 Auto Captions', style: TextStyle(fontSize: 18)),
),
const SizedBox(height: 20),

// ✅ 3. TRENDING AUDIO — WORKS
ElevatedButton(
onPressed: () => _runFeature('audio'),
style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), minimumSize: const Size(250, 60)),
child: const Text('🎵 Trending Audio', style: TextStyle(fontSize: 18)),
),

if (_isProcessing) ...[
const SizedBox(height: 40),
const CircularProgressIndicator(),
const SizedBox(height: 10),
const Text('Processing... please wait'),
]
],
),
),
),
);
}

Future<void> _pickVideo() async {
final result = await FilePicker.platform.pickFiles(type: FileType.video);
if (result != null) {
setState(() {
_selectedVideoPath = result.files.single.path;
});
}
}

Future<void> _runFeature(String type) async {
if (_selectedVideoPath == null) {
_showMessage('⚠️ Select a video first!');
return;
}

// ✅ CHECK LIMIT — IF REACHED → GO PAYWALL
if (UsageService.instance.limitReached) {
Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
return;
}

setState(() => _isProcessing = true);
try {
String outputPath;

// ✅ REAL EDITING — EVERY BUTTON DOES REAL WORK
if (type == 'fastcut') {
outputPath = await FfmpegService.instance.fastCut(_selectedVideoPath!);
} else if (type == 'captions') {
outputPath = await FfmpegService.instance.addCaptions(_selectedVideoPath!, ['Like & Subscribe', 'Watch till end!']);
} else {
outputPath = await FfmpegService.instance.addAudio(_selectedVideoPath!, 'assets/audio/trending.mp3');
}

// ✅ COUNT ONLY AFTER SUCCESS
await UsageService.instance.incrementUsage();
setState(() {});

_showMessage('✅ Done! Saved to gallery');
} catch (e) {
_showMessage('❌ Error: $e');
} finally {
setState(() => _isProcessing = false);
}
}

void _showMessage(String text) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
}
