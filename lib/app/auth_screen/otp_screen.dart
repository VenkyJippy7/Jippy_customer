import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/otp_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController otpController;
  late OtpController controller;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    controller = Get.put(OtpController());
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _unfocus() {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        ),
        body: controller.isLoading.value
            ? Constant.loader()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verify Your Number 📱".tr,
                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                      ),
                      Text(
                        "${'Enter the OTP sent to your mobile number.'.tr} ${controller.countryCode.value} ${Constant.maskingString(controller.phoneNumber.value, 3)}".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                          fontSize: 16,
                          fontFamily: AppThemeData.regular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: PinCodeTextField(
                              length: 6,
                              appContext: context,
                              keyboardType: TextInputType.phone,
                              enablePinAutofill: true,
                              hintCharacter: "-",
                              textStyle: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontFamily: AppThemeData.regular,
                              ),
                              pinTheme: PinTheme(
                                fieldHeight: 50,
                                fieldWidth: 40,
                                inactiveFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                selectedFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                activeFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                selectedColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                activeColor: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                inactiveColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                disabledColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: PinCodeFieldShape.box,
                                errorBorderColor: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              cursorColor: AppThemeData.primary300,
                              enableActiveFill: true,
                              controller: otpController,
                              onCompleted: (v) async {
                                if (!mounted) return;
                                // your logic (if any)
                              },
                              onChanged: (value) {
                                if (!mounted) return;
                                // your logic (if any)
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      RoundedButtonFill(
                        title: "Verify & Next".tr,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        onPress: () async {
                          _unfocus();
                          if (otpController.text.length == 6) {
                            ShowToastDialog.showLoader("Verify otp".tr);

                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: otpController.text);
                            String fcmToken = await NotificationService.getToken();
                            await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                              if (value.additionalUserInfo!.isNewUser) {
                                UserModel userModel = UserModel();
                                userModel.id = value.user!.uid;
                                userModel.countryCode = controller.countryCode.value;
                                userModel.phoneNumber = controller.phoneNumber.value;
                                userModel.fcmToken = fcmToken;
                                userModel.provider = 'phone';

                                ShowToastDialog.closeLoader();
                                _unfocus();
                                Get.off(const SignupScreen(), arguments: {
                                  "userModel": userModel,
                                  "type": "mobileNumber",
                                });
                              
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
                                          _unfocus();
                                          Get.offAll(const DashBoardScreen());
                                        } else {
                                          _unfocus();
                                          Get.offAll(const LocationPermissionScreen());
                                        }
                                      
                                        ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
                                        await FirebaseAuth.instance.signOut();
                                        _unfocus();
                                        Get.offAll(const LoginScreen());
                                      }
                                    } else {
                                      await FirebaseAuth.instance.signOut();
                                      _unfocus();
                                      Get.offAll(const LoginScreen());
                                    }
                                  } else {
                                    UserModel userModel = UserModel();
                                    userModel.id = value.user!.uid;
                                    userModel.countryCode = controller.countryCode.value;
                                    userModel.phoneNumber = controller.phoneNumber.value;
                                    userModel.fcmToken = fcmToken;
                                    userModel.provider = 'phone';

                                    _unfocus();
                                    Get.off(const SignupScreen(), arguments: {
                                      "userModel": userModel,
                                      "type": "mobileNumber",
                                    });
                                  }
                                });
                              }
                            }).catchError((error) {
                              ShowToastDialog.closeLoader();
                              ShowToastDialog.showToast("Invalid Code".tr);
                            });
                          } else {
                            ShowToastDialog.showToast("Enter Valid otp".tr);
                          }
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          text: "Didn't receive any code?".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  otpController.clear();
                                  controller.sendOTP();
                                },
                              text: 'Send Again'.tr,
                              style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  fontFamily: AppThemeData.medium,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppThemeData.primary300),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
