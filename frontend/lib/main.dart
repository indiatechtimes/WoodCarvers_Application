// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'app/bindings/initial_binding.dart';
// import 'app/routes/app_pages.dart';
// import 'app/routes/app_routes.dart';
// import 'app/theme/app_theme.dart';
// import 'app/services/push_notification_service.dart';
// import 'widgets/responsive_frame.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();

//   // Firebase requires google-services.json (Android) / GoogleService-Info.plist
//   // (iOS) to be added to the native projects — see SETUP.md. If they're
//   // missing this throws; push notifications simply won't work until then,
//   // but the rest of the app still runs.
//   try {
//     await Firebase.initializeApp();
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   } catch (e) {
//     debugPrint(
//       'Firebase init skipped/failed — push notifications disabled: $e',
//     );
//   }

//   runApp(const WoodCarversApp());
// }

// class WoodCarversApp extends StatelessWidget {
//   const WoodCarversApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'WOOD CARVERS',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light,
//       initialBinding: InitialBinding(),
//       initialRoute: Routes.splash,
//       getPages: AppPages.pages,
//       builder: (context, child) =>ResponsiveFrame(child: child ?? const SizedBox.shrink()),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/services/push_notification_service.dart';
import 'widgets/responsive_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Firebase requires google-services.json (Android) / GoogleService-Info.plist
  // (iOS) to be added to the native projects — see SETUP.md. If they're
  // missing this throws; push notifications simply won't work until then,
  // but the rest of the app still runs.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint(
      'Firebase init skipped/failed — push notifications disabled: $e',
    );
  }

  runApp(const WoodCarversApp());
}

class WoodCarversApp extends StatelessWidget {
  const WoodCarversApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WOOD CARVERS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      builder: (context, child) =>
          ResponsiveFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
