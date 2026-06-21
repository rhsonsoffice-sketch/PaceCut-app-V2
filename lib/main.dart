import 'package:flutter/material.dart';
import 'package:pacecut_ai/services/iap_service.dart';
import 'package:pacecut_ai/services/usage_service.dart';
import 'package:pacecut_ai/screens/main_editor_screen.dart'; // NEW: Real editor screen

void main() async {
WidgetsFlutterBinding.ensureInitialized();

await IapService.instance.init();
await UsageService.instance.init();

runApp(const PaceCutApp());
}

class PaceCutApp extends StatelessWidget {
const PaceCutApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'PaceCut AI • Auto Video Editor',
theme: ThemeData.dark(useMaterial3: true),
debugShowCheckedModeBanner: false,
debugShowMaterialGrid: false,
showPerformanceOverlay: false,
home: const MainEditorScreen(), // NEW: Actual working editor
);
}
}
