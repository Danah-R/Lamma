# Fonts

The app uses **Thmanyah** (ثمانية), the *sans* family. The font files are
licensed and must not be republished, so they are **not in git**
(`.gitignore` excludes `assets/fonts/*.otf`, `*.ttf`, `*.woff2`, and `*.zip`).

Download the family only from the official site: **https://thmanyah.com**.
Unzip it, and from `thmanyah typeface/thmanyahsans/otf/` copy exactly these
five files, with the same names and no changes, straight into this folder:

```
assets/fonts/thmanyahsans-Light.otf     (weight 300)
assets/fonts/thmanyahsans-Regular.otf   (weight 400)
assets/fonts/thmanyahsans-Medium.otf    (weight 500)
assets/fonts/thmanyahsans-Bold.otf      (weight 700)
assets/fonts/thmanyahsans-Black.otf     (weight 900)
```

Do not copy the serif families, the woff2 files, the PDF, or the zip itself.

They are declared in `pubspec.yaml` under `flutter: fonts:` as the family
`Thmanyah`. Without the files `flutter build` / `flutter run` fails with a
missing-asset error.

The app writes headings as `FontWeight.w700` (Bold). `w900` would pick Black,
and `w800` would pick Black too (Flutter takes the nearest heavier weight), so
use `w700` unless Black is really meant.

Nothing about the font goes in `.env`.
