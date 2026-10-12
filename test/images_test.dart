import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/features/moments/moments_controller.dart';
import 'package:lamma/features/moments/moments_screen.dart';
import 'package:lamma/features/moments/widgets/moment_scene.dart';
import 'package:lamma/features/notifications/notifications_controller.dart';
import 'package:lamma/l10n/app_localizations.dart';
import 'package:lamma/widgets/photo_or_painted.dart';
import 'package:provider/provider.dart';

// 1x1 transparent PNG
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// A bundle that has exactly the given assets.
class _Bundle extends CachingAssetBundle {
  final Set<String> have;
  _Bundle(this.have);

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final k in have) k: <Object>[],
      })!;
    }
    if (have.contains(key)) {
      return ByteData.sublistView(Uint8List.fromList(_png));
    }
    throw FlutterError('Unable to load asset: "$key".');
  }
}

Widget _host(Widget home, [AssetBundle? bundle]) {
  final n = NotificationsController();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: n),
      ChangeNotifierProvider(
        create: (_) => MomentsController(notifications: n),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: bundle == null
          ? home
          : DefaultAssetBundle(bundle: bundle, child: home),
    ),
  );
}

void main() {
  test('every sample scene has a photo name, as agreed', () {
    expect(momentAsset(MomentScene.coffee), 'assets/images/moments/coffee.jpg');
    expect(momentAsset(MomentScene.dinner), 'assets/images/moments/kabsa.jpg');
    expect(momentAsset(MomentScene.park), 'assets/images/moments/park.jpg');
    expect(momentAsset(MomentScene.desert), 'assets/images/moments/desert.jpg');
  });

  testWidgets('no photos yet: the drawn scene shows, no errors reported', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    await t.pumpWidget(_host(const MomentsScreen(), _Bundle({})));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await t.pump(const Duration(milliseconds: 400));
    // any asset error would have been reported to the framework and fail here
    expect(t.takeException(), isNull);
    expect(find.byType(PhotoOrPainted), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MomentScenePainter,
      ),
      findsWidgets,
    );
  });

  testWidgets('when the photo is there it shows by itself', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    final bundle = _Bundle({'assets/images/moments/park.jpg'});
    await t.pumpWidget(_host(const MomentsScreen(), bundle));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await t.pump(const Duration(milliseconds: 400));
    final img = find.descendant(
      of: find.byType(PhotoOrPainted),
      matching: find.byType(Image),
    );
    expect(img, findsNWidgets(4)); // one per moment; only park's file exists
    final image = t.widget<Image>(img.first);
    expect((image.image as ResizeImage).width, isNotNull); // cacheWidth set
    expect(t.takeException(), isNull);
  });
}
