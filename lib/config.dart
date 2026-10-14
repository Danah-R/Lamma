// App-wide switches.

import 'dart:io' show Platform;

/// True while `flutter test` runs. Things that pop up on their own (like the monthly survey's
/// notification) stay quiet then, so tests of other screens do not see them.
final bool kUnderTest = Platform.environment['FLUTTER_TEST'] == 'true';

/// Hackathon demo mode for the camera hint over the camera button.
///  - true: it shows on the moments page on every launch (cold start), until
///    the user dismisses it or shares a moment in that session. Nothing is
///    remembered on disk.
///  - false: the old behaviour: once ever, remembered in shared_preferences.
const bool kCoachDemoMode = true;
