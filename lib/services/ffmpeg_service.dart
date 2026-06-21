import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:pacecut_ai/services/iap_service.dart';

class FfmpegService {
static final FfmpegService instance = FfmpegService._internal();
factory FfmpegService() => instance;
FfmpegService._internal();

// ✅ WATERMARK: FREE = YES | PAID = NO
String _getWatermark() {
if (IapService.instance.isPremium) return "";
return ",drawtext=text='PaceCut AI':x=w-120:y=h-40:fontsize=22:fontcolor=white@0.8:box=1:boxcolor=black@0.4";
}

// ✅ RESOLUTION: FREE = 1080p | PAID = 1080p + 4K
String _getScale(bool is4K) {
if (is4K) {
if (IapService.instance.isPremium) return "scale=3840:2160"; // ✅ 4K ONLY IF PAID
return "scale=1920:1080"; // ❌ FREE FORCED TO 1080p
}
return "scale=1920:1080"; // ✅ 1080p FOR EVERYONE
}

Future<String> _saveAndReturn(String cmd, String name, {bool is4K = false}) async {
final dir = await getTemporaryDirectory();
final path = '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.mp4';
final fullCmd = '$cmd -vf "${_getScale(is4K)}${_getWatermark()}" -c:a aac "$path"';
await FFmpegKit.execute(fullCmd);
await GallerySaver.saveVideo(path);
return path;
}

// ✅ ALL FEATURES — FOLLOW RULES ABOVE
Future<String> fastCut(String input) async => _saveAndReturn('-i "$input" -t 15 -c:v copy', 'fastcut');
Future<String> autoPacing(String input) async => _saveAndReturn('-i "$input" -filter:v "setpts=0.7*PTS"', 'autopace');
Future<String> addCaptions(String input, List<String> lines) async => _saveAndReturn('-i "$input" -vf "drawtext=text=\'${lines.join('\\n')}\':x=(w-text_w)/2:y=h-100:fontsize=28:fontcolor=white:box=1"', 'captions');
Future<String> changeSpeed(String input, double speed) async => _saveAndReturn('-i "$input" -filter:v "setpts=${1/speed}*PTS"', 'speed');
Future<String> addFilterVintage(String input) async => _saveAndReturn('-i "$input" -vf "colorbalance=rs=0.3:gs=0.3:bs=-0.3"', 'vintage');
Future<String> addTrendingMusic(String input, String audioPath) async => _saveAndReturn('-i "$input" -i "$audioPath" -c:v copy -map 0:v:0 -map 1:a:0 -shortest', 'music');

// ✅ EXPORT: 4K BUTTON ONLY WORKS AFTER PAYMENT
Future<String> exportHD(String input, {bool is4K = false}) async {
return _saveAndReturn('-i "$input" -c:v libx264 -crf 23', is4K ? '4k_video' : '1080p_video', is4K: is4K);
}
Future<String> exportAndShare(String input) async => exportHD(input);
}
