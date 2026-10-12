# Fonts

The app uses **Thmanyah** (ثمانية). The font files are licensed and must not be
republished, so `assets/fonts/thmanyah/` is in `.gitignore`.

Download them from the official Thmanyah website and put the three files here,
with exactly these names:

```
assets/fonts/thmanyah/thmanyahsans/otf/thmanyahsans-Regular.otf   (weight 400)
assets/fonts/thmanyah/thmanyahsans/otf/thmanyahsans-Medium.otf    (weight 500)
assets/fonts/thmanyah/thmanyahsans/otf/thmanyahsans-Bold.otf      (weight 700)
```

They are declared in `pubspec.yaml` under `flutter: fonts:` as the family
`Thmanyah`. Without the files `flutter build` / `flutter run` fails with a
missing-asset error.

Nothing about the font goes in `.env`.
