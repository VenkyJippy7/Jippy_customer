import 'dart:convert';
import 'dart:developer';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/app/video_splash_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/global_setting_controller.dart';
import 'package:customer/controllers/otp_controller.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/models/language_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/styles.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:customer/controllers/dash_board_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('App startup: Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Log App Check enforcement status (manual flag, update as needed)
  const bool appCheckEnforced = false; // Set to true if enforced in Firebase Console
  log('App Check: Enforcement is ${appCheckEnforced ? 'ENABLED' : 'DISABLED'}');
  try {
    log('App Check: Activating...');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    log('App Check: Activated successfully.');
  } catch (e) {
    log('App Check: Activation failed: $e');
  }

  // Initialize other services
  await Get.putAsync(() => ApiService().init());
  DatabaseHelper.instance;
  await Preferences.initPref();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Register OtpController as a permanent dependency
  Get.put(OtpController(), permanent: true);
  // Register DashBoardController as a permanent dependency
  Get.put(DashBoardController(), permanent: true);

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Preferences.getString(Preferences.languageCodeKey)
          .toString()
          .isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.slug.toString());
      } else {
        LanguageModel languageModel =
            LanguageModel(slug: "en", isRtl: false, title: "English");
        Preferences.setString(
            Preferences.languageCodeKey, jsonEncode(languageModel.toJson()));
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'JippyMart Customer'.tr,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
                themeChangeProvider.darkTheme == 0
                    ? true
                    : themeChangeProvider.darkTheme == 1
                        ? false
                        : false,
                context),
            localizationsDelegates: const [
              CountryLocalizations.delegate,
            ],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetBuilder<GlobalSettingController>(
              init: GlobalSettingController(),
              builder: (context) {
                return const VideoSplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
