import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  String? verificationId;

  PhoneNumberController() {
    countryCodeEditingController.value.text = '+91';
  }

  sendCode() async {
    final rawNumber = phoneNUmberEditingController.value.text.trim();
    final countryCode = countryCodeEditingController.value.text.trim();
    print('DEBUG: rawNumber="' + rawNumber + '", countryCode="' + countryCode + '"');
    // Only allow 10-digit numbers for India
    if (countryCode != '+91' || rawNumber.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(rawNumber)) {
      ShowToastDialog.showToast('Please enter a valid 10-digit Indian mobile number.');
      return;
    }
    final e164Number = '+91$rawNumber';
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: e164Number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          ShowToastDialog.closeLoader();
          await signInWithPhoneAuthCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ShowToastDialog.closeLoader();
          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("Invalid phone number".tr);
          } else {
            ShowToastDialog.showToast(e.message ?? "Verification failed".tr);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          this.verificationId = verificationId;
          Get.to(() => const OtpScreen(), arguments: {
            "countryCode": countryCode,
            "phoneNumber": rawNumber,
            "verificationId": verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
      debugPrint("Error in sendCode: $e");
    }
  }

  Future<void> signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Handle successful sign in
        Get.offAll(() => const OtpScreen());
      }
    } catch (e) {
      ShowToastDialog.showToast("Failed to sign in with phone number".tr);
      debugPrint("Error in signInWithPhoneAuthCredential: $e");
    }
  }
}
