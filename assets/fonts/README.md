# Fonts

The app uses **Thmanyah Sans** (ثمانية), registered in `pubspec.yaml` as the
family `Thmanyah`. The font files are licensed: they must **not** be uploaded or
hosted anywhere other than the official site, so they are **not in this
repository** (`.gitignore` excludes `assets/fonts/*.otf`, `*.ttf`, `*.woff2`,
`assets/fonts/thmanyah/`, and `*.zip`).

To build the app, download the font yourself:

1. Get it from the official page, the only source: **https://thmanyah.com**
   (font download, free).
2. Unzip it, and from `thmanyah typeface/thmanyahsans/otf/` copy exactly these
   five files into this folder, without renaming or editing them:

   ```
   assets/fonts/thmanyahsans-Light.otf     (weight 300)
   assets/fonts/thmanyahsans-Regular.otf   (weight 400)
   assets/fonts/thmanyahsans-Medium.otf    (weight 500)
   assets/fonts/thmanyahsans-Bold.otf      (weight 700)
   assets/fonts/thmanyahsans-Black.otf     (weight 900)
   ```

   Do not copy the serif families, the woff2 files, the PDF, or the zip itself.
3. Run `flutter pub get`, then fully restart the app (not hot reload).

Without the files `flutter build` / `flutter run` fails with a missing-asset
error. Nothing about the font goes in `.env`.

The app writes headings as `FontWeight.w700` (Bold). `w800` and `w900` would
pick Black, so use `w700` unless Black is really meant.
