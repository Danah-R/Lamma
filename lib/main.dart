import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'screens/account.dart';
import 'screens/activities.dart';
import 'screens/activities_colors.dart';
import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'data.dart';
import 'features/clubs/clubs_controller.dart';
import 'features/clubs/clubs_screen.dart';
import 'features/family_chat/family_chat_controller.dart';
import 'features/family_chat/family_chat_screen.dart';
import 'features/games/games_controller.dart';
import 'features/moments/moments_controller.dart';
import 'features/outings/outing_controller.dart';
import 'features/notifications/notification_model.dart';
import 'features/notifications/notification_seed.dart';
import 'features/notifications/widgets/notification_banner.dart';
import 'features/notifications/notifications_controller.dart';
import 'features/moments/moments_screen.dart';
import 'config.dart';
import 'features/moments/widgets/camera_coach.dart';
import 'features/moments/widgets/share_pulse.dart';
import 'features/topics/topics_controller.dart';
import 'splash/lamma_splash.dart';
import 'theme.dart';

/// Debug runs skip splash + onboarding and land on home. Release builds show
/// the full flow. Override with `--dart-define=START_AT_HOME=false`.
const _startAtHome = bool.fromEnvironment(
  'START_AT_HOME',
  defaultValue: kDebugMode,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LammaApp(skipOnboarding: _startAtHome));
}

class LammaApp extends StatefulWidget {
  /// Set to true to jump straight to the app, skipping the splash and
  /// onboarding (used by tests).
  final bool skipOnboarding;

  /// Set to true to skip only the splash screen (used by tests that
  /// exercise onboarding directly).
  final bool skipSplash;

  /// Show the sample "suggested a weekend outing" notification 4 seconds in.
  /// Defaults to [kDemoNotifications].
  final bool? demoNotifications;

  /// Camera-hint behaviour; defaults to [kCoachDemoMode] (see config.dart).
  final bool? coachDemoMode;
  const LammaApp({
    super.key,
    this.skipOnboarding = false,
    this.skipSplash = false,
    this.demoNotifications,
    this.coachDemoMode,
  });
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> {
  late bool _onboarded = widget.skipOnboarding;
  late bool _showSplash = !widget.skipOnboarding && !widget.skipSplash;

  // Created here (above MaterialApp) so the controllers can notify each
  // other: the events they raise land in one shared notifications store.
  final _notifications = NotificationsController();
  late final _clubs = ClubsController(notifications: _notifications);
  late final _moments = MomentsController(notifications: _notifications);
  late final _chat = FamilyChatController(notifications: _notifications);
  final _topics = TopicsController();
  late final _outings = OutingController(notifications: _notifications);
  late final _games = GamesController(notifications: _notifications);
  Timer? _demo;

  @override
  void initState() {
    super.initState();
    seedSample();
    seedNotifications(
      notifications: _notifications,
      moments: _moments,
      chat: _chat,
      clubs: _clubs,
    );
    if (widget.demoNotifications ?? kDemoNotifications) {
      _demo = scheduleDemoNotification(_notifications);
    }
  }

  @override
  void dispose() {
    _demo?.cancel();
    _notifications.dispose();
    _clubs.dispose();
    _moments.dispose();
    _chat.dispose();
    _topics.dispose();
    _outings.dispose();
    _games.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _notifications),
      ChangeNotifierProvider.value(value: _clubs),
      ChangeNotifierProvider.value(value: _topics),
      ChangeNotifierProvider.value(value: _moments),
      ChangeNotifierProvider.value(value: _chat),
      ChangeNotifierProvider.value(value: _outings),
      ChangeNotifierProvider.value(value: _games),
    ],
    child: MaterialApp(
      title: 'لمّه',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: _showSplash
          ? LammaSplash(onStart: () => setState(() => _showSplash = false))
          : (_onboarded
                ? Shell(coachDemoMode: widget.coachDemoMode ?? kCoachDemoMode)
                : OnboardingFlow(
                    onDone: () => setState(() => _onboarded = true),
                  )),
    ),
  );
}

class Shell extends StatefulWidget {
  final bool coachDemoMode;
  const Shell({super.key, this.coachDemoMode = kCoachDemoMode});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  final _keys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  List<(String, IconData, IconData)> _tabs(AppLocalizations l) => [
    (l.navHome, Icons.home_outlined, Icons.home_rounded),
    (l.navLamma, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
    (l.navActivities, Icons.widgets_outlined, Icons.widgets_rounded),
    (l.navAccount, Icons.person_outline_rounded, Icons.person_rounded),
  ];
  static const _muted = Color(0xFFA9B3C6);

  Widget _root(int i) => switch (i) {
    0 => HomePage(onSwitchTab: _select),
    1 => const FamilyChatScreen(),
    2 => const ActivitiesPage(),
    4 => MomentsScreen(key: _momentsKey),
    _ => const AccountPage(),
  };

  static const _activitiesTab = 2;

  Widget _tabNavigator(BuildContext context, int i) {
    final nav = Navigator(
      key: _keys[i],
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _root(i)),
    );
    if (i != _activitiesTab) return nav;
    // Every page pushed inside the Activities tab defaults to its beige.
    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: AC.background),
      child: nav,
    );
  }

  late final NotificationsController _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = context.read<NotificationsController>()
      ..onOpen = _openTarget
      ..addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _coachTimer?.cancel();
    _notifications.removeListener(_onNotificationsChanged);
    if (_notifications.onOpen == _openTarget) _notifications.onOpen = null;
    super.dispose();
  }

  /// Takes the user to what a notification is about.
  void _openTarget(AppNotification n) {
    switch (n.targetRoute) {
      case NotificationRoute.moments:
        _select(_momentsTab);
        final id = int.tryParse(n.targetId ?? '');
        if (id != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _momentsKey.currentState?.scrollToMoment(id),
          );
        }
      case NotificationRoute.chat:
        _select(1);
      case NotificationRoute.activities:
        _select(_activitiesTab);
      case NotificationRoute.games:
      case NotificationRoute.clubs:
        _select(_activitiesTab);
        final nav = _keys[_activitiesTab].currentState;
        nav?.popUntil((r) => r.isFirst);
        nav?.push(
          MaterialPageRoute(
            builder: (_) => n.targetRoute == NotificationRoute.games
                ? const GamesPage()
                : const ClubsScreen(),
          ),
        );
    }
  }

  // ---- the camera hint (shown on the moments page only) ----
  bool _coachArmed = false; // eligible, and 600ms after the page opened
  Timer? _coachTimer;

  void _select(int i) {
    if (i == _i) _keys[i].currentState?.popUntil((r) => r.isFirst);
    setState(() {
      _i = i;
      if (i != _momentsTab) _coachArmed = false;
    });
    if (i == _momentsTab) _scheduleCoach();
  }

  /// 600ms after the moments page opens, show the hint if it is due.
  void _scheduleCoach() {
    _coachTimer?.cancel();
    _coachTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted || _i != _momentsTab || _coachArmed) return;
      if (!await _coachDue()) return;
      if (!mounted || _i != _momentsTab) return;
      setState(() => _coachArmed = true);
    });
  }

  /// Demo mode: every launch, until dismissed or a moment is shared in this
  /// session. Otherwise: once ever (shared_preferences).
  Future<bool> _coachDue() async {
    if (context.read<MomentsController>().didIShareToday) return false;
    if (widget.coachDemoMode) return !CoachSession.dismissed;
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(kCoachSeenKey) ?? false);
    } catch (_) {
      return false; // storage unavailable: don't risk showing it every time
    }
  }

  bool _coachVisible(bool shared) =>
      _coachArmed &&
      _i == _momentsTab &&
      !shared &&
      !_notifications.panelOpen; // hides while the box is open, then returns

  /// "بعدين", "صوّر الحين", the camera, or sharing: gone for this session
  /// (and for good when not in demo mode).
  Future<void> _dismissCoach() async {
    if (!_coachArmed) return;
    setState(() => _coachArmed = false);
    CoachSession.dismissed = true;
    if (widget.coachDemoMode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kCoachSeenKey, true);
    } catch (_) {}
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {}); // the hint hides/returns with the box
  }

  // The camera button opens the moments feed, a tab of its own (index 4),
  // separate from the chat.
  static const _momentsTab = 4;

  final _momentsKey = GlobalKey<MomentsScreenState>();

  // From any other tab the camera goes to the feed; pressing it again while
  // on the feed opens "لحظة جديدة".
  void _shareMoment() {
    _dismissCoach();
    if (_i == _momentsTab &&
        _keys[_momentsTab].currentState?.canPop() != true) {
      _momentsKey.currentState?.openNewMoment();
    } else {
      _select(_momentsTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shared = context.watch<MomentsController>().didIShareToday;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _keys[_i].currentState?.maybePop();
      },
      child: Stack(
        children: [
          Scaffold(
            extendBody: true,
            // The Activities tab is beige: paint the status-bar strip (outside
            // the page's own Scaffold) the same, instead of the theme's white.
            backgroundColor: _i == _activitiesTab ? AC.background : null,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _i,
                children: [
                  // hidden tabs keep their state but must not run animations
                  for (var i = 0; i < 5; i++)
                    TickerMode(
                      enabled: i == _i,
                      child: _tabNavigator(context, i),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: SizedBox(
                  height: 98, // 64 bar + 34 for the raised camera
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: C.navy,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .10),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _item(0, l),
                            _item(1, l),
                            const Expanded(child: SizedBox()),
                            _item(2, l),
                            _item(3, l),
                          ],
                        ),
                      ),
                      // The camera: 64px, raised 34px above the bar (the box is
                      // taller than the bar only so the raised part can be tapped).
                      Positioned(
                        top: 0,
                        child: Semantics(
                          button: true,
                          label: l.momentsShareSemantics,
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _shareMoment,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SharePulse(
                                  active: !shared,
                                  size: 64,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AC.brick,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AC.background,
                                        width: 4,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  l.navShare,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF0B9A5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_coachVisible(shared))
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + 118,
              child: Material(
                type: MaterialType.transparency,
                child: Center(
                  child: CameraCoach(
                    onLater: _dismissCoach,
                    onNow: () {
                      _dismissCoach();
                      _momentsKey.currentState?.openNewMoment();
                    },
                  ),
                ),
              ),
            ),
          const NotificationBannerHost(),
        ],
      ),
    );
  }

  Widget _item(int i, AppLocalizations l) {
    final t = _tabs(l)[i];
    final sel = _i == i;
    final color = sel ? C.coral : _muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? t.$3 : t.$2, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              t.$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
