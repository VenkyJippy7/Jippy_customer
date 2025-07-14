import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/login_controller.dart';
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

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final LoginController controller = Get.find<LoginController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify Your Number 📱".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
              ),
              Text(
                "${'Enter the OTP sent to your mobile number.'.tr} ${controller.countryCode.value} ${Constant.maskingString(controller.phoneNumber.value, 3)}",
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
                      controller: controller.otpEditingController.value,
                      onCompleted: (v) async {
                        // No 'mounted' check needed in StatelessWidget
                        // Optionally, you can auto-verify here
                      },
                      onChanged: (value) {
                        // No 'mounted' check needed in StatelessWidget
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
                  await controller.verifyOtp();
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
                          controller.resendOtp();
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
  }
}
