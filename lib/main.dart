import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'router/app_router.dart';
import 'providers/session_provider.dart';
import 'providers/drafts_provider.dart';
import 'services/iap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence before the widget tree renders so providers
  // have data ready on the very first build pass.
  final session = SessionProvider();
  final drafts = DraftsProvider();
  await Future.wait([
    session.init(),
    drafts.init(),
    IapService.instance.init(), // Start StoreKit purchase stream early
  ]);

  runApp(PaceCutApp(session: session, drafts: drafts));
}

class PaceCutApp extends StatelessWidget {
  final SessionProvider session;
  final DraftsProvider drafts;

  const PaceCutApp({super.key, required this.session, required this.drafts});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: drafts),
      ],
      child: MaterialApp.router(
        title: 'PaceCut AI',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}