# TP Go! — Smart Campus Companion

**Individual Flutter mobile application project** | Temasek Polytechnic, Mobile App Development (CIT2C18)

TP Go! is a campus companion designed for students, staff and visitors to discover locations, navigate campus, save places and obtain AI-powered recommendations.

## Features

- **Campus discovery:** Explore facilities and locations with categories, status, location images and a Flutter map.
- **Admin management:** Add, edit and remove campus locations with Firestore CRUD operations; administrators can update availability and crowd levels.
- **Crowd information:** Crowd levels are **manually updated by an administrator**. They are not automatically sensed or independently live-measured.
- **Personalised saved places:** Save and manage favourite places and filter them by category, crowd level or distance.
- **AI campus assistant:** A Gemini-integrated conversational assistant uses campus-location context for questions and recommendations.
- **Additional flows:** Facility booking, QR/payment-related demonstration screens, local notifications, sharing and optional biometric unlock.
- **Personalisation:** Light/dark themes, accent colours and branded assets.

> This repository preserves a coursework snapshot, not a currently deployed campus service. Some integrations depend on personal Firebase and Gemini configuration. Features were demonstrated in the original project, but this sanitized snapshot has not been independently rebuilt or end-to-end tested.

## Technology

Flutter, Dart, Firebase Authentication, Cloud Firestore, Firebase Storage, Riverpod, Google Gemini REST API integration, `flutter_map`, local notifications and biometric authentication.

## Project structure

```text
lib/             Flutter application source (screens, services, models, providers)
images/          App graphics and campus images
android/         Android platform project files
web/             Web platform project files
windows/         Windows platform project files
test/            Flutter widget tests
screenshots/     Selected images from the final presentation
pubspec.yaml     Dependencies and assets
```

## Setup (own Firebase project required)

1. Install a compatible Flutter SDK and run `flutter pub get`.
2. Create your **own** Firebase project and configure FlutterFire CLI using `flutterfire configure` to regenerate `lib/firebase_options.dart` and the Android `google-services.json` configuration as appropriate.
3. Enable the Firebase products the app uses (such as Authentication, Firestore and Storage), and establish restrictive Firestore security rules. **Do not rely on the client-side admin-email check as an authorization control.**
4. Provide your own Gemini API credential for local development. The original hardcoded credential has been removed from the shared source. Example for a local prototype:

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=YOUR_DEV_KEY --dart-define=TPGO_ADMIN_EMAIL=admin@example.com
   ```

   **Security note:** `--dart-define` does **not** securely hide a Gemini key inside a distributed client app. For any deployed/public application, route AI requests through a protected server/backend with appropriate controls.
5. Review the code's service configuration and run `flutter analyze` and `flutter run` after completing setup. This archive has not been verified as runnable without configuration.

## Demo and documentation

- [Recorded project walkthrough](https://youtu.be/Wf8FLahRS2U)
- The `screenshots/` directory includes images of selected pages from the coursework presentation.

## Authorship

Built as an **individual student project** by Mohamad Anis Bin Mohamad Suhaimi. This is an educational portfolio project and is not an official Temasek Polytechnic app.

## Notes

- Crowd statuses are provided through an **admin-maintained** system, not sensor-based real-time occupancy measurement.
- Payment and booking demonstrations should not be interpreted as an official campus payment or booking integration.
- Credentials and Firebase project identifiers have been intentionally omitted from the public snapshot.
