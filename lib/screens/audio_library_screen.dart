import 'package:flutter/material.dart';
import 'package:pacecut_ai/services/ffmpeg_service.dart';

class AudioLibraryScreen extends StatelessWidget {
final String videoPath;
const AudioLibraryScreen({super.key, required this.videoPath});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Trending Music Library')),
body: ListView(
padding: const EdgeInsets.all(24),
children: [
_audioItem('Trending Pop', 'assets/audio/pop.mp3'),
_audioItem('Upbeat Dance', 'assets/audio/dance.mp3'),
_audioItem('Cinematic', 'assets/audio/cinematic.mp3'),
_audioItem('Vlog Beat', 'assets/audio/vlog.mp3'),
],
),
);
}

Widget _audioItem(String title, String path) {
return ListTile(
title: Text(title),
trailing: const Icon(Icons.add_circle, color: Colors.green),
onTap: () => FfmpegService.instance.addTrendingMusic(videoPath, path),
);
}
}
