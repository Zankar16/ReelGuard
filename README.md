# ReelGuard — Android APK build pack (Flutter)

This pack contains the Flutter/Dart UI and Android Kotlin accessibility-service prototype, plus a GitHub Actions workflow that builds a release APK for you in the cloud.

## Important limitations
- The current prototype blocks the **entire Instagram or YouTube app** when enabled; it does **not** detect only Reels or Shorts.
- The daily limit and focus sliders are UI-only. Usage tracking, persistent settings, and daily reset are not implemented.
- Accessibility permission must be enabled manually in Android Settings.
- This workspace does not include a compiled APK. This environment has no Flutter SDK or Android SDK installed, so it cannot compile one locally.

## Build an APK using GitHub Actions
1. Create a new GitHub repository and upload the contents of this folder to the repository root.
2. Open the repository's **Actions** tab and enable workflows if GitHub asks.
3. Choose **Build ReelGuard APK** and click **Run workflow** (or push a commit to `main`).
4. When the run succeeds, open that run and download the `ReelGuard-Android-APK` artifact. It contains `app-release.apk`.
5. Transfer the APK to your Android phone, open it, and allow installation from that source if prompted.

## Local build (if Flutter + Android Studio are installed)
This folder is a source pack, not a fully generated Flutter platform project. Create the platform project first:

```bash
flutter create --platforms=android --org com.example --project-name reelguard build_workspace
cp pubspec.yaml build_workspace/pubspec.yaml
cp -r lib build_workspace/
cp android/app/src/main/kotlin/com/example/reelguard/*.kt build_workspace/android/app/src/main/kotlin/com/example/reelguard/
mkdir -p build_workspace/android/app/src/main/res/xml
cp android/app/src/main/res/xml/reelguard_accessibility_service.xml build_workspace/android/app/src/main/res/xml/
```

Then register the accessibility service in the generated `AndroidManifest.xml` and add the accessibility description string as shown in the `android/` source pack; finally run `flutter pub get` and `flutter build apk --release`.

## Privacy
The app uses an Android Accessibility Service only after the user enables it in system settings. Review the code and permissions before installing any build.
