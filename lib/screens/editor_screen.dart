mport 'package:flutter/material.dart';
import 'package:pacecut_ai/services/ffmpeg_service.dart';
import 'package:pacecut_ai/services/usage_service.dart';

class EditorScreen extends StatefulWidget {
final String videoPath;
const EditorScreen({super.key, required this.videoPath});

@override
State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
double _trimStart = 0.0;
double _trimEnd = 60.0;
double _speed = 1.0;
bool _isProcessing = false;

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Timeline Editor'),
centerTitle: true,
actions: [
TextButton(
onPressed: _exportEditedVideo,
child: const Text('EXPORT', style: TextStyle(fontSize: Colors.greenAccent, fontSize: 16)),
)
],
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
// ✅ VIDEO PREVIEW AREA
Container(
height: 400,
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(12),
),
child: const Center(
child: Text('VIDEO PREVIEW', style: TextStyle(color: Colors.white, fontSize: 18)),
),
),
const SizedBox(height: 30),

// ✅ TRIM CONTROLS — START / END
const Text('✂️ TRIM VIDEO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
Text('Start: ${_trimStart.toStringAsFixed(1)}s'),
Slider(
min: 0,
max: 120,
value: _trimStart,
onChanged: (val) => setState(() => _trimStart = val),
),
Text('End: ${_trimEnd.toStringAsFixed(1)}s'),
Slider(
min: 0,
max: 120,
value: _trimEnd,
onChanged: (val) => setState(() => _trimEnd = val),
),
const SizedBox(height: 20),

// ✅ SPEED CONTROL — 0.1x → 10x
const Text('⏱ SPEED CONTROL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
Text('Speed: ${_speed.toStringAsFixed(1)}x'),
Slider(
min: 0.1,
max: 10.0,
divisions: 99,
value: _speed,
onChanged: (val) => setState(() => _speed = val),
),
const SizedBox(height: 20),

// ✅ ROTATE / REVERSE / CROP BUTTONS
const Text('🔄 MORE EDITING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
ElevatedButton(onPressed: _rotate90, child: const Text('Rotate 90°')),
ElevatedButton(onPressed: _reverseVideo, child: const Text('Reverse')),
ElevatedButton(onPressed: _cropVideo, child: const Text('Crop')),
],
),
const SizedBox(height: 40),

// ✅ LOADING INDICATOR
if (_isProcessing) ...[
const CircularProgressIndicator(),
const SizedBox(height: 10),
const Text('Processing... please wait'),
]
],
),
),
);
}

// ✅ ROTATE VIDEO
Future<void> _rotate90() async {
setState(() => _isProcessing = true);
try {
await FfmpegService.instance._saveAndReturn(
'-i "${widget.videoPath}" -vf "transpose=1"',
'rotated',
);
_showMsg('✅ Rotated 90°');
} catch (e) {
_showMsg('❌ Error: $e');
} finally {
setState(() => _isProcessing = false);
}
}

// ✅ REVERSE VIDEO
Future<void> _reverseVideo() async {
setState(() => _isProcessing = true);
try {
await FfmpegService.instance._saveAndReturn(
'-i "${widget.videoPath}" -vf "reverse" -af "areverse"',
'reversed',
);
_showMsg('✅ Video reversed');
} catch (e) {
_showMsg('❌ Error: $e');
} finally {
setState(() => _isProcessing = false);
}
}

// ✅ CROP VIDEO
Future<void> _cropVideo() async {
setState(() => _isProcessing = true);
try {
await FfmpegService.instance._saveAndReturn(
'-i "${widget.videoPath}" -vf "crop=iw*0.8:ih*0.8"',
'cropped',
);
_showMsg('✅ Video cropped');
} catch (e) {
_showMsg('❌ Error: $e');
} finally {
setState(() => _isProcessing = false);
}
}

// ✅ EXPORT FINAL EDITED VIDEO
Future<void> _exportEditedVideo() async {
if (UsageService.instance.limitReached) {
Navigator.pop(context);
return;
}

setState(() => _isProcessing = true);
try {
final cmd = '-i "${widget.videoPath}" '
'-ss ${_trimStart.toInt()} -to ${_trimEnd.toInt()} '
'-filter:v "setpts=${1/_speed}*PTS" '
'-c:a aac';

await FfmpegService.instance._saveAndReturn(cmd, 'edited_final');
await UsageService.instance.incrementUsage();

_showMsg('✅ Exported! Saved to gallery');
Navigator.pop(context);
} catch (e) {
_showMsg('❌ Export failed: $e');
} finally {
setState(() => _isProcessing = false);
}
}

void _showMsg(String text) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
}
