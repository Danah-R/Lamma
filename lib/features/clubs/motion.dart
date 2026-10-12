import 'package:flutter/material.dart';

/// Returns [ms] as a Duration, or zero when the user has asked for
/// reduced motion — every animated widget on the clubs screen reads
/// this instead of a bare `Duration(milliseconds: ...)`.
Duration clubsMotionDuration(BuildContext context, int ms) =>
    MediaQuery.of(context).disableAnimations
    ? Duration.zero
    : Duration(milliseconds: ms);
