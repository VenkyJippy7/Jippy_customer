import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
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
    log('Login: Starting login process');
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      // Validate email and password
      if (emailEditingController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter email".tr);
        log('Login: Email is empty');
        return;
      }
      if (passwordEditingController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter password".tr);
        log('Login: Password is empty');
        return;
      }
      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailEditingController.value.text.trim())) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter a valid email address".tr);
        log('Login: Invalid email format');
        return;
      }
      // Clear any existing auth state
      await FirebaseAuth.instance.signOut();
      log('Login: Cleared existing auth state');
      // Firebase Auth login
      log('Login: Attempting Firebase Auth sign-in...');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.value.text.trim(),
        password: passwordEditingController.value.text.trim(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          log('Login: Firebase Auth sign-in timed out');
          throw FirebaseAuthException(
            code: 'timeout',
            message: 'Login attempt timed out. Please try again.',
          );
        },
      );
      log('Login: Firebase Auth response: [32m${credential.user?.uid}[0m');
      if (credential.user == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Login failed. Please try again.".tr);
        log('Login: Firebase Auth returned null user');
        return;
      }
      // Get user profile
      log('Login: Fetching user profile from Firestore...');
      UserModel? userModel = await FireStoreUtils.getUserProfile(credential.user!.uid);
      log("Login: User profile: [32m${userModel?.toJson()}\u001b[0m");
      if (userModel == null) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("User profile not found. Please try again.".tr);
        log('Login: User profile not found');
        return;
      }
      if (userModel.role != Constant.userRoleCustomer) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Invalid user role. Please contact administrator.".tr);
        log('Login: Invalid user role');
        return;
      }
      if (userModel.active != true) {
        await FirebaseAuth.instance.signOut();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("This user is disabled. Please contact administrator.".tr);
        log('Login: User is disabled');
        return;
      }
      // Update FCM token
      log('Login: Updating FCM token...');
      userModel.fcmToken = await NotificationService.getToken();
      await FireStoreUtils.updateUser(userModel);
      log('Login: Updated user FCM token');
      // Handle navigation based on shipping address
      if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
        if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
          Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
        } else {
          Constant.selectedLocation = userModel.shippingAddress!.first;
        }
        ShowToastDialog.closeLoader();
        log('Login: Navigation to DashBoardScreen');
        Get.offAll(() => const DashBoardScreen());
      } else {
        ShowToastDialog.closeLoader();
        log('Login: Navigation to LocationPermissionScreen');
        Get.offAll(() => const LocationPermissionScreen());
      }
    } on FirebaseAuthException catch (e) {
      ShowToastDialog.closeLoader();
      log('Login: Firebase Auth Error: ${e.code} - ${e.message}');
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
        default:
          ShowToastDialog.showToast(e.message ?? "An error occurred during login. Please try again.".tr);
      }
    } catch (e, stack) {
      ShowToastDialog.closeLoader();
      log('Login: Error occurred: $e\n$stack');
      if (e.toString().contains('network')) {
        ShowToastDialog.showToast("Network error. Please check your internet connection and try again.".tr);
      } else {
        ShowToastDialog.showToast("An unexpected error occurred. Please try again.".tr);
      }
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
    } catch (e, stack) {
      debugPrint('signInWithApple error: $e\n$stack');
    }
    return null;
  }
}
