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
import 'features/moments/moments_controller.dart';
import 'features/notifications/notification_model.dart';
import 'features/notifications/notification_seed.dart';
import 'features/notifications/widgets/notification_banner.dart';
import 'features/notifications/notifications_controller.dart';
import 'features/moments/moments_screen.dart';
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
  const LammaApp({
    super.key,
    this.skipOnboarding = false,
    this.skipSplash = false,
    this.demoNotifications,
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
                ? const Shell()
                : OnboardingFlow(
                    onDone: () => setState(() => _onboarded = true),
                  )),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
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
      ..onOpen = _openTarget;
  }

  @override
  void dispose() {
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

  static const _coachSeenKey = 'moments_coach_seen';
  bool _coach = false;

  void _select(int i) {
    if (i == _i) _keys[i].currentState?.popUntil((r) => r.isFirst);
    setState(() {
      _i = i;
      if (i != _momentsTab) _coach = false;
    });
    if (i == _momentsTab) _maybeShowCoach();
  }

  /// First time the feed opens, and I haven't shared: show the tooltip once.
  Future<void> _maybeShowCoach() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_coachSeenKey) ?? false) return;
      if (!mounted || _i != _momentsTab) return;
      if (context.read<MomentsController>().didIShareToday) return;
      await prefs.setBool(_coachSeenKey, true);
      if (mounted) setState(() => _coach = true);
    } catch (_) {
      // storage unavailable: skip the hint rather than risk showing it every time
    }
  }

  // The camera button opens the moments feed, a tab of its own (index 4),
  // separate from the chat.
  static const _momentsTab = 4;

  final _momentsKey = GlobalKey<MomentsScreenState>();

  // From any other tab the camera goes to the feed; pressing it again while
  // on the feed opens "لحظة جديدة".
  void _shareMoment() {
    if (_coach) setState(() => _coach = false);
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
                  height: 76,
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
                      // share a moment: centered, only slightly raised so it doesn't outweigh the tabs
                      Positioned(
                        bottom: 7,
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
                                  size: 48,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: C.terracotta,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.navShare,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
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
          if (_coach && _i == _momentsTab)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + 118,
              child: Material(
                type: MaterialType.transparency,
                child: Center(
                  child: CameraCoach(
                    onLater: () => setState(() => _coach = false),
                    onNow: () {
                      setState(() => _coach = false);
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
