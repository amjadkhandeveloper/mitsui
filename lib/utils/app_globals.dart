/// Process-wide values that are not worth injecting via GetIt.
/// [fcmToken] is set in `main()` and read by dashboard FCM registration.
class Global {
  static String? fcmToken;
}
