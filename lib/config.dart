// App-wide switches.

/// Hackathon demo mode for the camera hint over the camera button.
///  - true: it shows on the moments page on every launch (cold start), until
///    the user dismisses it or shares a moment in that session. Nothing is
///    remembered on disk.
///  - false: the old behaviour: once ever, remembered in shared_preferences.
const bool kCoachDemoMode = true;
