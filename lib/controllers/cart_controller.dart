import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/cart_screen/oder_placing_screens.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/payment_model/cod_setting_model.dart';
import 'package:customer/models/payment_model/flutter_wave_model.dart';
import 'package:customer/models/payment_model/mercado_pago_model.dart';
import 'package:customer/models/payment_model/mid_trans.dart';
import 'package:customer/models/payment_model/orange_money.dart';
import 'package:customer/models/payment_model/pay_fast_model.dart';
import 'package:customer/models/payment_model/pay_stack_model.dart';
import 'package:customer/models/payment_model/paypal_model.dart';
import 'package:customer/models/payment_model/paytm_model.dart';
import 'package:customer/models/payment_model/razorpay_model.dart';
import 'package:customer/models/payment_model/stripe_model.dart';
import 'package:customer/models/payment_model/wallet_setting_model.dart';
import 'package:customer/models/payment_model/xendit.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/payment/MercadoPagoScreen.dart';
import 'package:customer/payment/PayFastScreen.dart';
import 'package:customer/payment/getPaytmTxtToken.dart';
import 'package:customer/payment/midtrans_screen.dart';
import 'package:customer/payment/orangePayScreen.dart';
import 'package:customer/payment/paystack/pay_stack_screen.dart';
import 'package:customer/payment/paystack/pay_stack_url_model.dart';
import 'package:customer/payment/paystack/paystack_url_genrater.dart';
import 'package:customer/payment/stripe_failed_model.dart';
import 'package:customer/payment/xenditModel.dart';
import 'package:customer/payment/xenditScreen.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class CartController extends GetxController {
  final CartProvider cartProvider = CartProvider();
  Rx<TextEditingController> reMarkController = TextEditingController().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;
  Rx<TextEditingController> tipsController = TextEditingController().obs;

  Rx<ShippingAddress> selectedAddress = ShippingAddress().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;
  RxList<CouponModel> allCouponList = <CouponModel>[].obs;
  RxString selectedFoodType = "Delivery".obs;

  RxString selectedPaymentMethod = ''.obs;

  RxString deliveryType = "instant".obs;
  Rx<DateTime> scheduleDateTime = DateTime.now().obs;
  RxDouble totalDistance = 0.0.obs;
  RxDouble deliveryCharges = 0.0.obs;
  RxDouble subTotal = 0.0.obs;
  RxDouble couponAmount = 0.0.obs;

  RxDouble specialDiscountAmount = 0.0.obs;
  RxDouble specialDiscount = 0.0.obs;
  RxString specialType = "".obs;

  RxDouble deliveryTips = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;

  RxDouble originalDeliveryFee = 0.0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    selectedAddress.value = Constant.selectedLocation;
    getCartData();
    getPaymentSettings();
    ever(subTotal, (_) {
      if (subTotal.value > 599 && selectedPaymentMethod.value == PaymentGateway.cod.name) {
        selectedPaymentMethod.value = PaymentGateway.razorpay.name;
      }
    });
    super.onInit();
  }

  getCartData() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);

        if (cartItem.isNotEmpty) {
          await FireStoreUtils.getVendorById(cartItem.first.vendorID.toString())
              .then(
            (value) {
              if (value != null) {
                vendorModel.value = value;
              }
            },
          );
        }
        calculatePrice();
      },
    );
    selectedFoodType.value = Preferences.getString(Preferences.foodDeliveryType,
        defaultValue: "Delivery".tr);

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );

    await FireStoreUtils.getDeliveryCharge().then(
      (value) {
        if (value != null) {
          deliveryChargeModel.value = value;
          calculatePrice();
        }
      },
    );

    await FireStoreUtils.getAllVendorPublicCoupons(vendorModel.value.id.toString())
        .then(
      (value) {
        couponList.value = value;
      },
    );

    await FireStoreUtils.getAllVendorCoupons(vendorModel.value.id.toString())
        .then(
      (value) {
        allCouponList.value = value;
      },
    );

    // Fetch global coupons (resturant_id: 'ALL', null, or empty)
    await FireStoreUtils.getHomeCoupon().then((globalCoupons) {
      // Filter for coupons where resturant_id is 'ALL', null, or empty
      final filteredGlobalCoupons = globalCoupons.where((c) =>
        c.resturantId == null ||
        c.resturantId == '' ||
        c.resturantId?.toUpperCase() == 'ALL'
      ).toList();
      // Add to both lists if not already present
      couponList.addAll(filteredGlobalCoupons.where((g) => !couponList.any((c) => c.id == g.id)));
      allCouponList.addAll(filteredGlobalCoupons.where((g) => !allCouponList.any((c) => c.id == g.id)));
    });

    // Fetch used coupons for the current user
    final usedCouponsSnapshot = await FirebaseFirestore.instance
        .collection('used_coupons')
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .get();
    final usedCouponIds = usedCouponsSnapshot.docs.map((doc) => doc['couponId'] as String).toSet();

    // Mark used coupons in both lists
    for (var coupon in couponList) {
      coupon.isEnabled = !usedCouponIds.contains(coupon.id);
    }
    for (var coupon in allCouponList) {
      coupon.isEnabled = !usedCouponIds.contains(coupon.id);
    }
  }

  calculatePrice() async {
    // Ensure tax list is loaded before calculation
    if (Constant.taxList == null || Constant.taxList!.isEmpty) {
      Constant.taxList = await FireStoreUtils.getTaxList();
    }
    print('DEBUG: Constant.taxList at calculatePrice = ' + Constant.taxList.toString());
    deliveryCharges.value = 0.0;
    subTotal.value = 0.0;
    couponAmount.value = 0.0;
    specialDiscountAmount.value = 0.0;
    taxAmount.value = 0.0;
    totalAmount.value = 0.0;

    // 1. Calculate subtotal first
    subTotal.value = 0.0;
    for (var element in cartItem) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal.value += double.parse(element.price.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      } else {
        subTotal.value += double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      }
    }
    // 2. Now calculate delivery fee using the correct subtotal
    if (cartItem.isNotEmpty) {
      if (selectedFoodType.value == "Delivery") {
        totalDistance.value = double.parse(Constant.getDistance(
            lat1: selectedAddress.value.location!.latitude.toString(),
            lng1: selectedAddress.value.location!.longitude.toString(),
            lat2: vendorModel.value.latitude.toString(),
            lng2: vendorModel.value.longitude.toString()));
        final dc = deliveryChargeModel.value;
        final subtotal = subTotal.value;
        final threshold = dc.itemTotalThreshold ?? 299;
        final baseCharge = dc.baseDeliveryCharge ?? 23;
        final freeKm = dc.freeDeliveryDistanceKm ?? 7;
        final perKm = dc.perKmChargeAboveFreeDistance ?? 8;
        if (vendorModel.value.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true) {
          deliveryCharges.value = 0.0;
          originalDeliveryFee.value = 0.0;
        } else if (subtotal < threshold) {
          if (totalDistance.value <= freeKm) {
            deliveryCharges.value = baseCharge.toDouble();
            originalDeliveryFee.value = baseCharge.toDouble();
          } else {
            double extraKm = (totalDistance.value - freeKm).ceilToDouble();
            deliveryCharges.value = (baseCharge + (extraKm * perKm)).toDouble();
            originalDeliveryFee.value = deliveryCharges.value;
          }
        } else {
          if (totalDistance.value <= freeKm) {
            deliveryCharges.value = 0.0;
            originalDeliveryFee.value = baseCharge.toDouble();
          } else {
            double extraKm = (totalDistance.value - freeKm).ceilToDouble();
            originalDeliveryFee.value = (baseCharge + (extraKm * perKm)).toDouble();
            deliveryCharges.value = (extraKm * perKm).toDouble();
            print('DEBUG: subtotal >= threshold && totalDistance > freeKm');
            print('DEBUG: baseCharge = ' + baseCharge.toString());
            print('DEBUG: extraKm = ' + extraKm.toString());
            print('DEBUG: perKm = ' + perKm.toString());
            print('DEBUG: originalDeliveryFee = ' + originalDeliveryFee.value.toString());
            print('DEBUG: deliveryCharges = ' + deliveryCharges.value.toString());
          }
        }
        print('DEBUG: subTotal.value = ' + subTotal.value.toString());
        print('DEBUG: totalDistance.value = ' + totalDistance.value.toString());
        print('DEBUG: originalDeliveryFee = ' + originalDeliveryFee.value.toString());
        print('DEBUG: deliveryCharges = ' + deliveryCharges.value.toString());
      }
    }

    if (selectedCouponModel.value.id != null) {
      couponAmount.value = Constant.calculateDiscount(
          amount: subTotal.value.toString(),
          offerModel: selectedCouponModel.value);
    }

    if (vendorModel.value.specialDiscountEnable == true &&
        Constant.specialDiscountOffer == true) {
      final now = DateTime.now();
      var day = DateFormat('EEEE', 'en_US').format(now);
      var date = DateFormat('dd-MM-yyyy').format(now);
      for (var element in vendorModel.value.specialDiscount!) {
        if (day == element.day.toString()) {
          if (element.timeslot!.isNotEmpty) {
            for (var element in element.timeslot!) {
              if (element.discountType == "delivery") {
                var start = DateFormat("dd-MM-yyyy HH:mm")
                    .parse("$date ${element.from}");
                var end =
                    DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
                if (isCurrentDateInRange(start, end)) {
                  specialDiscount.value =
                      double.parse(element.discount.toString());
                  specialType.value = element.type.toString();
                  if (element.type == "percentage") {
                    specialDiscountAmount.value =
                        subTotal * specialDiscount.value / 100;
                  } else {
                    specialDiscountAmount.value = specialDiscount.value;
                  }
                }
              }
            }
          }
        }
      }
    } else {
      specialDiscount.value = double.parse("0");
      specialType.value = "amount";
    }

    print('DEBUG: subTotal.value = ' + subTotal.value.toString());
    print('DEBUG: deliveryCharges.value = ' + deliveryCharges.value.toString());
    // Calculate SGST (5%) on item total, GST (18%) on delivery fee
    double sgst = 0.0;
    double gst = 0.0;
    if (Constant.taxList != null) {
      for (var element in Constant.taxList!) {
        if ((element.title?.toLowerCase() ?? '').contains('sgst')) {
          sgst = Constant.calculateTax(amount: subTotal.value.toString(), taxModel: element);
          print('DEBUG: SGST (5%) on item total: ' + sgst.toString());
        } else if ((element.title?.toLowerCase() ?? '').contains('gst')) {
          gst = Constant.calculateTax(amount: originalDeliveryFee.value.toString(), taxModel: element);
          print('DEBUG: GST (18%) on delivery fee: ' + gst.toString());
        }
      }
    }
    taxAmount.value = sgst + gst;
    print('DEBUG: Total Taxes & Charges = ' + taxAmount.value.toString());

    bool isFreeDelivery = false;
    if (cartItem.isNotEmpty && selectedFoodType.value == "Delivery") {
      final dc = deliveryChargeModel.value;
      final subtotal = subTotal.value;
      final threshold = dc.itemTotalThreshold ?? 299;
      final freeKm = dc.freeDeliveryDistanceKm ?? 7;
      if (subtotal >= threshold && totalDistance.value <= freeKm) {
        isFreeDelivery = true;
      }
    }

    totalAmount.value =
        (subTotal.value - couponAmount.value - specialDiscountAmount.value) +
            taxAmount.value +
            (isFreeDelivery ? 0.0 : deliveryCharges.value) +
            deliveryTips.value;
  }

  addToCart(
      {required CartProductModel cartProductModel,
      required bool isIncrement,
      required int quantity}) {
    if (isIncrement) {
      cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      cartProvider.removeFromCart(cartProductModel, quantity);
    }
    update();
  }

  List<CartProductModel> tempProduc = [];

  placeOrder() async {
    if (selectedPaymentMethod.value == PaymentGateway.cod.name && subTotal.value > 599) {
      ShowToastDialog.showToast("Cash on Delivery is not available for orders above ₹599. Please select another payment method.".tr);
      return;
    }
    if (selectedPaymentMethod.value == PaymentGateway.wallet.name) {
      if (double.parse(userModel.value.walletAmount.toString()) >=
          totalAmount.value) {
        setOrder();
      } else {
        ShowToastDialog.showToast(
            "You don't have sufficient wallet balance to place order".tr);
      }
    } else {
      setOrder();
    }
  }

  setOrder() async {
    ShowToastDialog.showLoader("Please wait".tr);

    // Double-check restaurant open status before placing order
    final latestVendor = await FireStoreUtils.getVendorById(vendorModel.value.id!);
    if (latestVendor?.reststatus == false) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("This restaurant is currently closed. Please try again later.".tr);
      return;
    }

    if ((Constant.isSubscriptionModelApplied == true ||
            Constant.adminCommission?.isEnabled == true) &&
        vendorModel.value.subscriptionPlan != null) {
      await FireStoreUtils.getVendorById(vendorModel.value.id!)
          .then((vender) async {
        if (vender?.subscriptionTotalOrders == '0' ||
            vender?.subscriptionTotalOrders == null) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast(
              "This vendor has reached their maximum order capacity. Please select a different vendor or try again later."
                  .tr);
          return;
        }
      });
    }

    for (CartProductModel cartProduct in cartItem) {
      CartProductModel tempCart = cartProduct;
      if (cartProduct.extrasPrice == '0') {
        tempCart.extras = [];
      }
      tempProduc.add(tempCart);
    }

    Map<String, dynamic> specialDiscountMap = {
      'special_discount': specialDiscountAmount.value,
      'special_discount_label': specialDiscount.value,
      'specialType': specialType.value
    };

    OrderModel orderModel = OrderModel();
    // Generate a sequential order ID like Jippy3000006, Jippy3000007, etc.
    // Query for the highest document ID starting with 'Jippy3'
    final querySnapshot = await FirebaseFirestore.instance
        .collection('restaurant_orders')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'Jippy3000000')
        .where(FieldPath.documentId, isLessThan: 'Jippy4') // upper bound for prefix
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .get();
    int maxNumber = 5; // Default starting number (so first is 6)
    if (querySnapshot.docs.isNotEmpty) {
      final id = querySnapshot.docs.first.id;
      final match = RegExp(r'Jippy3(\d{7})').firstMatch(id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxNumber) {
          maxNumber = num;
        }
      }
    }
    final nextNumber = maxNumber + 1;
    orderModel.id = 'Jippy3' + nextNumber.toString().padLeft(7, '0');
    print('DEBUG: Next Order ID = ' + (orderModel.id ?? 'null'));
    orderModel.address = selectedAddress.value;
    orderModel.authorID = FireStoreUtils.getCurrentUid();
    orderModel.author = userModel.value;
    orderModel.vendorID = vendorModel.value.id;
    orderModel.vendor = vendorModel.value;
    orderModel.adminCommission = vendorModel.value.adminCommission != null
        ? vendorModel.value.adminCommission!.amount
        : Constant.adminCommission!.amount;
    orderModel.adminCommissionType = vendorModel.value.adminCommission != null
        ? vendorModel.value.adminCommission!.commissionType
        : Constant.adminCommission!.commissionType;
    orderModel.status = Constant.orderPlaced;
    orderModel.discount = couponAmount.value;
    orderModel.couponId = selectedCouponModel.value.id;
    orderModel.taxSetting = Constant.taxList;
    print('DEBUG: Tax List at order = ' + Constant.taxList.toString());
    orderModel.paymentMethod = selectedPaymentMethod.value;
    orderModel.products = cartItem;
    orderModel.specialDiscount = specialDiscountMap;
    orderModel.couponCode = selectedCouponModel.value.code;
    orderModel.deliveryCharge = deliveryCharges.value.toString();
    orderModel.tipAmount = deliveryTips.value.toString();
    orderModel.notes = reMarkController.value.text;
    orderModel.takeAway =
        selectedFoodType.value == "Delivery".tr ? false : true;
    orderModel.createdAt = Timestamp.now();
    orderModel.scheduleTime = deliveryType.value == "schedule".tr
        ? Timestamp.fromDate(scheduleDateTime.value)
        : null;

    if (selectedPaymentMethod.value == PaymentGateway.wallet.name) {
      WalletTransactionModel transactionModel = WalletTransactionModel(
          id: Constant.getUuid(),
          amount: double.parse(totalAmount.value.toString()),
          date: Timestamp.now(),
          paymentMethod: PaymentGateway.wallet.name,
          transactionUser: "user",
          userId: FireStoreUtils.getCurrentUid(),
          isTopup: false,
          orderId: orderModel.id,
          note: "Order Amount debited".tr,
          paymentStatus: "success".tr);

      await FireStoreUtils.setWalletTransaction(transactionModel)
          .then((value) async {
        if (value == true) {
          await FireStoreUtils.updateUserWallet(
                  amount: "-${totalAmount.value.toString()}",
                  userId: FireStoreUtils.getCurrentUid())
              .then((value) {});
        }
      });
    }

    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils.getProductById(tempProduc[i].id!.split('~').first)
          .then((value) async {
        ProductModel? productModel = value;
        if (tempProduc[i].variantInfo != null) {
          if (productModel!.itemAttribute != null) {
            for (int j = 0;
                j < productModel.itemAttribute!.variants!.length;
                j++) {
              if (productModel.itemAttribute!.variants![j].variantId ==
                  tempProduc[i].id!.split('~').last) {
                if (productModel.itemAttribute!.variants![j].variantQuantity !=
                    "-1") {
                  productModel.itemAttribute!.variants![j].variantQuantity =
                      (int.parse(productModel
                                  .itemAttribute!.variants![j].variantQuantity
                                  .toString()) -
                              tempProduc[i].quantity!)
                          .toString();
                }
              }
            }
          } else {
            if (productModel.quantity != -1) {
              productModel.quantity =
                  (productModel.quantity! - tempProduc[i].quantity!);
            }
          }
        } else {
          if (productModel!.quantity != -1) {
            productModel.quantity =
                (productModel.quantity! - tempProduc[i].quantity!);
          }
        }

        await FireStoreUtils.setProduct(productModel);
      });
    }

    // Store the order using Firestore .set() with orderModel.id as the document ID
    await FirebaseFirestore.instance
        .collection('restaurant_orders')
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) async {
      ShowToastDialog.closeLoader();
      // Record used coupon for this user if a coupon was used
      if (orderModel.couponId != null && orderModel.couponId!.isNotEmpty) {
        await markCouponAsUsed(orderModel.couponId!);
      }
      await FireStoreUtils.getUserProfile(
              orderModel.vendor!.author.toString())
          .then(
        (value) {
          if (value != null) {
            if (orderModel.scheduleTime != null) {
              SendNotification.sendFcmMessage(
                  Constant.scheduleOrder, value.fcmToken ?? '', {});
            } else {
              SendNotification.sendFcmMessage(
                  Constant.newOrderPlaced, value.fcmToken ?? '', {});
            }
          }
        },
      );
      await Constant.sendOrderEmail(orderModel: orderModel);
      Get.off(const OrderPlacingScreen(),
          arguments: {"orderModel": orderModel});
    });
  }

  Rx<WalletSettingModel> walletSettingModel = WalletSettingModel().obs;
  Rx<CodSettingModel> cashOnDeliverySettingModel = CodSettingModel().obs;
  Rx<PayFastModel> payFastModel = PayFastModel().obs;
  Rx<MercadoPagoModel> mercadoPagoModel = MercadoPagoModel().obs;
  Rx<PayPalModel> payPalModel = PayPalModel().obs;
  Rx<StripeModel> stripeModel = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveModel = FlutterWaveModel().obs;
  Rx<PayStackModel> payStackModel = PayStackModel().obs;
  Rx<PaytmModel> paytmModel = PaytmModel().obs;
  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;

  Rx<MidTrans> midTransModel = MidTrans().obs;
  Rx<OrangeMoney> orangeMoneyModel = OrangeMoney().obs;
  Rx<Xendit> xenditModel = Xendit().obs;

  getPaymentSettings() async {
    await FireStoreUtils.getPaymentSettingsData().then(
      (value) {
        stripeModel.value = StripeModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.stripeSettings)));
        payPalModel.value = PayPalModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.paypalSettings)));
        payStackModel.value = PayStackModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.payStack)));
        mercadoPagoModel.value = MercadoPagoModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.mercadoPago)));
        flutterWaveModel.value = FlutterWaveModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.flutterWave)));
        paytmModel.value = PaytmModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.paytmSettings)));
        payFastModel.value = PayFastModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.payFastSettings)));
        razorPayModel.value = RazorPayModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.razorpaySettings)));
        midTransModel.value = MidTrans.fromJson(
            jsonDecode(Preferences.getString(Preferences.midTransSettings)));
        orangeMoneyModel.value = OrangeMoney.fromJson(
            jsonDecode(Preferences.getString(Preferences.orangeMoneySettings)));
        xenditModel.value = Xendit.fromJson(
            jsonDecode(Preferences.getString(Preferences.xenditSettings)));
        walletSettingModel.value = WalletSettingModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.walletSettings)));
        cashOnDeliverySettingModel.value = CodSettingModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.codSettings)));

        if (walletSettingModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.wallet.name;
        } else if (cashOnDeliverySettingModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.cod.name;
        } else if (stripeModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.stripe.name;
        } else if (payPalModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.paypal.name;
        } else if (payStackModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.payStack.name;
        } else if (mercadoPagoModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.mercadoPago.name;
        } else if (flutterWaveModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.flutterWave.name;
        } else if (paytmModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.paytm.name;
        } else if (payFastModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.payFast.name;
        } else if (razorPayModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.razorpay.name;
        } else if (midTransModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.midTrans.name;
        } else if (orangeMoneyModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.orangeMoney.name;
        } else if (xenditModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.xendit.name;
        }
        Stripe.publishableKey =
            stripeModel.value.clientpublishableKey.toString();
        Stripe.merchantIdentifier = 'Foodie Customer';
        Stripe.instance.applySettings();
        setRef();

        razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
        razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      },
    );
  }

  // Strip
  Future<void> stripeMakePayment({required String amount}) async {
    log(double.parse(amount).toStringAsFixed(0));
    try {
      Map<String, dynamic>? paymentIntentData =
          await createStripeIntent(amount: amount);
      log("stripe Responce====>$paymentIntentData");
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.".tr);
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'IN',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                customFlow: true,
                style: ThemeMode.system,
                appearance: PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppThemeData.primary300,
                  ),
                ),
                merchantDisplayName: 'GoRide'));
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ShowToastDialog.showToast("Payment successfully".tr);
        placeOrder();
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName(),
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "IN",
      };
      var stripeSecret = stripeModel.value.stripeSecret;
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  //mercadoo
  mercadoPagoMakePayment(
      {required BuildContext context, required String amount}) async {
    final headers = {
      'Authorization': 'Bearer ${mercadoPagoModel.value.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "BRL", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.email},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return":
          "approved" // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['init_point']))!.then((value) {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!!".tr);
          placeOrder();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
        }
      });
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

//Paypal
  paypalPaymentSheet(String amount, context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: payPalModel.value.isLive == true ? false : true,
            clientId: payPalModel.value.paypalClient ?? '',
            secretKey: payPalModel.value.paypalSecret ?? '',
            returnURL: "com.parkme://paypalpay",
            cancelURL: "com.parkme://paypalpay",
            transactions: [
              {
                "amount": {
                  "total": amount,
                  "currency": "USD",
                  "details": {"subtotal": amount}
                },
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              placeOrder();
              ShowToastDialog.showToast("Payment Successful!!".tr);
            },
            onError: (error) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
            },
            onCancel: (params) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
            }),
      ),
    );
  }

  ///PayStack Payment Method
  payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(),
            currency: "ZAR",
            secretKey: payStackModel.value.secretKey.toString(),
            userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel0 = value;
        Get.to(PayStackScreen(
          secretKey: payStackModel.value.secretKey.toString(),
          callBackUrl: payStackModel.value.callbackURL.toString(),
          initialURl: payStackModel0.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel0.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!".tr);
            placeOrder();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
          }
        });
      } else {
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.".tr);
      }
    });
  }

  //flutter wave Payment Method
  flutterWaveInitiatePayment(
      {required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${flutterWaveModel.value.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber, // Add a real phone number
        "name": userModel.value.fullName(), // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!
          .then((value) {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!!".tr);
          placeOrder();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!".tr);
        }
      });
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  String? _ref;

  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // payFast
  payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(
            payFastSettingData: payFastModel.value,
            amount: amount.toString(),
            userModel: userModel.value)
        .then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(
          htmlData: value!, payFastSettingData: payFastModel.value));
      if (isDone) {
        Get.back();
        ShowToastDialog.showToast("Payment successfully".tr);
        placeOrder();
      } else {
        Get.back();
        ShowToastDialog.showToast("Payment Failed".tr);
      }
    });
  }

  ///Paytm payment function
  getPaytmCheckSum(context, {required double amount}) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    String getChecksum = "${Constant.globalUrl}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmModel.value.paytmMID.toString(),
          "order_id": orderId,
          "key_secret": paytmModel.value.pAYTMMERCHANTKEY.toString(),
        });

    final data = jsonDecode(response.body);
    await verifyCheckSum(
            checkSum: data["code"], amount: amount, orderId: orderId)
        .then((value) {
      initiatePayment(amount: amount, orderId: orderId).then((value) {
        String callback = "";
        if (paytmModel.value.isSandboxEnabled == true) {
          callback =
              "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback =
              "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        GetPaymentTxtTokenModel result = value;
        startTransaction(context,
            txnTokenBy: result.body.txnToken,
            orderId: orderId,
            amount: amount,
            callBackURL: callback,
            isStaging: paytmModel.value.isSandboxEnabled);
      });
    });
  }

  Future<void> startTransaction(context,
      {required String txnTokenBy,
      required orderId,
      required double amount,
      required callBackURL,
      required isStaging}) async {
    // try {
    //   var response = AllInOneSdk.startTransaction(
    //     paytmModel.value.paytmMID.toString(),
    //     orderId,
    //     amount.toString(),
    //     txnTokenBy,
    //     callBackURL,
    //     isStaging,
    //     true,
    //     true,
    //   );
    //
    //   response.then((value) {
    //     if (value!["RESPMSG"] == "Txn Success") {
    //       print("txt done!!");
    //       ShowToastDialog.showToast("Payment Successful!!");
    //       placeOrder();
    //     }
    //   }).catchError((onError) {
    //     if (onError is PlatformException) {
    //       Get.back();
    //
    //       ShowToastDialog.showToast(onError.message.toString());
    //     } else {
    //       log("======>>2");
    //       Get.back();
    //       ShowToastDialog.showToast(onError.message.toString());
    //     }
    //   });
    // } catch (err) {
    //   Get.back();
    //   ShowToastDialog.showToast(err.toString());
    // }
  }

  Future verifyCheckSum(
      {required String checkSum,
      required double amount,
      required orderId}) async {
    String getChecksum = "${Constant.globalUrl}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmModel.value.paytmMID.toString(),
          "order_id": orderId,
          "key_secret": paytmModel.value.pAYTMMERCHANTKEY.toString(),
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(
      {required double amount, required orderId}) async {
    String initiateURL = "${Constant.globalUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (paytmModel.value.isSandboxEnabled == true) {
      callback =
          "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback =
          "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response =
        await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paytmModel.value.paytmMID,
      "order_id": orderId,
      "key_secret": paytmModel.value.pAYTMMERCHANTKEY,
      "amount": amount.toString(),
      "currency": "INR",
      "callback_url": callback,
      "custId": FireStoreUtils.getCurrentUid(),
      "issandbox": paytmModel.value.isSandboxEnabled == true ? "1" : "2",
    });
    log(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null ||
        data["body"]["txnToken"].toString().isEmpty) {
      Get.back();
      ShowToastDialog.showToast(
          "something went wrong, please contact admin.".tr);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayModel.value.razorpayKey,
      'amount': amount * 100,
      'name': 'GoRide',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userModel.value.phoneNumber,
        'email': userModel.value.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Successful!!".tr);
    placeOrder();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Processing!! via".tr);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Failed!!".tr);
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  //Midtrans payment
  midtransMakePayment(
      {required String amount, required BuildContext context}) async {
    await createPaymentLink(amount: amount).then((url) {
      ShowToastDialog.closeLoader();
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!".tr);
            placeOrder();
          } else {
            ShowToastDialog.showToast("Payment Unsuccessful!!".tr);
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var ordersId = const Uuid().v1();
    final url = Uri.parse(midTransModel.value.isSandbox!
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            generateBasicAuthHeader(midTransModel.value.serverKey!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {
          "finish": "https://www.google.com?merchant_order_id=$ordersId"
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['payment_url'];
    } else {
      ShowToastDialog.showToast(
          "something went wrong, please contact admin.".tr);
      return '';
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

  //Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment(
      {required String amount, required BuildContext context}) async {
    reset();
    var id = const Uuid().v4();
    var paymentURL = await fetchToken(
        context: context, orderId: id, amount: amount, currency: 'USD');
    ShowToastDialog.closeLoader();
    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: orangeMoneyModel.value,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!!".tr);
          placeOrder();
          ();
        }
      });
    } else {
      ShowToastDialog.showToast("Payment Unsuccessful!!".tr);
    }
  }

  Future fetchToken(
      {required String orderId,
      required String currency,
      required BuildContext context,
      required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${orangeMoneyModel.value.auth!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
          context: context,
          amountData: amount,
          currency: currency,
          orderIdData: orderId);
    } else {
      ShowToastDialog.showToast(
          "Something went wrong, please contact admin.".tr);
      return '';
    }
  }

  Future webpayment(
      {required String orderIdData,
      required BuildContext context,
      required String currency,
      required String amountData}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = orangeMoneyModel.value.isSandbox! == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": orangeMoneyModel.value.merchantKey ?? '',
      "currency": orangeMoneyModel.value.isSandbox == true ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": orangeMoneyModel.value.returnUrl!.toString(),
      "cancel_url": orangeMoneyModel.value.cancelUrl!.toString(),
      "notif_url": orangeMoneyModel.value.notifUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ShowToastDialog.showToast(
          "Something went wrong, please contact admin.".tr);
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

  //XenditPayment
  xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      ShowToastDialog.closeLoader();
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: xenditModel.value.apiKey!.toString(),
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!".tr);
            placeOrder();
            ();
          } else {
            ShowToastDialog.showToast("Payment Unsuccessful!!".tr);
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          generateBasicAuthHeader(xenditModel.value.apiKey!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  // Add this method to mark a coupon as used for the current user
  Future<void> markCouponAsUsed(String couponId) async {
    final userId = FireStoreUtils.getCurrentUid();
    await FirebaseFirestore.instance.collection('used_coupons').add({
      'userId': userId,
      'couponId': couponId,
      'usedAt': FieldValue.serverTimestamp(),
    });
    // After marking as used, re-fetch coupon lists to update their status
    await getCartData();
  }
}
