import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/account.dart';
import 'screens/activities.dart';
import 'screens/activities_colors.dart';
import 'screens/home.dart';
import 'screens/lamma.dart';
import 'screens/onboarding.dart';
import 'data.dart';
import 'features/clubs/clubs_controller.dart';
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
  const LammaApp({
    super.key,
    this.skipOnboarding = false,
    this.skipSplash = false,
  });
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> {
  late bool _onboarded = widget.skipOnboarding;
  late bool _showSplash = !widget.skipOnboarding && !widget.skipSplash;

  @override
  void initState() {
    super.initState();
    seedSample();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ClubsController()),
      ChangeNotifierProvider(create: (_) => TopicsController()),
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
  final _keys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  List<(String, IconData, IconData)> _tabs(AppLocalizations l) => [
    (l.navHome, Icons.home_outlined, Icons.home_rounded),
    (l.navLamma, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
    (l.navActivities, Icons.widgets_outlined, Icons.widgets_rounded),
    (l.navAccount, Icons.person_outline_rounded, Icons.person_rounded),
  ];
  static const _muted = Color(0xFFA9B3C6);

  Widget _root(int i) => switch (i) {
    0 => HomePage(onSwitchTab: _select),
    1 => const LammaPage(),
    2 => const ActivitiesPage(),
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

  void _select(int i) {
    if (i == _i) _keys[i].currentState?.popUntil((r) => r.isFirst);
    setState(() => _i = i);
  }

  void _shareMoment() {
    setState(() => _i = 1);
    _keys[1].currentState?.popUntil((r) => r.isFirst);
    _keys[1].currentState?.push(
      MaterialPageRoute(builder: (_) => const ShareMomentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _keys[_i].currentState?.maybePop();
      },
      child: Scaffold(
        extendBody: true,
        // The Activities tab is beige: paint the status-bar strip (outside
        // the page's own Scaffold) the same, instead of the theme's white.
        backgroundColor: _i == _activitiesTab ? AC.background : null,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _i,
            children: [for (var i = 0; i < 4; i++) _tabNavigator(context, i)],
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
                      label: l.navShare,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _shareMoment,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
                            const SizedBox(height: 4),
                            Text(
                              l.navShare,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _muted,
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
