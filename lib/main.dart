import 'package:flutter/material.dart';

import 'core/deep_link/deep_link_service.dart';
import 'core/router/app_router.dart';
import 'core/theme.dart';
import 'features/splash/screens/splash_screen.dart';

/// A single, app-wide navigator key used by [DeepLinkService] so it can push
/// routes even when there is no BuildContext available (e.g. cold-start).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise deep-link handling before the first frame is drawn.
  final deepLinkService = DeepLinkService(navigatorKey: navigatorKey);
  await deepLinkService.init();

  runApp(MyApp(deepLinkService: deepLinkService));
}

class MyApp extends StatefulWidget {
  final DeepLinkService deepLinkService;

  const MyApp({super.key, required this.deepLinkService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huma Volve',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ── Deep-link & routing ────────────────────────────────────────────
      navigatorKey: navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      // ──────────────────────────────────────────────────────────────────

      home: const SplashScreen(),
    );
  }
}
