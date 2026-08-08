import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../app/controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../data/repositories/fcm_repository.dart';

const _androidChannel = AndroidNotificationChannel(
  'wc_orders_channel',
  'Order updates',
  description: 'Notifications about your WOOD CARVERS order status',
  importance: Importance.high,
);

/// Must be a top-level function — runs in a separate isolate when the app
/// is backgrounded/terminated. Firebase.initializeApp() must be called
/// again here since this isolate doesn't share state with the main one.
/// Call this from main() via FirebaseMessaging.onBackgroundMessage(...)
/// AFTER Firebase.initializeApp() succeeds there too.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work needed here — the OS shows the notification tray entry
  // itself for background/terminated messages sent with a `notification`
  // payload (which is what the backend sends). This handler exists so
  // Firebase doesn't warn about a missing background handler, and as a
  // hook if you later want to update local state/badge counts.
}

class PushNotificationService extends GetxController {
  final _fcmRepo = FcmRepository();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  final RxBool permissionGranted = false.obs;
  final RxBool registering = false.obs;

  Future<void> init() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final orderId = response.payload;
        if (orderId != null && orderId.isNotEmpty) _goToOrder(orderId);
      },
    );

    // Foreground messages don't show a system tray notification on their
    // own — show one via flutter_local_notifications so the person still
    // sees it while the app is open.
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'WOOD CARVERS';
      final body = message.notification?.body ?? '';
      final orderId = message.data['orderId'];
      _localNotifications.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: orderId,
      );
    });

    // App was backgrounded and the person tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final orderId = message.data['orderId'];
      if (orderId != null) _goToOrder(orderId);
    });

    // App was terminated and launched by tapping the notification.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final orderId = initialMessage?.data['orderId'];
    if (orderId != null) _goToOrder(orderId);

    // Re-register if the token rotates.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn) _fcmRepo.registerToken(token);
    });

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    permissionGranted.value = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    // Keep the token registered whenever the person is (or becomes) logged
    // in and permission is already granted — covers both app boot and
    // logging in mid-session having previously granted permission.
    final auth = Get.find<AuthController>();
    ever(auth.user, (_) {
      if (auth.isLoggedIn && permissionGranted.value) _registerCurrentToken();
    });
    if (permissionGranted.value && auth.isLoggedIn) _registerCurrentToken();
  }

  /// Called from the "Enable notifications" button in Account settings.
  Future<bool> requestAndRegister() async {
    registering.value = true;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      permissionGranted.value = granted;
      if (granted) await _registerCurrentToken();
      return granted;
    } finally {
      registering.value = false;
    }
  }

  Future<void> _registerCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _fcmRepo.registerToken(token);
  }

  void _goToOrder(String orderId) {
    Get.toNamed('${Routes.orders}/$orderId');
  }
}
