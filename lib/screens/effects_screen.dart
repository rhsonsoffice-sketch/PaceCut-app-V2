import 'package:flutter/material.dart';
import 'package:pacecut_ai/services/ffmpeg_service.dart';

class EffectsScreen extends StatelessWidget {
final String videoPath;
const EffectsScreen({super.key, required this.videoPath});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Effects & Filters')),
body: GridView.count(
crossAxisCount: 2,
padding: const EdgeInsets.all(24),
children: [
_effectButton('Vintage', ()=>FfmpegService.instance.addFilterVintage(videoPath)),
_effectButton('Glitch', ()=>FfmpegService.instance.addFilterGlitch(videoPath)),
_effectButton('Black & White', ()=>FfmpegService.instance._saveAndReturn('-i "$videoPath" -vf format=gray', 'bw')),
_effectButton('Brightness+', ()=>FfmpegService.instance._saveAndReturn('-i "$videoPath" -vf eq=brightness=0.2', 'bright')),
],
),
);
}

Widget _effectButton(String label, VoidCallback onTap) {
return Card(child: InkWell(onTap: onTap, child: Center(child: Text(label, style: const TextStyle(fontSize:18)))));
}
}
