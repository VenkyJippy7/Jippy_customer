import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  RxBool isLoading = false.obs;
  RxString verificationId = ''.obs;

  PhoneNumberController() {
    countryCodeEditingController.value.text = '+91';
  }

  sendCode() async {
    final rawNumber = phoneNUmberEditingController.value.text.trim();
    final countryCode = countryCodeEditingController.value.text.trim();
    // Only allow 10-digit numbers for India
    if (countryCode != '+91' || rawNumber.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(rawNumber)) {
      ShowToastDialog.showToast('Please enter a valid 10-digit Indian mobile number.');
      return;
    }
    final e164Number = '+91' + rawNumber;
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
          this.verificationId.value = verificationId;
          print('Navigating to OtpScreen with verificationId: ' + verificationId);
          Get.to(() => const OtpScreen(), arguments: {
            "countryCode": countryCode,
            "phoneNumber": rawNumber,
            "verificationId": verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
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
        print('Auto sign-in: Navigating to OtpScreen with verificationId: ' + (this.verificationId.value ?? 'null'));
        Get.offAll(() => const OtpScreen(), arguments: {
          "countryCode": countryCodeEditingController.value.text.trim(),
          "phoneNumber": phoneNUmberEditingController.value.text.trim(),
          "verificationId": this.verificationId.value ?? '',
        });
      }
    } catch (e) {
      ShowToastDialog.showToast("Failed to sign in with phone number".tr);
      debugPrint("Error in signInWithPhoneAuthCredential: $e");
    }
  }
}
