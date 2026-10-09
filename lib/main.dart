import 'package:flutter/material.dart';
import 'screens/account.dart';
import 'screens/activities.dart';
import 'screens/home.dart';
import 'screens/lamma.dart';
import 'screens/onboarding.dart';
import 'data.dart';
import 'theme.dart';

void main() => runApp(const LammaApp());

class LammaApp extends StatefulWidget {
  /// Set to true to jump straight to the app (used by tests).
  final bool skipOnboarding;
  const LammaApp({super.key, this.skipOnboarding = false});
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> {
  late bool _onboarded = widget.skipOnboarding;

  @override
  void initState() {
    super.initState();
    seedSample();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lamma',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('en', 'US'),
        home: _onboarded
            ? const Shell()
            : OnboardingFlow(onDone: () => setState(() => _onboarded = true)),
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

  static const _tabs = <(String, IconData, IconData)>[
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Lamma', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
    ('Activity Box', Icons.widgets_outlined, Icons.widgets_rounded),
    ('Account', Icons.person_outline_rounded, Icons.person_rounded),
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
  Widget build(BuildContext context) => PopScope(
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: SizedBox(
                height: 76,
                child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: C.navy,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: .10),
                            blurRadius: 16,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(children: [
                      _item(0),
                      _item(1),
                      const Expanded(child: SizedBox()),
                      _item(2),
                      _item(3),
                    ]),
                  ),
                  // share a moment: centered, only slightly raised so it doesn't outweigh the tabs
                  Positioned(
                    bottom: 7,
                    child: Semantics(
                      button: true,
                      label: 'Share a moment',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _shareMoment,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(color: C.terracotta, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 4),
                          const Text('Share',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );

  Widget _item(int i) {
    final t = _tabs[i];
    final sel = _i == i;
    final color = sel ? C.coral : _muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(i),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(sel ? t.$3 : t.$2, size: 24, color: color),
          const SizedBox(height: 3),
          Text(t.$1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}
