# Jippy Customer App – Signup & Authentication Flow Documentation

---

## 1. Loader Removal from Search Screen
- Loader code in `lib/app/search_screen/search_screen.dart` is commented out, not deleted, for future reference.

---

## 2. Signup Logic & UserModel Review
- `referralCode` field added to `UserModel` and included in Firestore user document creation.
- All user fields (name, email, phone, etc.) are set during signup.

---

## 3. Email Validation in Signup
- Email validation logic added to the signup form using regex.
- Error message shown for invalid email.

---

## 4. Fixing Undefined Names: Constant and Platform
- Correct imports added for `Constant` and `Platform` to resolve undefined name errors.

---

## 5. Default Country Code and Disabling Country Picker
- `CountryCodePicker` replaced with a static, non-editable `+91` prefix in the phone number field.

---

## 6. Consistent Vertical Spacing in Signup Form
- Used `SizedBox` for consistent vertical spacing between all fields in the signup form.

---

## 7. OTP (One-Time Password) Verification Flow

### Purpose
Securely verify a user's phone number during signup/login using Firebase Auth's SMS OTP.

### Step-by-Step Flow
1. User enters phone number (always `+91`).
2. App calls Firebase Auth's `verifyPhoneNumber`.
3. App navigates to OTP entry screen with `verificationId`.
4. User enters 6-digit OTP.
5. App creates `PhoneAuthCredential` and signs in.
6. Errors (invalid/expired code) are handled with user-friendly messages.
7. "Resend OTP" option is available.

### Best Practices & Troubleshooting
- Store `verificationId` securely.
- Validate OTP input.
- Handle Firebase exceptions.
- Test on real devices.
- Ensure Firebase Console is set up for phone auth.
- Consider SMS Retriever API for auto-fill (Android).

### Sample Code
```dart
// Sending OTP
FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+91{phoneNumber}',
  verificationCompleted: (PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) {},
  codeSent: (String verificationId, int? resendToken) {},
  codeAutoRetrievalTimeout: (String verificationId) {},
);

// Verifying OTP
PhoneAuthCredential credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: enteredOtp,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Invalid code" error | Ensure correct `verificationId` and OTP. Check navigation/state. |
| OTP not received | Check Firebase Console, device network, SMS permissions. |
| Auto-fill not working | Enable SMS Retriever API, check SMS format. |
| Works on emulator, not device | Register device SHA keys in Firebase Console. |

### Files Involved
- `lib/app/auth_screen/phone_number_screen.dart`
- `lib/app/auth_screen/otp_screen.dart`
- `lib/controllers/phone_number_controller.dart`
- `lib/controllers/login_controller.dart`

---

## 8. General Best Practices
- Comment out, don't delete, code that may be needed later.
- Make minimal, clear, and maintainable changes.
- Ensure UI/UX improvements are consistent.

---

## Summary Table

| Step | File(s) Affected | Description |
|------|------------------|-------------|
| 1    | `search_screen.dart` | Loader code commented out |
| 2    | `UserModel`, signup logic | Referral code added and saved |
| 3    | Signup form | Email validation added |
| 4    | Various | Correct imports for `Constant` and `Platform` |
| 5    | Signup form | Static +91 prefix, country picker removed |
| 6    | Signup form | Consistent vertical spacing |
| 7    | `otp_screen.dart`, `phone_number_screen.dart`, controllers | OTP send, entry, verification, error handling |
| 8    | All | Commenting, clarity, maintainability |

