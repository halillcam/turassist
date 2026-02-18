# turassist

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Tour manager notifications (QR checked-in only)

This project sends tour announcements only to users who have scanned their QR for the assigned tour.

### Data flow

- Mobile app saves FCM token into `users/{uid}.fcmTokens`.
- Tour manager announcement writes into `tours/{tourId}/announcements`.
- Cloud Function `fanoutAnnouncementToCheckedInParticipants` creates `users/{uid}/notifications` only for tickets where `tickets.isScanned == true`.
- Cloud Function `sendPushForUserNotification` triggers on new notification docs and sends FCM push.
- Function verifies `tickets` again (`tourId + userId + isScanned=true`) before sending.

### Deploy Cloud Functions

1. Install Firebase CLI and login:
	- `npm install -g firebase-tools`
	- `firebase login`
2. From repository root install dependencies:
	- `cd functions`
	- `npm install`
3. Deploy:
	- `firebase deploy --only functions`
