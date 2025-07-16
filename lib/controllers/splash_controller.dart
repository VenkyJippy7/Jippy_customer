import 'dart:async';
import 'dart:developer';

import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/app/on_boarding_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:customer/app/dash_board_screens/dash_board_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
    print('[SPLASH] === SplashController redirectScreen START ===');
    // Print all signOut calls for debugging
    print('[SPLASH] Checking onboarding status...');
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      print('[SPLASH] Onboarding not finished, navigating to OnBoardingScreen');
      Get.offAll(const OnBoardingScreen());
      return;
    }

    // Log: After reading API token from secure storage
    final apiToken = await secureStorage.read(key: 'api_token');
    print('[SPLASH] api_token from secure storage: $apiToken');

    // Log: After checking FirebaseAuth.instance.currentUser
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    print('[SPLASH] Firebase currentUser: ${firebaseUser?.uid}');
    if (firebaseUser == null) {
      if (apiToken != null && apiToken.isNotEmpty) {
        try {
          print('[SPLASH] Attempting to refresh Firebase custom token from backend...');
          final response = await Dio().post(
            'https://jippymart.in/api/refresh-firebase-token',
            options: Options(headers: {'Authorization': 'Bearer $apiToken'}),
          );
          print('[SPLASH] Backend response: ${response.statusCode} ${response.data}');
          if (response.statusCode == 200 && response.data['firebase_custom_token'] != null) {
            await FirebaseAuth.instance.signInWithCustomToken(response.data['firebase_custom_token']);
            firebaseUser = FirebaseAuth.instance.currentUser;
            print('[SPLASH] Successfully signed in with refreshed Firebase custom token. UID: ${firebaseUser?.uid}');
          } else {
            print('[SPLASH] Failed to get firebase_custom_token from backend.');
          }
        } catch (e) {
          print('[SPLASH] Error while refreshing Firebase custom token: $e');
        }
      } else {
        print('[SPLASH] No api_token found in secure storage.');
      }
    } else {
      print('[SPLASH] Existing Firebase user session found, skipping token refresh.');
    }

    if (firebaseUser != null) {
      print('[SPLASH] User is signed in. Fetching Firestore profile...');
      final userDoc = await FireStoreUtils.getUserProfile(firebaseUser.uid);
      if (userDoc != null) {
        UserModel userModel = userDoc;
        print('[SPLASH] Firestore user profile found: ${userModel.toJson()}');
        if (userModel.role == Constant.userRoleCustomer) {
          if (userModel.active == true) {
            userModel.fcmToken = await NotificationService.getToken();
            await FireStoreUtils.updateUser(userModel);
            if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
              if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
              } else {
                Constant.selectedLocation = userModel.shippingAddress!.first;
              }
              print('[SPLASH] Navigating to DashBoardScreen');
              Get.put(DashBoardController(), permanent: true);
              Get.offAll(const DashBoardScreen());
            } else {
              print('[SPLASH] No shipping address, navigating to LocationPermissionScreen');
              Get.offAll(const LocationPermissionScreen());
            }
            return;
          } else {
            print('[SPLASH] User is inactive, signing out and navigating to LoginScreen');
            await FirebaseAuth.instance.signOut();
            FireStoreUtils.backendUserId = null;
            await Preferences.setBoolean('isOtpVerified', false);
            Get.offAll(const LoginScreen());
            return;
          }
        } else {
          print('[SPLASH] User role is not customer, signing out and navigating to LoginScreen');
          await FirebaseAuth.instance.signOut();
          FireStoreUtils.backendUserId = null;
          await Preferences.setBoolean('isOtpVerified', false);
          Get.offAll(const LoginScreen());
          return;
        }
      } else {
        print('[SPLASH] No Firestore profile found, navigating to SignupScreen');
        Get.offAllNamed('/SignupScreen', arguments: {
          "userModel": UserModel(id: firebaseUser.uid, phoneNumber: firebaseUser.phoneNumber),
          "type": "mobileNumber"
        });
        return;
      }
    }

    print('[SPLASH] No valid session, signing out and navigating to LoginScreen');
    await FirebaseAuth.instance.signOut();
    FireStoreUtils.backendUserId = null;
    await Preferences.setBoolean('isOtpVerified', false);
    Get.offAll(const LoginScreen());
  }

  Future<void> restoreSession() async {
    String? apiToken = await storage.read(key: 'api_token');
    if (apiToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $apiToken';
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        final response = await dio.post('https://your-backend.com/api/refresh-firebase-token');
        if (response.data['success'] == true) {
          await FirebaseAuth.instance.signInWithCustomToken(response.data['firebase_custom_token']);
        }
      }
    }
  }
}
