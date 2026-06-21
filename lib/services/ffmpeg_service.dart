import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class FfmpegService {
static final FfmpegService instance = FfmpegService._internal();
factory FfmpegService() => instance;
FfmpegService._internal();

Future<String> _saveAndReturn(String cmd, String name) async {
final dir = await getTemporaryDirectory();
final path = '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.mp4';
await FFmpegKit.execute('$cmd "$path"');
await GallerySaver.saveVideo(path);
return path;
}

// ✅ AI TOOLS
Future<String> fastCut(String input) async => _saveAndReturn('-i "$input" -t 15 -c:v copy -c:a copy', 'fastcut');
Future<String> autoPacing(String input) async => _saveAndReturn('-i "$input" -filter:v "setpts=0.7*PTS" -c:a aac', 'autopace');
Future<String> addCaptions(String input, List<String> lines) async => _saveAndReturn('-i "$input" -vf "drawtext=text=\'${lines.join('\\n')}\':x=(w-text_w)/2:y=h-100:fontsize=28:fontcolor=white:box=1"', 'captions');
Future<String> addIntroHook(String input) async => _saveAndReturn('-i "$input" -vf "drawtext=text=\'STOP WATCH THIS!\':x=(w-text_w)/2:y=50:fontsize=36:fontcolor=red:box=1"', 'hook');
Future<String> addRetentionPoints(String input) async => _saveAndReturn('-i "$input" -vf "drawtext=text=\'👇 MORE BELOW\':y=h-50", 'retention');

// ✅ EDITING
Future<String> changeSpeed(String input, double speed) async => _saveAndReturn('-i "$input" -filter:v "setpts=${1/speed}*PTS"', 'speed');
Future<String> cropRotate(String input) async => _saveAndReturn('-i "$input" -vf "crop=iw/2:ih,rotate=PI/2"', 'crop');
Future<String> addTransitions(String input) async => _saveAndReturn('-i "$input" -vf "fade=t=in:st=0:d=0.5,fade=t=out:st=10:d=0.5"', 'trans');

// ✅ EFFECTS
Future<String> addFilterVintage(String input) async => _saveAndReturn('-i "$input" -vf "colorbalance=rs=0.3:gs=0.3:bs=-0.3"', 'vintage');
Future<String> addFilterGlitch(String input) async => _saveAndReturn('-i "$input" -vf "hue=H=200:S=1.5"', 'glitch');
Future<String> addTextOverlay(String input, String text) async => _saveAndReturn('-i "$input" -vf "drawtext=text=\'$text\':x=10:y=10:fontsize=24:fontcolor=white"', 'text');

// ✅ AUDIO
Future<String> addTrendingMusic(String input, String audioPath) async => _saveAndReturn('-i "$input" -i "$audioPath" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest', 'music');
Future<String> addSoundEffect(String input, String effect) async => _saveAndReturn('-i "$input" -i assets/audio/$effect.mp3 -filter_complex "[0:a][1:a]amix=inputs=2"', 'sfx');
Future<String> recordAndAddVoiceover(String input) async => _saveAndReturn('-i "$input" -i voiceover.wav -filter_complex amix=inputs=2', 'voice');

// ✅ EXPORT
Future<String> exportHD(String input, {bool is4K=false}) async {
final res = is4K ? 'scale=3840:2160' : 'scale=1920:1080';
return _saveAndReturn('-i "$input" -vf "$res" -c:v libx264 -crf 23', is4K?'4k':'1080p');
}
Future<String> exportAndShare(String input) async => exportHD(input);
}

     

  
