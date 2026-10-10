import 'package:flutter/widgets.dart';

/// True when the system asks for reduced motion; games then use plain fades
/// (no slide/scale/float) and instant progress bars.
bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Duration helper: zero when motion is reduced.
Duration motionDuration(BuildContext context, Duration d) =>
    reduceMotion(context) ? Duration.zero : d;
