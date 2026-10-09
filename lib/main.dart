import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/account.dart';
import 'screens/activities.dart';
import 'screens/home.dart';
import 'screens/lamma.dart';
import 'screens/onboarding.dart';
import 'splash/lamma_splash.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LammaApp());
}

class LammaApp extends StatefulWidget {
  /// Set to true to jump straight to the app, skipping the splash and
  /// onboarding (used by tests).
  final bool skipOnboarding;

  /// Set to true to skip only the splash screen (used by tests that
  /// exercise onboarding directly).
  final bool skipSplash;
  const LammaApp({super.key, this.skipOnboarding = false, this.skipSplash = false});
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> {
  late bool _onboarded = widget.skipOnboarding;
  late bool _showSplash = !widget.skipOnboarding && !widget.skipSplash;

  @override
  Widget build(BuildContext context) => MaterialApp(
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
                : OnboardingFlow(onDone: () => setState(() => _onboarded = true))),
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

  void _select(int i) {
    if (i == _i) _keys[i].currentState?.popUntil((r) => r.isFirst);
    setState(() => _i = i);
  }

  void _shareMoment() {
    setState(() => _i = 1);
    _keys[1].currentState?.popUntil((r) => r.isFirst);
    _keys[1].currentState?.push(MaterialPageRoute(builder: (_) => const ShareMomentPage()));
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
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: _i, children: [
              for (var i = 0; i < 4; i++)
                Navigator(
                  key: _keys[i],
                  onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _root(i)),
                ),
            ]),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 88,
                child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
                  Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: C.navy,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: C.navy.withValues(alpha: .28),
                            blurRadius: 18,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(children: [
                      _item(0, l),
                      _item(1, l),
                      const Expanded(child: SizedBox()),
                      _item(2, l),
                      _item(3, l),
                    ]),
                  ),
                  // centered big button: share a moment
                  Positioned(
                    bottom: 8,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _shareMoment,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: C.terracotta,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: C.navy.withValues(alpha: .25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 2),
                        Text(l.navShare,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800, color: _muted)),
                      ]),
                    ),
                  ),
                ]),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(sel ? t.$3 : t.$2, color: color),
          const SizedBox(height: 4),
          Text(t.$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}
