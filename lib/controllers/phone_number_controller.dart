import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/play_integrity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;

  sendCode() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      
      // Perform integrity check first
      final isIntegrityValid = await PlayIntegrityService.performIntegrityCheck();
      if (!isIntegrityValid) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Security check failed. Please try again.".tr);
        return;
      }

      await FirebaseAuth.instance
          .verifyPhoneNumber(
              phoneNumber: countryCodeEditingController.value.text + phoneNUmberEditingController.value.text,
              verificationCompleted: (PhoneAuthCredential credential) {},
              verificationFailed: (FirebaseAuthException e) {
                debugPrint("FirebaseAuthException--->${e.message}");
                ShowToastDialog.closeLoader();
                if (e.code == 'invalid-phone-number') {
                  ShowToastDialog.showToast("invalid_phone_number".tr);
                } else {
                  ShowToastDialog.showToast(e.message);
                }
              },
              codeSent: (String verificationId, int? resendToken) {
                ShowToastDialog.closeLoader();
                Get.to(const OtpScreen(), arguments: {
                  "countryCode": countryCodeEditingController.value.text,
                  "phoneNumber": phoneNUmberEditingController.value.text,
                  "verificationId": verificationId,
                });
              },
              codeAutoRetrievalTimeout: (String verificationId) {})
          .catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("multiple_time_request".tr);
      });
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
      debugPrint("Error in sendCode: $e");
    }
  }
}
