# TODO

- [x] Inspect repository for existing Firebase App Check code/config.
- [x] Determine current state: App Check activation exists only for Android; web provider not configured.
- [ ] Implement full Firebase App Check for **web + Android**:
  - [ ] Update `lib/main.dart` to activate App Check on web using Debug provider for dev builds and ReCAPTCHA v3 for production builds.
  - [ ] Update Android project files (if needed) to support App Check activation (manifest/Gradle consistency).
  - [ ] Ensure platform-specific initialization won’t crash when provider keys/config are missing (graceful error handling).
- [ ] Add documentation/comments for required Firebase Console setup (App Check registration keys per platform).
- [ ] Run `flutter run -d chrome` and `flutter run -d android` to validate no AppCheck provider warnings/errors.

