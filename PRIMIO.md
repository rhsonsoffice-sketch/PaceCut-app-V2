# PaceCut AI

## Overview
A premium short-form video editing tool targeting TikTok and Instagram Reel creators. The app's core value is rapid-cut video pacing automation. Designed as a high-fidelity iOS-style MVP with dark, modern aesthetics.

## Tech Stack & Key Decisions
- `shared_preferences ^2.5.3` (pre-installed) — three persistence stores: session state (`session_signed_in` bool + `session_email` string + `session_is_pro` bool) and drafts list (`drafts_list_v1` JSON array of `DraftProject` objects)
- `provider ^6.1.1` (pre-installed) — `SessionProvider` and `DraftsProvider` both extend `ChangeNotifier`; initialized before `runApp` via `await Future.wait([session.init(), drafts.init()])` so providers have data on the first build pass; injected via `MultiProvider` + `ChangeNotifierProvider.value`
- `uuid ^4.2.1` (pre-installed) — generates stable draft IDs; when `draftTitle` is set the ID is `'draft_${draftTitle.hashCode}'` so repeated Studio visits update rather than duplicate the draft
- `ffmpeg_kit_flutter_new` (^4.1.0, PRIMIO_ADDED) — community-maintained fork of the discontinued `ffmpeg_kit_flutter`; supports Flutter 3.22+ / SDK ^3.7.2; used for device-local trim (`-ss/-to -c copy`) and H.264 compress (`CRF 24, ultrafast`) commands; original package (`ffmpeg_kit_flutter`) is incompatible with current SDK and must NOT be used
- go_router with StatefulShellRoute for persistent bottom nav across 4 tabs; `parentNavigatorKey: _rootNavigatorKey` used on `/studio/edit` to push OVER the shell (no bottom nav visible)
- `file_picker` (PRIMIO_ADDED) for native iOS/Android gallery video picker — used over `image_picker` because it returns a full file path for both iOS and Android without additional plugins
- `video_player` (pre-installed v2.10.0) for real video playback; controller lifecycle owned by `_StudioScreenState` (init, listener, dispose) — never owned by the widget layer
- `image_gallery_saver` (PRIMIO_ADDED) for saving exported video to iOS camera roll / Android gallery — requires `NSPhotoLibraryAddUsageDescription` in Info.plist and `WRITE_EXTERNAL_STORAGE` in AndroidManifest (maxSdkVersion=29)
- flutter_animate for staggered hero banner entrance animations; google_fonts (Inter) for typography

## Architecture
- Four fully implemented tab screens: HomeScreen, StudioScreen, TemplatesScreen, SettingsScreen
- PaywallScreen at `/paywall` — pushed over the shell via `parentNavigatorKey: _rootNavigatorKey`
- StudioScreen reachable two ways: `/studio` tab (no metadata) or `/studio/edit` push over shell (extra Map carries `title`, `videoPath`, `preset`, `duration`, `subtitle`)
- `VideoPlayerController` lifecycle is owned entirely by `_StudioScreenState` — init in `initState`, listener in `_onVideoUpdate`, dispose in `dispose`; never passed as a stateful object to child widgets
- Retention Booster preset: controller auto-seeks to 0.8s after init; listener loops back to 0.8s whenever position exceeds 5.0s during playback
- Export flow: quality picker sheet → `_ExportProgressDialog` (animated circular progress + step labels) → `ImageGallerySaver.saveFile(videoPath)` → SnackBar result; dialog uses `rootNavigator: true` to pop cleanly
- `videoPath` travels from `file_picker` result → `context.push('/studio/edit', extra: {...})` → router extra → `StudioScreen` constructor → `VideoPlayerController.file(File(path))`

## Conventions
- `TemplatePreset` model lives in `lib/models/template_preset.dart`; three `static const` instances (`hookMaster`, `vlogSpeedUp`, `dialoguePuncher`) define `intervalSec`, `capSec`, `presetKey`, `subtitle`, and the device FFmpeg `-vf` filter string; `buildCommand()` returns null on web (caller skips FFmpeg), non-null on device
- `DraftProject` model lives in `lib/models/draft_model.dart`; serialized to/from JSON for `shared_preferences` persistence; `videoPath` is nullable (null = mock/seed draft with placeholder thumbnail)
- `SessionProvider` in `lib/providers/session_provider.dart` — no login/auth UI; `upgradeToPro()` sets `session_is_pro = true`; `isPro` getter drives PRO badge, 4K quality gate, and paywall CTA flow; `signIn`/`signOut` methods remain in the provider but are not exposed in any UI
- `DraftsProvider` in `lib/providers/drafts_provider.dart` — seeded with 2 mock drafts on first launch; `addDraft()` uses upsert-by-id semantics; `DraftsSection` consumes it via `Consumer<DraftsProvider>`; `StudioScreen._persistDraft()` is called inside `_initController` once the `VideoPlayerController` initializes, so every real video import auto-saves to Your Drafts
- All interactive elements use GestureDetector + AnimatedScale for press-state feedback
- HapticFeedback intensity: mediumImpact (create/export), lightImpact (edit tools/back), selectionClick (draft tap)
- Screen-specific widgets live in `widgets/<screen_name>/`; each section is its own public class file
- Theme extension AppColorsExtension holds all custom semantic colors (glow, card surfaces, gradients)
- Section headers use a 3px gradient left-bar accent + titleSmall text as the consistent section header pattern

## Billing & PRO State
- Paywall pricing is GBP: Weekly £1.99/week, Monthly £4.99/month ("BEST VALUE" badge)
- `PaywallScreen` is stateful and owns `_selectedPlan` (0=Weekly, 1=Monthly); passes it to both `PaywallPricingCards` (display) and `PaywallCta` (purchase)
- `IapService` (singleton in `lib/services/iap_service.dart`) wraps `in_app_purchase` package — initialised in `main()` via `IapService.instance.init()`; callbacks `onPurchaseSuccess` / `onPurchaseError` wired in `_PaywallCtaState.initState()` and cleared in `dispose()` to prevent post-unmount calls; product IDs: `com.primio.pacecutai.pro_weekly` and `com.primio.pacecutai.pro_monthly` — must be registered in App Store Connect before going live
- `_IapSimulationDialog` removed — real StoreKit sheet is presented natively by iOS when `IapService.instance.buyProduct()` is called; "Restore Purchases" button calls `IapService.instance.restorePurchases()` (required by Apple Guideline 3.1.1)
- PRO gate on 4K export: `_QualitySheet` receives `isPro` from `_SettingsListState`; selecting "4K Ultra / 60fps" when not PRO closes the sheet and pushes `/paywall` instead
- `ProUpgradeCard` reads `SessionProvider.isPro` via `context.watch` — badge switches FREE/PRO ✓, description and button label update live after purchase
- PRIMIO_ADDITIONS are correctly placed under `dependencies:` (not `dev_dependencies:`)

## Key Patterns & Gotchas
- `FFmpegService` is a pure-static service class in `lib/services/ffmpeg_service.dart`; it owns no state — each call receives `StreamController<double>` for progress and returns `FFmpegResult`; progress is driven by `FFmpegKitConfig.enableStatisticsCallback` normalised against clip duration
- `FFmpegService.applyTemplate({inputPath, template})` is the new template rendering entry point — on web (`kIsWeb`) it skips processing and returns the source path unchanged; on device it runs the full `-vf` filter chain with `-t capSec` duration cap
- Trim state (`_trimStartSec`, `_trimEndSec`, `_trimmedVideoPath`) is owned by `_StudioScreenState`; `QuickEditHub.onTrimChanged` bubbles slider values up; `StudioAppBar.onApplyTrim` is a `Future<String?> Function()` callback that fires trim before compression
- Export flow: quality sheet → `_startFfmpegExport` (optionally calls `onApplyTrim` first) → `_FfmpegExportDialog` (FFmpeg compress via `FFmpegService.compressAndExport`, real `CircularProgressIndicator(value:)`) → `ImageGallerySaver.saveFile` → `FFmpegService.deleteTempFile`
- FFmpeg output files are always written to `getTemporaryDirectory()` — never in gallery until `ImageGallerySaver.saveFile` is called explicitly; temp files are deleted after save
- `showTemplateProcessingOverlay(context)` in `widgets/templates/template_processing_overlay.dart` returns a `BuildContext` for programmatic dismissal via `Navigator.of(overlayCtx, rootNavigator: true).pop()`; always guard with `overlayCtx.mounted` before popping
- Template-first flow: tapping "Use Template" runs `_processAndNavigate` → overlay shown → `applyTemplate` called → overlay dismissed → `DraftsProvider.addDraft()` called → `/studio/edit` pushed; Studio receives `videoPath: null` when no source clip exists (placeholder player mode)
- Press states use AnimatedScale (0.90–0.98) rather than Opacity to feel native-iOS
- Playhead in timeline uses a Column with a glow circle top + gradient-filled Expanded container (LayoutBuilder required to avoid unbounded-height assertion)
- `file_picker` returns `null` on cancel — always null-check `result?.files.single.path` before navigating
- `VideoPlayerController` must be removed from listeners and disposed in the screen's `dispose()`; never dispose it inside a widget
- `_ExportProgressDialog` uses `Navigator.of(context, rootNavigator: true).pop()` to ensure it dismisses even when pushed over the shell route
- Studio push route `/studio/edit` uses `state.extra as Map<String, String?>?` — always null-safe cast

## Design System
- Dark premium aesthetic: deep charcoal (#12101C) surface with purple (#9C5FFF) accents and pink-purple gradients
- `AppTheme.brandPurple` (`#A855F7`) is the bright accent — used for the hero headline text and the "Create New Project" primary CTA background
- Inter font family throughout — w800/w900 for headlines, w600 for labels, w500 for body
- 8px spacing grid (spacingSm=8, spacingMd=16, spacingLg=24, spacingCardLg=29 for 20%-enlarged card); cards use 12-16px border radius
- Glow effects via BoxShadow with purple at 20-55% opacity; Create CTA uses a dual-layer glow (55% blurRadius 32 + 25% blurRadius 64)
- App logo lives at `assets/images/app_logo.png` (1024×1024 PNG); rendered at 200px wide in `_BrandLogo` inside `HomeHeader`; same file copied to `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` for App Store submission
- Export action always uses gradient background + glow shadow to signal primary CTA hierarchy
