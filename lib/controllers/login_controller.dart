import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/play_integrity_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  loginWithEmailAndPassword() async {
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      // Validate email and password
      if (emailEditingController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter email".tr);
        return;
      }
      if (passwordEditingController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter password".tr);
        return;
      }

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailEditingController.value.text.trim())) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter a valid email address".tr);
        return;
      }

      // Perform Play Integrity check
      try {
        log('Starting Play Integrity check...');
        final isIntegrityValid = await PlayIntegrityService.performIntegrityCheck();
        if (!isIntegrityValid) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Security check failed. Please try again.".tr);
          return;
        }
        log('Play Integrity check passed');
      } catch (e) {
        log('Play Integrity check error: $e');
        // For development, continue with login
        // In production, you might want to show an error and return
        ShowToastDialog.showToast("Security check warning. Proceeding with login.".tr);
      }

      // Clear any existing auth state
      await FirebaseAuth.instance.signOut();

      // Attempt to sign in
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.value.text.trim(),
        password: passwordEditingController.value.text.trim(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'timeout',
            message: 'Login attempt timed out. Please try again.',
          );
        },
      );

      if (credential.user == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Login failed. Please try again.".tr);
        return;
      }

      // Get user profile
      UserModel? userModel = await FireStoreUtils.getUserProfile(credential.user!.uid);
      log("Login :: ${userModel?.toJson()}");
      
      if (userModel == null) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("User profile not found. Please try again.".tr);
        return;
      }

      if (userModel.role != Constant.userRoleCustomer) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Invalid user role. Please contact administrator.".tr);
        return;
      }

      if (userModel.active != true) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("This user is disabled. Please contact administrator.".tr);
        return;
      }

      // Update FCM token
      userModel.fcmToken = await NotificationService.getToken();
      await FireStoreUtils.updateUser(userModel);
      
      // Handle navigation based on shipping address
      if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
        if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
          Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
        } else {
          Constant.selectedLocation = userModel.shippingAddress!.first;
        }
        ShowToastDialog.closeLoader();
        Get.offAll(() => const DashBoardScreen());
      } else {
        ShowToastDialog.closeLoader();
        Get.offAll(() => const LocationPermissionScreen());
      }
    } on FirebaseAuthException catch (e) {
      ShowToastDialog.closeLoader();
      switch (e.code) {
        case 'user-not-found':
          ShowToastDialog.showToast("No account found with this email. Please check your email or sign up.".tr);
          break;
        case 'wrong-password':
          ShowToastDialog.showToast("Incorrect password. Please try again.".tr);
          break;
        case 'invalid-email':
          ShowToastDialog.showToast("Invalid email format. Please enter a valid email address.".tr);
          break;
        case 'user-disabled':
          ShowToastDialog.showToast("This account has been disabled. Please contact support.".tr);
          break;
        case 'too-many-requests':
          ShowToastDialog.showToast("Too many login attempts. Please try again later.".tr);
          break;
        case 'timeout':
          ShowToastDialog.showToast("Login attempt timed out. Please check your internet connection and try again.".tr);
          break;
        case 'network-request-failed':
          ShowToastDialog.showToast("Network error. Please check your internet connection and try again.".tr);
          break;
        case 'invalid-credential':
          ShowToastDialog.showToast("Invalid email or password. Please try again.".tr);
          break;
        case 'operation-not-allowed':
          ShowToastDialog.showToast("Email/password accounts are not enabled. Please contact support.".tr);
          break;
        default:
          ShowToastDialog.showToast(e.message ?? "An error occurred during login. Please try again.".tr);
      }
      log("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      if (e.toString().contains('network')) {
        ShowToastDialog.showToast("Network error. Please check your internet connection and try again.".tr);
      } else {
        ShowToastDialog.showToast("An unexpected error occurred. Please try again.".tr);
      }
      log("Login error: $e");
    }
  }

  loginWithGoogle() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithGoogle().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.firstName = value.user!.displayName?.split(' ').first;
          userModel.lastName = value.user!.displayName?.split(' ').last;
          userModel.provider = 'google';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "google",
          });
        } else {
          await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
                    } else {
                      Constant.selectedLocation = userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.firstName = value.user!.displayName?.split(' ').first;
              userModel.lastName = value.user!.displayName?.split(' ').last;
              userModel.provider = 'google';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "google",
              });
            }
          });
        }
      }
    });
  }

  loginWithApple() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithApple().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];
        if (userCredential.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = userCredential.user!.uid;
          userModel.email = appleCredential.email;
          userModel.firstName = appleCredential.givenName;
          userModel.lastName = appleCredential.familyName;
          userModel.provider = 'apple';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "apple",
          });
        } else {
          await FireStoreUtils.userExistOrNot(userCredential.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
                    } else {
                      Constant.selectedLocation = userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = userCredential.user!.uid;
              userModel.email = appleCredential.email;
              userModel.firstName = appleCredential.givenName;
              userModel.lastName = appleCredential.familyName;
              userModel.provider = 'apple';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "apple",
              });
            }
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn().catchError((error) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("something_went_wrong".tr);
        return null;
      });

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
    // Trigger the authentication flow
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {"appleCredential": appleCredential, "userCredential": userCredential};
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
