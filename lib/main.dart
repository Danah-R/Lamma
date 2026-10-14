import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/backend.dart';
import 'config.dart';
import 'data.dart';
import 'features/clubs/clubs_controller.dart';
import 'features/clubs/clubs_screen.dart';
import 'features/family_chat/family_chat_controller.dart';
import 'features/family_chat/family_chat_screen.dart';
import 'features/games/games_controller.dart';
import 'features/moments/moments_controller.dart';
import 'features/moments/moments_screen.dart';
import 'features/moments/widgets/camera_coach.dart';
import 'features/moments/widgets/share_pulse.dart';
import 'features/notifications/notification_model.dart';
import 'features/notifications/notification_seed.dart';
import 'features/notifications/notifications_controller.dart';
import 'features/notifications/widgets/notification_banner.dart';
import 'features/outings/outing_controller.dart';
import 'features/survey/survey_controller.dart';
import 'features/topics/topics_controller.dart';
import 'l10n/app_localizations.dart';
import 'screens/account.dart';
import 'screens/activities.dart';
import 'screens/activities_colors.dart';
import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'splash/lamma_splash.dart';
import 'theme.dart';

/// `--dart-define=START_AT_HOME=true` skips onboarding only (splash, then
/// home). The splash always shows, in debug too.
const _startAtHome = bool.fromEnvironment('START_AT_HOME');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // A returning install signs in silently and, if it already belongs to a family,
  // goes straight into the app. Offline or on any failure, onboarding runs as usual.
  var inFamily = false;
  try {
    await Backend.init();
    inFamily = await Backend.restore();
  } catch (e) {
    debugPrint('Starting without the database: $e');
  }
  runApp(LammaApp(skipOnboarding: inFamily || _startAtHome));
}

class LammaApp extends StatefulWidget {
  /// Set to true to skip onboarding and go to the app after the splash.
  final bool skipOnboarding;

  /// Set to true to skip the splash screen (used by tests).
  final bool skipSplash;

  /// Show the sample "suggested a weekend outing" notification 3.5 seconds in.
  /// Defaults to [kDemoNotifications].
  final bool? demoNotifications;

  /// Camera-hint behaviour; defaults to [kCoachDemoMode] (see config.dart).
  final bool? coachDemoMode;

  /// Whether a new month's survey sends its notification (off by default in tests).
  final bool announceSurvey;
  const LammaApp({
    super.key,
    this.skipOnboarding = false,
    this.skipSplash = false,
    this.demoNotifications,
    this.coachDemoMode,
    this.announceSurvey = true,
  });
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> {
  late bool _onboarded = widget.skipOnboarding;
  // the splash opens every launch; only tests skip it
  late bool _showSplash = !widget.skipSplash;

  // Created here (above MaterialApp) so the controllers can notify each
  // other: the events they raise land in one shared notifications store.
  final _notifications = NotificationsController();
  late final _clubs = ClubsController(notifications: _notifications);
  late final _moments = MomentsController(notifications: _notifications);
  late final _chat = FamilyChatController(notifications: _notifications);
  final _topics = TopicsController();
  late final _survey = SurveyController(notifications: _notifications);
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
    // a new month's survey: sends its notification the first time the app opens that month
    _topics.load(); // my topics saved on this phone
    _survey.init(announce: widget.announceSurvey && !kUnderTest);
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
    _survey.dispose();
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
      ChangeNotifierProvider.value(value: _survey),
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
  static const _muted = Color(0x99FFF7F1); // page cream at 60% on the navy bar
  static const _barHeight = 60.0, _peek = 20.0;

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
      case NotificationRoute.profile:
        _select(3);
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
            // The bar sits on the bottom edge, full width, with a straight top edge. The area
            // under the home indicator is navy too, and the camera button peeks out above.
            bottomNavigationBar: Builder(
              builder: (context) {
                // only part of the home-indicator area is added, so the bar hugs the bottom edge
                final inset = MediaQuery.of(context).padding.bottom * .45;
                return SizedBox(
                  height: _peek + _barHeight + inset,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: _barHeight + inset,
                          padding: EdgeInsets.only(bottom: inset),
                          decoration: BoxDecoration(
                            color: C.navy,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .10),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
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
                      ),
                      // share a moment: centered, peeking out above the bar, with its label underneath
                      Align(
                        alignment: Alignment.topCenter,
                        child: Tooltip(
                          message: l.navShare,
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
                                    size: 56,
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: C.brick,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.navShare,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_coachVisible(shared))
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  MediaQuery.paddingOf(context).bottom * .45 +
                  _peek +
                  _barHeight +
                  12,
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
    final color = sel ? C.peach : _muted;
    return Expanded(
      child: Tooltip(
        message: t.$1,
        child: Semantics(
          button: true,
          selected: sel,
          label: t.$1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _select(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // a soft pill marks the section you are in
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 54,
                  height: 30,
                  decoration: BoxDecoration(
                    color: sel
                        ? C.cream.withValues(alpha: .16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(sel ? t.$3 : t.$2, size: 24, color: color),
                ),
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
        ),
      ),
    );
  }
}
