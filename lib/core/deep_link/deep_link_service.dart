import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

/// Handles incoming deep links (both cold-start and while app is running).
///
/// Supported URI schemes:
///   • Custom scheme  : `humavolve://product/42`
///   • HTTPS (Web)    : `https://humavolve.com/product/42`
///
/// Usage:
/// ```dart
/// final service = DeepLinkService(navigatorKey: _navigatorKey);
/// await service.init();
/// // … later …
/// service.dispose();
/// ```
class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService({required this.navigatorKey});

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Initialise the service:
  /// 1. Handle the **initial** link that launched the app (cold start).
  /// 2. Subscribe to **subsequent** links while the app is in the foreground.
  Future<void> init() async {
    // Cold-start link (app was opened via a deep link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Small delay so the widget tree is fully built before navigation.
        await Future.delayed(const Duration(milliseconds: 300));
        _handleUri(initialUri);
      }
    } catch (_) {
      // Ignore: no initial link present.
    }

    // Foreground / warm links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {/* silently ignore malformed URIs */},
    );
  }

  /// Cancel the stream subscription and release resources.
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  // ── URI handling ──────────────────────────────────────────────────────────

  /// Parses the incoming [uri] and navigates to the correct screen.
  ///
  /// Recognised patterns
  ///   `humavolve://product/42`
  ///   `https://humavolve.com/product/42`
  void _handleUri(Uri uri) {
    final segments = uri.pathSegments;

    // Expect exactly two path segments: ["product", "<id>"]
    if (segments.length == 2 && segments.first == 'product') {
      final productId = int.tryParse(segments[1]);
      if (productId != null) {
        _navigateTo(AppRoutes.productDetailsPath(productId.toString()));
        return;
      }
    }

    // Unknown link → navigate to home as a safe fallback
    _navigateTo(AppRoutes.home);
  }

  void _navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}
