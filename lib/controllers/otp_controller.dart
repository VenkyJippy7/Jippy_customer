import 'package:customer/constant/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/utils/preferences.dart';

class OtpController extends GetxController {
  Rx<TextEditingController> otpController = TextEditingController().obs;
  RxString verificationId = ''.obs;
  RxBool isLoading = false.obs;
  RxString countryCode = ''.obs;
  RxString phoneNumber = ''.obs;

  void setVerificationId(String id) {
    verificationId.value = id;
  }

  void verifyOtp(String enteredOtp) async {
    if (enteredOtp.length != 6) {
      ShowToastDialog.showToast("Enter a valid 6-digit OTP");
      return;
    }
    isLoading.value = true;
    ShowToastDialog.showLoader("Verifying OTP...");
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOtp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await Preferences.setBoolean('isOtpVerified', true);
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      Get.offAllNamed('/DashBoardScreen');
    } catch (e) {
      await Preferences.setBoolean('isOtpVerified', false);
      await FirebaseAuth.instance.signOut();
    isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Invalid OTP. Try again.");
    }
  }

  void resendOtp(String phone, String countryCode) async {
    isLoading.value = true;
    try {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCode + phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          isLoading.value = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          ShowToastDialog.showToast("Verification failed: "+(e.message ?? ''));
        },
        codeSent: (String newVerificationId, int? resendToken) {
          isLoading.value = false;
          verificationId.value = newVerificationId;
          ShowToastDialog.showToast("OTP resent");
      },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast("Error: "+e.toString());
    }
  }

  @override
  void onClose() {
    otpController.value.dispose();
    super.onClose();
  }
}
