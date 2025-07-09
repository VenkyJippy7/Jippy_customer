import 'package:badges/badges.dart' as badges;
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/review_list_screen/review_list_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantDetailsController(),
        autoRemove: false,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : InkWell(
              onTap: () {
                Get.to(const CartScreen());
              },
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF48000),
                      Color(0xFFff0404)
                      // AppThemeData.danger200,
                      // AppThemeData.danger300,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cartItem.length} items',
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        color: AppThemeData.grey50,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'View Cart',
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: AppThemeData.grey50,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: Responsive.height(30, context),
                    floating: true,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppThemeData.primary300,
                    title: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey50,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.vendorModel.value.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          controller.vendorModel.value.photos == null ||
                              controller.vendorModel.value.photos!.isEmpty
                              ? Stack(
                            children: [
                              NetworkImageWidget(
                                imageUrl: controller
                                    .vendorModel.value.photo
                                    .toString(),
                                fit: BoxFit.cover,
                                width: Responsive.width(100, context),
                                height: Responsive.height(40, context),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: const Alignment(0.00, -1.00),
                                    end: const Alignment(0, 1),
                                    colors: [
                                      Colors.black.withOpacity(0),
                                      Colors.black
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                              : PageView.builder(
                            physics: const BouncingScrollPhysics(),
                            controller: controller.pageController.value,
                            scrollDirection: Axis.horizontal,
                            itemCount: controller
                                .vendorModel.value.photos!.length,
                            padEnds: false,
                            pageSnapping: true,
                            allowImplicitScrolling: true,
                            itemBuilder:
                                (BuildContext context, int index) {
                              String image = controller
                                  .vendorModel.value.photos![index];
                              return Stack(
                                children: [
                                  NetworkImageWidget(
                                    imageUrl: image.toString(),
                                    fit: BoxFit.cover,
                                    width: Responsive.width(100, context),
                                    height:
                                    Responsive.height(40, context),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin:
                                        const Alignment(0.00, -1.00),
                                        end: const Alignment(0, 1),
                                        colors: [
                                          Colors.black.withOpacity(0),
                                          Colors.black
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Positioned(
                            bottom: 10,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                controller.vendorModel.value.photos!.length,
                                    (index) {
                                  return Obx(
                                        () => Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      alignment: Alignment.centerLeft,
                                      height: 9,
                                      width: 9,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: controller.currentPage.value ==
                                            index
                                            ? AppThemeData.primary300
                                            : AppThemeData.grey300,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: controller.isLoading.value
                  ? Constant.loader()
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.vendorModel.value.title
                                            .toString(),
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 22,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily:
                                          AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                        Responsive.width(78, context),
                                        child: Text(
                                          controller
                                              .vendorModel.value.location
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily:
                                            AppThemeData.medium,
                                            fontWeight: FontWeight.w500,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.primary600
                                            : AppThemeData.primary50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                120)),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_star.svg",
                                              colorFilter:
                                              ColorFilter.mode(
                                                  AppThemeData
                                                      .primary300,
                                                  BlendMode.srcIn),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              Constant.calculateReview(
                                                  reviewCount: controller
                                                      .vendorModel
                                                      .value
                                                      .reviewsCount!
                                                      .toStringAsFixed(0),
                                                  reviewSum: controller
                                                      .vendorModel
                                                      .value
                                                      .reviewsSum
                                                      .toString()),
                                              style: TextStyle(
                                                color:
                                                themeChange.getThem()
                                                    ? AppThemeData
                                                    .primary300
                                                    : AppThemeData
                                                    .primary300,
                                                fontFamily:
                                                AppThemeData.semiBold,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(const ReviewListScreen(),
                                            arguments: {
                                              "vendorModel": controller
                                                  .vendorModel.value
                                            });
                                      },
                                      child: Text(
                                        "${controller.vendorModel.value.reviewsCount} ${'Ratings'.tr}",
                                        style: TextStyle(
                                          decoration:
                                          TextDecoration.underline,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey700,
                                          fontFamily:
                                          AppThemeData.regular,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (controller.vendorModel.value.reststatus == false) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.lock, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text('Closed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: controller.isOpen.value ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          controller.isOpen.value ? Icons.check_circle : Icons.lock,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          controller.isOpen.value ? 'Open' : 'Closed',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (controller.vendorModel.value.workingHours!.isEmpty) {
                                      ShowToastDialog.showToast("Timing is not added by restaurant".tr);
                                    } else {
                                      timeShowBottomSheet(context, controller);
                                    }
                                  },
                                  child: Text(
                                    "View Timings".tr,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppThemeData.secondary300,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                      color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            controller.vendorModel.value.dineInActive ==
                                true ||
                                (controller.vendorModel.value
                                    .openDineTime !=
                                    null &&
                                    controller.vendorModel.value
                                        .openDineTime!.isNotEmpty)
                                ? const SizedBox() // Permanently hide Table Booking
                                : const SizedBox(),
                            controller.couponList.isEmpty
                                ? const SizedBox()
                                : Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,

                                ),
                                Text(
                                  "Additional Offers".tr,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily:
                                    AppThemeData.semiBold,
                                    fontWeight: FontWeight.w600,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CouponListView(
                                  controller: controller,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Menu".tr,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w600,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFieldWidget(
                              controller: controller
                                  .searchEditingController.value,
                              hintText:
                              'Search the dish, food, meals and more...'
                                  .tr,
                              onchange: (value) {
                                controller.searchProduct(value);
                              },
                              prefix: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                    "assets/icons/ic_search.svg"),
                              ),
                            ),
                            const SizedBox(height: 16), // Add spacing between search bar and filters
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (!controller.isVag.value) {
                                      controller.isVag.value = true;
                                      controller.isNonVag.value = false;
                                      controller.filterRecord();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: controller.isVag.value
                                        ? ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary600
                                          : AppThemeData.primary50,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: AppThemeData
                                                .primary300),
                                        borderRadius:
                                        BorderRadius.circular(
                                            120),
                                      ),
                                    )
                                        : ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: themeChange
                                                .getThem()
                                                ? AppThemeData
                                                .grey700
                                                : AppThemeData
                                                .grey200),
                                        borderRadius:
                                        BorderRadius.circular(
                                            120),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_veg.svg",
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Veg'.tr,
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey100
                                                : AppThemeData.grey800,
                                            fontFamily:
                                            AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (!controller.isNonVag.value) {
                                      controller.isNonVag.value = true;
                                      controller.isVag.value = false;
                                      controller.filterRecord();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: controller.isNonVag.value
                                        ? ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary600
                                          : AppThemeData.primary50,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: AppThemeData
                                                .primary300),
                                        borderRadius:
                                        BorderRadius.circular(
                                            120),
                                      ),
                                    )
                                        : ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: themeChange
                                                .getThem()
                                                ? AppThemeData
                                                .grey700
                                                : AppThemeData
                                                .grey200),
                                        borderRadius:
                                        BorderRadius.circular(
                                            120),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_nonveg.svg",
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Non Veg'.tr,
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey100
                                                : AppThemeData.grey800,
                                            fontFamily:
                                            AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (controller.vendorModel.value.reststatus == false || controller.isOpen.value == false) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.lock, color: Colors.red, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'This restaurant is currently closed.',
                                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ]
                      else ...[
                        ProductListView(controller: controller),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  timeShowBottomSheet(
      BuildContext context, RestaurantDetailsController productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.70,
          child: StatefulBuilder(builder: (context1, setState) {
            final themeChange = Provider.of<DarkThemeProvider>(context1);
            return Scaffold(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: ShapeDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: productModel
                            .vendorModel.value.workingHours!.length,
                        itemBuilder: (context, dayIndex) {
                          WorkingHours workingHours = productModel
                              .vendorModel.value.workingHours![dayIndex];
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${workingHours.day}",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w600,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                workingHours.timeslot == null ||
                                    workingHours.timeslot!.isEmpty
                                    ? const SizedBox()
                                    : ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount:
                                  workingHours.timeslot!.length,
                                  itemBuilder: (context, timeIndex) {
                                    Timeslot timeSlotModel =
                                    workingHours
                                        .timeslot![timeIndex];
                                    return Padding(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  vertical: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  const BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      12)),
                                                  border: Border.all(
                                                      color: themeChange.getThem()
                                                          ? AppThemeData
                                                          .grey400
                                                          : AppThemeData
                                                          .grey200)),
                                              child: Center(
                                                child: Text(
                                                  timeSlotModel.from
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily:
                                                    AppThemeData
                                                        .medium,
                                                    fontSize: 14,
                                                    color: themeChange
                                                        .getThem()
                                                        ? AppThemeData
                                                        .grey400
                                                        : AppThemeData
                                                        .grey500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  vertical: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  const BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      12)),
                                                  border: Border.all(
                                                      color: themeChange.getThem()
                                                          ? AppThemeData
                                                          .grey400
                                                          : AppThemeData
                                                          .grey200)),
                                              child: Center(
                                                child: Text(
                                                  timeSlotModel.to
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily:
                                                    AppThemeData
                                                        .medium,
                                                    fontSize: 14,
                                                    color: themeChange
                                                        .getThem()
                                                        ? AppThemeData
                                                        .grey400
                                                        : AppThemeData
                                                        .grey500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ));
  }
}

class CouponListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const CouponListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(9, context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponList.length,
        itemBuilder: (BuildContext context, int index) {
          CouponModel offerModel = controller.couponList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 300, // fixed width for coupon card
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1,
                      color: themeChange.getThem()
                          ? AppThemeData.grey800
                          : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/offer_gif.gif"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          offerModel.discountType == "Fix Price"
                              ? Constant.amountShow(amount: offerModel.discount)
                              : "${offerModel.discount}%",
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey50,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerModel.description.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          offerModel.isEnabled == false
                              ? Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Used",
                              style: TextStyle(
                                fontFamily: AppThemeData.medium,
                                color: AppThemeData.grey400,
                                fontSize: 14,
                              ),
                            ),
                          )
                              : InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: offerModel.code.toString()))
                                  .then((value) {
                                ShowToastDialog.showToast("Copied".tr);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    offerModel.code.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey500,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SvgPicture.asset("assets/icons/ic_copy.svg"),
                                const SizedBox(height: 10, child: VerticalDivider()),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    Constant.timestampToDateTime(offerModel.expiresAt!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey500,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const ProductListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel =
          controller.vendorCategoryList[index];
          return ExpansionTile(
            childrenPadding: EdgeInsets.zero,
            tilePadding: EdgeInsets.zero,
            shape: const Border(),
            initiallyExpanded: true,
            title: Text(
              "${vendorCategoryModel.title.toString()} (${controller.productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList().length})",
              style: TextStyle(
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
                fontWeight: FontWeight.w600,
                color: themeChange.getThem()
                    ? AppThemeData.grey50
                    : AppThemeData.grey900,
              ),
            ),
            children: [
              Obx(
                    () => ListView.builder(
                  itemCount: controller.productList
                      .where((p0) => p0.categoryID == vendorCategoryModel.id)
                      .toList()
                      .length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    ProductModel productModel = controller.productList
                        .where((p0) => p0.categoryID == vendorCategoryModel.id)
                        .toList()[index];

                    bool isItemAvailable = productModel.isAvailable ?? true;
                    String price = "0.0";
                    String disPrice = "0.0";
                    List<String> selectedVariants = [];
                    List<String> selectedIndexVariants = [];
                    List<String> selectedIndexArray = [];
                    if (productModel.itemAttribute != null) {
                      if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                        for (var element
                        in productModel.itemAttribute!.attributes!) {
                          if (element.attributeOptions!.isNotEmpty) {
                            selectedVariants.add(productModel
                                .itemAttribute!
                                .attributes![productModel
                                .itemAttribute!.attributes!
                                .indexOf(element)]
                                .attributeOptions![0]
                                .toString());
                            selectedIndexVariants.add(
                                '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                            selectedIndexArray.add(
                                '${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                          }
                        }
                      }
                      if (productModel.itemAttribute!.variants!
                          .where((element) =>
                      element.variantSku == selectedVariants.join('-'))
                          .isNotEmpty) {
                        price = Constant.productCommissionPrice(
                            controller.vendorModel.value,
                            productModel.itemAttribute!.variants!
                                .where((element) =>
                            element.variantSku ==
                                selectedVariants.join('-'))
                                .first
                                .variantPrice ??
                                '0');
                        disPrice = "0";
                      }
                    } else {
                      price = Constant.productCommissionPrice(
                          controller.vendorModel.value,
                          productModel.price.toString());
                      disPrice =
                      double.parse(productModel.disPrice.toString()) <= 0
                          ? "0"
                          : Constant.productCommissionPrice(
                          controller.vendorModel.value,
                          productModel.disPrice.toString());
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    productModel.nonveg == true
                                        ? SvgPicture.asset(
                                        "assets/icons/ic_nonveg.svg")
                                        : SvgPicture.asset(
                                        "assets/icons/ic_veg.svg"),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      productModel.nonveg == true
                                          ? "Non Veg.".tr
                                          : "Pure veg.".tr,
                                      style: TextStyle(
                                        color: productModel.nonveg == true
                                            ? AppThemeData.danger300
                                            : AppThemeData.success400,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  productModel.name.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (double.parse(disPrice) <= 0)
                                      Text(
                                        Constant.amountShow(amount: price),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(
                                            Constant.amountShow(
                                                amount: disPrice),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            Constant.amountShow(amount: price),
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration:
                                              TextDecoration.lineThrough,
                                              decorationColor:
                                              themeChange.getThem()
                                                  ? AppThemeData.grey500
                                                  : AppThemeData.grey400,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey500
                                                  : AppThemeData.grey400,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (!isItemAvailable)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          "Not Available",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: AppThemeData.medium,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_star.svg",
                                      colorFilter: const ColorFilter.mode(
                                          AppThemeData.warning300,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${Constant.calculateReview(reviewCount: productModel.reviewsCount!.toStringAsFixed(0), reviewSum: productModel.reviewsSum.toString())} (${productModel.reviewsCount!.toStringAsFixed(0)})",
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontFamily: AppThemeData.regular,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${productModel.description}",
                                  maxLines: 2,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontFamily: AppThemeData.regular,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Visibility(
                                  visible: false,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return infoDialog(controller, themeChange, productModel);
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary300
                                              : AppThemeData.secondary300,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Info".tr,
                                          maxLines: 2,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 16,
                                            color: themeChange.getThem()
                                                ? AppThemeData.secondary300
                                                : AppThemeData.secondary300,
                                            fontFamily: AppThemeData.regular,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                                child: ColorFiltered(
                                  colorFilter: isItemAvailable
                                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                      : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                  child: NetworkImageWidget(
                                    imageUrl: productModel.photo.toString(),
                                    fit: BoxFit.cover,
                                    height: Responsive.height(16, context),
                                    width: Responsive.width(34, context),
                                  ),
                                ),
                              ),
                              if (!isItemAvailable)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: InkWell(
                                  onTap: () async {
                                    if (controller.favouriteItemList
                                        .where((p0) =>
                                    p0.productId == productModel.id)
                                        .isNotEmpty) {
                                      FavouriteItemModel favouriteModel =
                                      FavouriteItemModel(
                                          productId: productModel.id,
                                          storeId: controller
                                              .vendorModel.value.id,
                                          userId: FireStoreUtils
                                              .getCurrentUid());
                                      controller.favouriteItemList
                                          .removeWhere((item) =>
                                      item.productId ==
                                          productModel.id);
                                      await FireStoreUtils
                                          .removeFavouriteItem(
                                          favouriteModel);
                                    } else {
                                      FavouriteItemModel favouriteModel =
                                      FavouriteItemModel(
                                          productId: productModel.id,
                                          storeId: controller
                                              .vendorModel.value.id,
                                          userId: FireStoreUtils
                                              .getCurrentUid());
                                      controller.favouriteItemList
                                          .add(favouriteModel);

                                      await FireStoreUtils.setFavouriteItem(
                                          favouriteModel);
                                    }
                                  },
                                  child: Obx(
                                        () => controller.favouriteItemList
                                        .where((p0) =>
                                    p0.productId ==
                                        productModel.id)
                                        .isNotEmpty
                                        ? SvgPicture.asset(
                                      "assets/icons/ic_like_fill.svg",
                                    )
                                        : SvgPicture.asset(
                                      "assets/icons/ic_like.svg",
                                    ),
                                  ),
                                ),
                              ),
                              controller.isOpen.value == false ||
                                  Constant.userModel == null
                                  ? const SizedBox()
                                  : Positioned(
                                bottom: 10,
                                left: 20,
                                right: 20,
                                child: isItemAvailable
                                    ? selectedVariants.isNotEmpty ||
                                    (productModel.addOnsTitle !=
                                        null &&
                                        productModel
                                            .addOnsTitle!
                                            .isNotEmpty)
                                    ? RoundedButtonFill(
                                  title: "Add".tr,
                                  width: 10,
                                  height: 4,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  textColor:
                                  AppThemeData.primary300,
                                  onPress: () async {
                                    controller
                                        .selectedVariants
                                        .clear();
                                    controller
                                        .selectedIndexVariants
                                        .clear();
                                    controller
                                        .selectedIndexArray
                                        .clear();
                                    controller.selectedAddOns
                                        .clear();
                                    controller
                                        .quantity.value = 1;
                                    if (productModel
                                        .itemAttribute !=
                                        null) {
                                      if (productModel
                                          .itemAttribute!
                                          .attributes!
                                          .isNotEmpty) {
                                        for (var element
                                        in productModel
                                            .itemAttribute!
                                            .attributes!) {
                                          if (element
                                              .attributeOptions!
                                              .isNotEmpty) {
                                            controller.selectedVariants.add(productModel
                                                .itemAttribute!
                                                .attributes![productModel
                                                .itemAttribute!
                                                .attributes!
                                                .indexOf(
                                                element)]
                                                .attributeOptions![
                                            0]
                                                .toString());
                                            controller
                                                .selectedIndexVariants
                                                .add(
                                                '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                            controller
                                                .selectedIndexArray
                                                .add(
                                                '${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                                          }
                                        }
                                      }
                                      final bool
                                      productIsInList =
                                      cartItem.any(
                                              (product) =>
                                          product
                                              .id ==
                                              "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");

                                      if (productIsInList) {
                                        CartProductModel
                                        element =
                                        cartItem.firstWhere(
                                                (product) =>
                                            product
                                                .id ==
                                                "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                        controller.quantity
                                            .value =
                                        element.quantity!;
                                        if (element.extras !=
                                            null) {
                                          for (var element
                                          in element
                                              .extras!) {
                                            controller
                                                .selectedAddOns
                                                .add(element);
                                          }
                                        }
                                      }
                                    } else {
                                      if (cartItem
                                          .where((product) =>
                                      product.id ==
                                          "${productModel.id}")
                                          .isNotEmpty) {
                                        CartProductModel
                                        element =
                                        cartItem.firstWhere(
                                                (product) =>
                                            product
                                                .id ==
                                                "${productModel.id}");
                                        controller.quantity
                                            .value =
                                        element.quantity!;
                                        if (element.extras !=
                                            null) {
                                          for (var element
                                          in element
                                              .extras!) {
                                            controller
                                                .selectedAddOns
                                                .add(element);
                                          }
                                        }
                                      }
                                    }
                                    controller.update();
                                    controller.calculatePrice(
                                        productModel);
                                    productDetailsBottomSheet(
                                        context,
                                        productModel);
                                  },
                                )
                                    : Obx(
                                      () => cartItem
                                      .where((p0) =>
                                  p0.id ==
                                      productModel
                                          .id)
                                      .isNotEmpty
                                      ? Container(
                                    width: Responsive
                                        .width(100,
                                        context),
                                    height: Responsive
                                        .height(4,
                                        context),
                                    decoration:
                                    ShapeDecoration(
                                      color: themeChange
                                          .getThem()
                                          ? AppThemeData
                                          .grey900
                                          : AppThemeData
                                          .grey50,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            200),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              controller.addToCart(
                                                productModel: productModel,
                                                price: price,
                                                discountPrice: disPrice,
                                                isIncrement: false,
                                                quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! - 1,
                                              );
                                            },
                                            child: const Icon(Icons.remove),
                                          ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14),
                                            child: Text(
                                              cartItem.where((p0) => p0.id == productModel.id).first.quantity.toString(),
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: AppThemeData.medium,
                                                fontWeight: FontWeight.w500,
                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              if ((cartItem.where((p0) => p0.id == productModel.id).first.quantity ?? 0) < (productModel.quantity ?? 0) || (productModel.quantity ?? 0) == -1) {
                                                controller.addToCart(
                                                  productModel: productModel,
                                                  price: price,
                                                  discountPrice: disPrice,
                                                  isIncrement: true,
                                                  quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! + 1,
                                                );
                                              } else {
                                                ShowToastDialog.showToast("Out of stock".tr);
                                              }
                                            },
                                            child: const Icon(Icons.add),
                                          ),
                                      ],
                                      ),
                                    ),
                                  )
                                      : RoundedButtonFill(
                                    title: "Add".tr,
                                    width: 10,
                                    height: 4,
                                    color: themeChange
                                        .getThem()
                                        ? AppThemeData
                                        .grey900
                                        : AppThemeData
                                        .grey50,
                                    textColor:
                                    AppThemeData
                                        .primary300,
                                    onPress:
                                        () async {
                                      if (1 <=
                                          (productModel.quantity ??
                                              0) ||
                                          (productModel
                                              .quantity ??
                                              0) ==
                                              -1) {
                                        controller.addToCart(
                                            productModel:
                                            productModel,
                                            price:
                                            price,
                                            discountPrice:
                                            disPrice,
                                            isIncrement:
                                            true,
                                            quantity:
                                            1);
                                      } else {
                                        ShowToastDialog
                                            .showToast(
                                            "Out of stock"
                                                .tr);
                                      }
                                    },
                                  ),
                                )
                                    : const SizedBox(), // Removed the grey button completely
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  productDetailsBottomSheet(BuildContext context, ProductModel productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.85,
          child: StatefulBuilder(builder: (context1, setState) {
            return ProductDetailsView(
              productModel: productModel,
            );
          }),
        ));
  }

  infoDialog(RestaurantDetailsController controller, themeChange,
      ProductModel productModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Food Information's".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  productModel.description.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.regular,
                    fontWeight: FontWeight.w400,
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Gram".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.grams.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Calories".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.calories.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Proteins".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.proteins.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Fats".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.fats.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                productModel.productSpecification != null &&
                    productModel.productSpecification!.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Specification".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount:
                      productModel.productSpecification!.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productModel.productSpecification!.keys
                                    .elementAt(index),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.regular,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey300
                                      : AppThemeData.grey600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                productModel.productSpecification!.values
                                    .elementAt(index),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.bold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                RoundedButtonFill(
                  title: "Back".tr,
                  color: AppThemeData.primary300,
                  textColor: AppThemeData.grey50,
                  onPress: () async {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsView extends StatelessWidget {
  final ProductModel productModel;

  const ProductDetailsView({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantDetailsController(),
        builder: (controller) {
          bool isItemAvailable = productModel.isAvailable ?? true;

          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                            child: ColorFiltered(
                              colorFilter: isItemAvailable
                                  ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                  : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                              child: NetworkImageWidget(
                                imageUrl: productModel.photo.toString(),
                                height: Responsive.height(11, context),
                                width: Responsive.width(22, context),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        productModel.name.toString(),
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (controller.favouriteItemList
                                            .where((p0) =>
                                        p0.productId == productModel.id)
                                            .isNotEmpty) {
                                          FavouriteItemModel favouriteModel =
                                          FavouriteItemModel(
                                              productId: productModel.id,
                                              storeId: controller
                                                  .vendorModel.value.id,
                                              userId: FireStoreUtils
                                                  .getCurrentUid());
                                          controller.favouriteItemList
                                              .removeWhere((item) =>
                                          item.productId ==
                                              productModel.id);
                                          await FireStoreUtils
                                              .removeFavouriteItem(
                                              favouriteModel);
                                        } else {
                                          FavouriteItemModel favouriteModel =
                                          FavouriteItemModel(
                                              productId: productModel.id,
                                              storeId: controller
                                                  .vendorModel.value.id,
                                              userId: FireStoreUtils
                                                  .getCurrentUid());
                                          controller.favouriteItemList
                                              .add(favouriteModel);

                                          await FireStoreUtils.setFavouriteItem(
                                              favouriteModel);
                                        }
                                      },
                                      child: Obx(
                                            () => controller.favouriteItemList
                                            .where((p0) =>
                                        p0.productId ==
                                            productModel.id)
                                            .isNotEmpty
                                            ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                            : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                if (!isItemAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Not Available",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                    ),
                                  ),
                                Text(
                                  productModel.description.toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppThemeData.regular,
                                    fontWeight: FontWeight.w400,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  productModel.itemAttribute == null ||
                      productModel.itemAttribute!.attributes!.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                    itemCount:
                    productModel.itemAttribute!.attributes!.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String title = "";
                      for (var element in controller.attributesList) {
                        if (productModel.itemAttribute!.attributes![index]
                            .attributeId ==
                            element.id) {
                          title = element.title.toString();
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: Container(
                          decoration: ShapeDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.grey900
                                : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                productModel
                                    .itemAttribute!
                                    .attributes![index]
                                    .attributeOptions!
                                    .isNotEmpty
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          fontFamily:
                                          AppThemeData.semiBold,
                                          fontWeight:
                                          FontWeight.w600,
                                          color: themeChange
                                              .getThem()
                                              ? AppThemeData.grey100
                                              : AppThemeData
                                              .grey800,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        "Required • Select any 1 option"
                                            .tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          fontFamily:
                                          AppThemeData.medium,
                                          fontWeight:
                                          FontWeight.w500,
                                          color: themeChange
                                              .getThem()
                                              ? AppThemeData.grey400
                                              : AppThemeData
                                              .grey500,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Divider(),
                                    ),
                                  ],
                                )
                                    : Offstage(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      productModel
                                          .itemAttribute!
                                          .attributes![index]
                                          .attributeOptions!
                                          .length,
                                          (i) {
                                        return InkWell(
                                          onTap: isItemAvailable
                                              ? () async {
                                            if (controller
                                                .selectedIndexVariants
                                                .where((element) =>
                                                element.contains(
                                                    '$index _'))
                                                .isEmpty) {
                                              controller.selectedVariants
                                                  .insert(
                                                  index,
                                                  productModel
                                                      .itemAttribute!
                                                      .attributes![
                                                  index]
                                                      .attributeOptions![
                                                  i]
                                                      .toString());
                                              controller
                                                  .selectedIndexVariants
                                                  .add(
                                                  '$index _${productModel.itemAttribute!.attributes![index].attributeOptions![i].toString()}');
                                              controller
                                                  .selectedIndexArray
                                                  .add('${index}_$i');
                                            } else {
                                              controller
                                                  .selectedIndexArray
                                                  .remove(
                                                  '${index}_${productModel.itemAttribute!.attributes![index].attributeOptions?.indexOf(controller.selectedIndexVariants.where((element) => element.contains('$index _')).first.replaceAll('$index _', ''))}');
                                              controller.selectedVariants
                                                  .removeAt(index);
                                              controller
                                                  .selectedIndexVariants
                                                  .remove(controller
                                                  .selectedIndexVariants
                                                  .where((element) =>
                                                  element.contains(
                                                      '$index _'))
                                                  .first);
                                              controller.selectedVariants
                                                  .insert(
                                                  index,
                                                  productModel
                                                      .itemAttribute!
                                                      .attributes![
                                                  index]
                                                      .attributeOptions![
                                                  i]
                                                      .toString());
                                              controller
                                                  .selectedIndexVariants
                                                  .add(
                                                  '$index _${productModel.itemAttribute!.attributes![index].attributeOptions![i].toString()}');
                                              controller
                                                  .selectedIndexArray
                                                  .add('${index}_$i');
                                            }

                                            final bool productIsInList =
                                            cartItem.any((product) =>
                                            product.id ==
                                                "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                            if (productIsInList) {
                                              CartProductModel element =
                                              cartItem.firstWhere(
                                                      (product) =>
                                                  product.id ==
                                                      "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                              controller.quantity.value =
                                              element.quantity!;
                                            } else {
                                              controller.quantity.value =
                                              1;
                                            }

                                            controller.update();
                                            controller.calculatePrice(
                                                productModel);
                                          }
                                              : null,
                                          child: Chip(
                                            shape:
                                            const RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors
                                                        .transparent),
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        20))),
                                            label: Row(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Text(
                                                  productModel
                                                      .itemAttribute!
                                                      .attributes![index]
                                                      .attributeOptions![
                                                  i]
                                                      .toString(),
                                                  style: TextStyle(
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    fontFamily:
                                                    AppThemeData
                                                        .medium,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: controller
                                                        .selectedVariants
                                                        .contains(productModel
                                                        .itemAttribute!
                                                        .attributes![
                                                    index]
                                                        .attributeOptions![
                                                    i]
                                                        .toString())
                                                        ? Colors.white
                                                        : themeChange
                                                        .getThem()
                                                        ? AppThemeData
                                                        .grey600
                                                        : AppThemeData
                                                        .grey300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: controller
                                                .selectedVariants
                                                .contains(productModel
                                                .itemAttribute!
                                                .attributes![
                                            index]
                                                .attributeOptions![
                                            i]
                                                .toString())
                                                ? AppThemeData.primary300
                                                : themeChange.getThem()
                                                ? AppThemeData.grey800
                                                : AppThemeData
                                                .grey100,
                                            elevation: 6.0,
                                            padding:
                                            const EdgeInsets.all(8.0),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  productModel.addOnsTitle == null ||
                      productModel.addOnsTitle!.isEmpty
                      ? const SizedBox()
                      : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 5),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text(
                                "Addons".tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.semiBold,
                                  fontWeight: FontWeight.w600,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            ListView.builder(
                                itemCount:
                                productModel.addOnsTitle!.length,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  String title =
                                  productModel.addOnsTitle![index];
                                  String price =
                                  productModel.addOnsPrice![index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              fontFamily:
                                              AppThemeData.medium,
                                              fontWeight: FontWeight.w500,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey100
                                                  : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.amountShow(
                                              amount: Constant
                                                  .productCommissionPrice(
                                                  controller
                                                      .vendorModel
                                                      .value,
                                                  price)),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            fontFamily:
                                            AppThemeData.medium,
                                            fontWeight: FontWeight.w500,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey100
                                                : AppThemeData.grey800,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Obx(
                                              () => SizedBox(
                                            height: 24.0,
                                            width: 24.0,
                                            child: Checkbox(
                                              value: controller
                                                  .selectedAddOns
                                                  .contains(title),
                                              activeColor:
                                              AppThemeData.primary300,
                                              onChanged: isItemAvailable
                                                  ? (value) {
                                                if (value != null) {
                                                  if (value == true) {
                                                    controller
                                                        .selectedAddOns
                                                        .add(title);
                                                  } else {
                                                    controller
                                                        .selectedAddOns
                                                        .remove(title);
                                                  }
                                                  controller.update();
                                                }
                                              }
                                                  : null,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemeData.grey800
                  : AppThemeData.grey100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: Responsive.width(100, context),
                        height: Responsive.height(5.5, context),
                        decoration: ShapeDecoration(
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: isItemAvailable
                                  ? () {
                                if (controller.quantity.value > 1) {
                                  controller.quantity.value -= 1;
                                  controller.update();
                                }
                              }
                                  : null,
                              child: Icon(
                                Icons.remove,
                                color: isItemAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                controller.quantity.value.toString(),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: isItemAvailable
                                  ? () {
                                if (productModel.itemAttribute == null) {
                                  if (controller.quantity.value <
                                      (productModel.quantity ?? 0) ||
                                      (productModel.quantity ?? 0) == -1) {
                                    controller.quantity.value += 1;
                                    controller.update();
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Out of stock".tr);
                                  }
                                } else {
                                  int totalQuantity = int.parse(productModel
                                      .itemAttribute!.variants!
                                      .where((element) =>
                                  element.variantSku ==
                                      controller.selectedVariants
                                          .join('-'))
                                      .first
                                      .variantQuantity
                                      .toString());
                                  if (controller.quantity.value <
                                      totalQuantity ||
                                      totalQuantity == -1) {
                                    controller.quantity.value += 1;
                                    controller.update();
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Out of stock".tr);
                                  }
                                }
                              }
                                  : null,
                              child: Icon(
                                Icons.add,
                                color: isItemAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: isItemAvailable
                          ? RoundedButtonFill(
                        title:
                        "${'Add item'.tr} ${Constant.amountShow(amount: controller.calculatePrice(productModel))}"
                            .tr,
                        height: 5.5,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          if (productModel.itemAttribute == null) {
                            controller.addToCart(
                                productModel: productModel,
                                price: Constant.productCommissionPrice(
                                    controller.vendorModel.value,
                                    productModel.price.toString()),
                                discountPrice: double.parse(
                                    productModel.disPrice.toString()) <=
                                    0
                                    ? "0"
                                    : Constant.productCommissionPrice(
                                    controller.vendorModel.value,
                                    productModel.disPrice.toString()),
                                isIncrement: true,
                                quantity: controller.quantity.value);
                          } else {
                            String variantPrice = "0";
                            if (productModel.itemAttribute!.variants!
                                .where((element) =>
                            element.variantSku ==
                                controller.selectedVariants.join('-'))
                                .isNotEmpty) {
                              variantPrice = Constant.productCommissionPrice(
                                  controller.vendorModel.value,
                                  productModel.itemAttribute!.variants!
                                      .where((element) =>
                                  element.variantSku ==
                                      controller.selectedVariants
                                          .join('-'))
                                      .first
                                      .variantPrice ??
                                      '0');
                            }
                            Map<String, String> mapData = {};
                            for (var element
                            in productModel.itemAttribute!.attributes!) {
                              mapData.addEntries([
                                MapEntry(
                                    controller.attributesList
                                        .where((element1) =>
                                    element.attributeId == element1.id)
                                        .first
                                        .title
                                        .toString(),
                                    controller.selectedVariants[productModel
                                        .itemAttribute!.attributes!
                                        .indexOf(element)])
                              ]);
                            }

                            VariantInfo variantInfo = VariantInfo(
                                variantPrice: productModel
                                    .itemAttribute!.variants!
                                    .where((element) =>
                                element.variantSku ==
                                    controller.selectedVariants
                                        .join('-'))
                                    .first
                                    .variantPrice ??
                                    '0',
                                variantSku:
                                controller.selectedVariants.join('-'),
                                variantOptions: mapData,
                                variantImage: productModel
                                    .itemAttribute!.variants!
                                    .where((element) =>
                                element.variantSku ==
                                    controller.selectedVariants
                                        .join('-'))
                                    .first
                                    .variantImage ??
                                    '',
                                variantId: productModel.itemAttribute!.variants!
                                    .where((element) => element.variantSku == controller.selectedVariants.join('-'))
                                    .first
                                    .variantId ??
                                    '0');

                            controller.addToCart(
                                productModel: productModel,
                                price: variantPrice,
                                discountPrice: "0",
                                isIncrement: true,
                                variantInfo: variantInfo,
                                quantity: controller.quantity.value);
                          }

                          Get.back();
                        },
                      )
                          : const SizedBox(), // Removed the grey button completely
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}