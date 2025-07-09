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

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      bool isOtpVerified = Preferences.getBoolean('isOtpVerified');
      if (isLogin && isOtpVerified) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
          if (value != null) {
            UserModel userModel = value;
            log(userModel.toJson().toString());
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
                  Get.put(DashBoardController(), permanent: true); // Ensure controller is registered
                  Get.offAll(const DashBoardScreen());
                } else {
                  Get.offAll(const LocationPermissionScreen());
                }
              } else {
                await FirebaseAuth.instance.signOut();
                await Preferences.setBoolean('isOtpVerified', false);
                Get.offAll(const LoginScreen());
              }
            } else {
              await FirebaseAuth.instance.signOut();
              await Preferences.setBoolean('isOtpVerified', false);
              Get.offAll(const LoginScreen());
            }
          }
        });
      } else {
        await FirebaseAuth.instance.signOut();
        await Preferences.setBoolean('isOtpVerified', false);
        Get.offAll(const LoginScreen());
      }
    }
  }
}
