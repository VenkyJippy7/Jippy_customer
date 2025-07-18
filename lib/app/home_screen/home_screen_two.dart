import 'dart:math';

import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/advertisement_screens/all_advertisement_screen.dart';
import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/app/home_screen/home_screen.dart';
import 'package:customer/app/home_screen/restaurant_list_screen.dart';
import 'package:customer/app/home_screen/story_view.dart';
import 'package:customer/app/home_screen/view_all_category_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/app/scan_qrcode_screen/scan_qr_code_screen.dart';
import 'package:customer/app/search_screen/search_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/custom_dialog_box.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/gradiant_text.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:customer/widget/animated_search_hint.dart';
import 'package:customer/widget/mini_cart_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'discount_restaurant_list_screen.dart';
import 'package:customer/widget/initials_avatar.dart';
import 'package:customer/app/profile_screen/profile_screen.dart';
import 'package:customer/widget/filter_bar.dart';

class HomeScreenTwo extends StatelessWidget {
  const HomeScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surfaceDark
              : AppThemeData.surface,
          floatingActionButton: const MiniCartBar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: controller.isLoading.value
              ? Constant.loader()
              : Constant.isZoneAvailable == false
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/location.gif",
                            height: 120,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "No Restaurants Found in Your Area".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                                fontSize: 22,
                                fontFamily: AppThemeData.semiBold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Currently, there are no available restaurants in your zone. Try changing your location to find nearby options."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey500,
                                fontSize: 16,
                                fontFamily: AppThemeData.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RoundedButtonFill(
                            title: "Change Zone".tr,
                            width: 55,
                            height: 5.5,
                            color: AppThemeData.primary300,
                            textColor: AppThemeData.grey50,
                            onPress: () async {
                              Get.offAll(const LocationPermissionScreen());
                            },
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).viewPadding.top),
                      child: controller.isListView.value == false
                          ? const MapView()
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Get.to(const ProfileScreen());
                                            },
                                            child: buildProfileAvatar(),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Constant.userModel == null
                                                    ? InkWell(
                                                        onTap: () {
                                                          Get.offAll(
                                                              const LoginScreen());
                                                        },
                                                        child: Text(
                                                          "Login".tr,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .medium,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                    : Text(
                                                        "${Constant.userModel!.fullName()}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .medium,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey50
                                                              : AppThemeData
                                                                  .grey900,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                InkWell(
                                                  onTap: () async {
                                                    if (Constant.userModel !=
                                                        null) {
                                                      Get.to(const AddressListScreen())!
                                                          .then(
                                                        (value) {
                                                          if (value != null) {
                                                            ShippingAddress
                                                                addressModel =
                                                                value;
                                                            Constant.selectedLocation =
                                                                addressModel;
                                                            controller
                                                                .getData();
                                                          }
                                                        },
                                                      );
                                                    } else {
                                                      Constant.checkPermission(
                                                          onTap: () async {
                                                            ShowToastDialog
                                                                .showLoader(
                                                                    "Please wait"
                                                                        .tr);
                                                            ShippingAddress
                                                                addressModel =
                                                                ShippingAddress();
                                                            try {
                                                              await Geolocator
                                                                  .requestPermission();
                                                              await Geolocator
                                                                  .getCurrentPosition();
                                                              ShowToastDialog
                                                                  .closeLoader();
                                                              if (Constant
                                                                      .selectedMapType ==
                                                                  'osm') {
                                                                final result =
                                                                    await Get.to(
                                                                        () =>
                                                                            MapPickerPage());
                                                                if (result !=
                                                                    null) {
                                                                  final firstPlace =
                                                                      result;
                                                                  final lat = firstPlace
                                                                      .coordinates
                                                                      .latitude;
                                                                  final lng = firstPlace
                                                                      .coordinates
                                                                      .longitude;
                                                                  final address =
                                                                      firstPlace
                                                                          .address;

                                                                  addressModel
                                                                          .addressAs =
                                                                      "Home";
                                                                  addressModel
                                                                          .locality =
                                                                      address
                                                                          .toString();
                                                                  addressModel
                                                                          .location =
                                                                      UserLocation(
                                                                          latitude:
                                                                              lat,
                                                                          longitude:
                                                                              lng);
                                                                  Constant.selectedLocation =
                                                                      addressModel;
                                                                  controller
                                                                      .getData();
                                                                  Get.back();
                                                                }
                                                              } else {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            PlacePicker(
                                                                      apiKey: Constant
                                                                          .mapAPIKey,
                                                                      onPlacePicked:
                                                                          (result) async {
                                                                        ShippingAddress
                                                                            addressModel =
                                                                            ShippingAddress();
                                                                        addressModel.addressAs =
                                                                            "Home";
                                                                        addressModel.locality = result
                                                                            .formattedAddress!
                                                                            .toString();
                                                                        addressModel.location = UserLocation(
                                                                            latitude:
                                                                                result.geometry!.location.lat,
                                                                            longitude: result.geometry!.location.lng);
                                                                        Constant.selectedLocation =
                                                                            addressModel;
                                                                        controller
                                                                            .getData();
                                                                        Get.back();
                                                                      },
                                                                      initialPosition: const LatLng(
                                                                          -33.8567844,
                                                                          151.213108),
                                                                      useCurrentLocation:
                                                                          true,
                                                                      selectInitialPosition:
                                                                          true,
                                                                      usePinPointingSearch:
                                                                          true,
                                                                      usePlaceDetailSearch:
                                                                          true,
                                                                      zoomGesturesEnabled:
                                                                          true,
                                                                      zoomControlsEnabled:
                                                                          true,
                                                                      resizeToAvoidBottomInset:
                                                                          false, // only works in page mode, less flickery, remove if wrong offsets
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            } catch (e) {
                                                              await placemarkFromCoordinates(
                                                                      19.228825,
                                                                      72.854118)
                                                                  .then(
                                                                      (valuePlaceMaker) {
                                                                Placemark
                                                                    placeMark =
                                                                    valuePlaceMaker[
                                                                        0];
                                                                addressModel
                                                                        .addressAs =
                                                                    "Home";
                                                                addressModel
                                                                        .location =
                                                                    UserLocation(
                                                                        latitude:
                                                                            19.228825,
                                                                        longitude:
                                                                            72.854118);
                                                                String
                                                                    currentLocation =
                                                                    "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                                                addressModel
                                                                        .locality =
                                                                    currentLocation;
                                                              });

                                                              Constant.selectedLocation =
                                                                  addressModel;
                                                              ShowToastDialog
                                                                  .closeLoader();
                                                              controller
                                                                  .getData();
                                                            }
                                                          },
                                                          context: context);
                                                    }
                                                  },
                                                  child: Text.rich(
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: Constant
                                                              .selectedLocation
                                                              .getFullAddress(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .medium,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        WidgetSpan(
                                                          child: SvgPicture.asset(
                                                              "assets/icons/ic_down.svg"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          // InkWell(
                                          //   onTap: () async {
                                          //     (await Get.to(
                                          //         const CartScreen()));
                                          //     controller.getCartData();
                                          //   },
                                          //   child: ClipOval(
                                          //     child: Container(
                                          //         padding:
                                          //             const EdgeInsets.all(8.0),
                                          //         color: themeChange.getThem()
                                          //             ? AppThemeData.grey900
                                          //             : AppThemeData.grey50,
                                          //         child: SvgPicture.asset(
                                          //           "assets/icons/ic_shoping_cart.svg",
                                          //           colorFilter:
                                          //               ColorFilter.mode(
                                          //                   themeChange
                                          //                           .getThem()
                                          //                       ? AppThemeData
                                          //                           .grey50
                                          //                       : AppThemeData
                                          //                           .grey900,
                                          //                   BlendMode.srcIn),
                                          //         )),
                                          //   ),
                                          // )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(const SearchScreen(), arguments: {
                                            "vendorList": controller.allNearestRestaurant
                                          });
                                        },
                                        child: AnimatedSearchHint(
                                          controller: null,
                                          enable: false,
                                          fillColor: Colors.white,
                                          fontFamily: 'Outfit-Bold',
                                          textStyle: TextStyle(
                                            fontFamily: 'Outfit-Bold',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          hintTextStyle: TextStyle(
                                            fontFamily: 'Outfit-Bold',
                                            fontWeight: FontWeight.w200,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          suffix: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: SvgPicture.asset(
                                              "assets/icons/ic_search.svg",
                                              color: Color(0xFFff5201),
                                            ),
                                          ),
                                          hints: [
                                            "Search 'cake'".tr,
                                            "Search 'biryani'".tr,
                                            "Search 'ice cream'".tr,
                                            "Search 'pizza'".tr,
                                            "Search 'burger'".tr,
                                            "Search 'sushi'".tr,
                                            "Search 'Restaurants or dish'".tr,
                                          ],
                                          interval: const Duration(seconds: 2),
                                        ),
                                      ),

                                      //Old search bar
                                      // InkWell(
                                      //   onTap: () {
                                      //     Get.to(const SearchScreen(),
                                      //         arguments: {
                                      //           "vendorList": controller
                                      //               .allNearestRestaurant
                                      //         });
                                      //   },
                                      //   child: TextFieldWidget(
                                      //     hintText:
                                      //         'Search the dish, restaurant, food, meals'
                                      //             .tr,
                                      //     controller: null,
                                      //     enable: false,
                                      //     prefix: Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //           horizontal: 16),
                                      //       child: SvgPicture.asset(
                                      //           "assets/icons/ic_search.svg"),
                                      //     ),
                                      //   ),
                                      //  ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        controller.bannerModel.isEmpty
                                            ? const SizedBox()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: BannerView(
                                                    controller: controller),
                                              ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: CategoryView(
                                              controller: controller),
                                        ),
                                        controller.couponRestaurantList.isEmpty
                                            ? const SizedBox()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    OfferView(
                                                        controller: controller),
                                                  ],
                                                ),
                                              ),
                                        controller.storyList.isEmpty ||
                                                Constant.storyEnable == false
                                            ? const SizedBox()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    StoryView(
                                                        controller: controller),
                                                  ],
                                                ),
                                              ),
                                        Visibility(
                                          visible:
                                              Constant.isEnableAdsFeature ==
                                                  true,
                                          child: controller
                                                  .advertisementList.isEmpty
                                              ? const SizedBox()
                                              : Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: AppThemeData
                                                            .primary300
                                                            .withAlpha(40),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  "Highlights for you"
                                                                      .tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontSize:
                                                                        16,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey900,
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Get.to(AllAdvertisementScreen())
                                                                      ?.then(
                                                                          (value) {
                                                                    controller
                                                                        .getFavouriteRestaurant();
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "See all".tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .regular,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .primary300
                                                                        : AppThemeData
                                                                            .primary300,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          SizedBox(
                                                            height: 220,
                                                            child: ListView
                                                                .builder(
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount: controller
                                                                          .advertisementList
                                                                          .length >=
                                                                      10
                                                                  ? 10
                                                                  : controller
                                                                      .advertisementList
                                                                      .length,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return AdvertisementHomeCard(
                                                                    controller:
                                                                        controller,
                                                                    model: controller
                                                                            .advertisementList[
                                                                        index]);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                        BestRestaurantsSection(restaurantList: controller.allNearestRestaurant),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
        );
      },
    );
  }

  Widget buildProfileAvatar() {
    final user = Constant.userModel;
    final hasProfileImage = user != null &&
        user.profilePictureURL != null &&
        user.profilePictureURL!.isNotEmpty &&
        user.profilePictureURL!.toLowerCase() != "null";

    if (hasProfileImage) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppThemeData.primary300,
        backgroundImage: NetworkImage(user!.profilePictureURL!),
      );
    } else {
      return InitialsAvatar(
        firstName: user?.firstName,
        lastName: user?.lastName,
        radius: 20,
        backgroundColor: AppThemeData.primary300,
        textColor: Colors.white,
      );
    }
  }
}

class CategoryView extends StatelessWidget {
  final HomeController controller;

  const CategoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Our Categories".tr,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(const ViewAllCategoryScreen());
                      },
                      child: Text(
                        "See all".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppThemeData.medium,
                          color: themeChange.getThem()
                              ? AppThemeData.primary300
                              : AppThemeData.primary300,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Best Serving Food".tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Inter Tight',
                    fontWeight: FontWeight.w800,
                  ),
                )

                // GradientText(
                //   'Best Servings Food'.tr,
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontFamily: 'Inter Tight',
                //     fontWeight: FontWeight.w800,
                //   ),
                //   gradient: LinearGradient(colors: [
                //     Color(0xFF3961F1),
                //     Color(0xFF11D0EA),
                //   ]),
                // ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 0.8),
            itemCount: controller.vendorCategoryModel.length >= 8
                ? 8
                : controller.vendorCategoryModel.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              VendorCategoryModel vendorCategoryModel =
                  controller.vendorCategoryModel[index];
              return InkWell(
                onTap: () {
                  Get.to(const CategoryRestaurantScreen(), arguments: {
                    "vendorCategoryModel": vendorCategoryModel,
                    "dineIn": false
                  });
                },
                child: Column(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: NetworkImageWidget(
                            imageUrl: vendorCategoryModel.photo.toString(),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Text(
                      "${vendorCategoryModel.title}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OfferView extends StatelessWidget {
  final HomeController controller;

  const OfferView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      decoration: ShapeDecoration(
        color:
            themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Large Discounts".tr,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(const DiscountRestaurantListScreen(),
                              arguments: {
                                "vendorList": controller.couponRestaurantList,
                                "couponList": controller.couponList,
                                "title": "Discounts Restaurants"
                              });
                        },
                        child: Text(
                          "See all".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem()
                                ? AppThemeData.primary300
                                : AppThemeData.primary300,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),


                  Text(
                    "Save Upto 50% Off".tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Inter Tight',
                      fontWeight: FontWeight.w800,
                    ),
                  )


                  // GradientText(
                  //   'Save Upto 50% Off'.tr,
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontFamily: 'Inter Tight',
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  //   gradient: LinearGradient(colors: [
                  //     Color(0xFF39F1C5),
                  //     Color(0xFF97EA11),
                  //   ]),
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.32,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.couponRestaurantList.length >= 15
                        ? 15
                        : controller.couponRestaurantList.length,
                    itemBuilder: (context, index) {
                      VendorModel vendorModel =
                          controller.couponRestaurantList[index];
                      CouponModel offerModel = controller.couponList[index];
                      return InkWell(
                        onTap: () {
                          Get.to(const RestaurantDetailsScreen(),
                              arguments: {"vendorModel": vendorModel});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: Responsive.width(34, context),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Stack(
                                children: [
                                  NetworkImageWidget(
                                    imageUrl: vendorModel.photo.toString(),
                                    fit: BoxFit.cover,
                                    height: Responsive.height(100, context),
                                    width: Responsive.width(100, context),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: const Alignment(-0.00, -1.00),
                                        end: const Alignment(0, 1),
                                        colors: [
                                          Colors.black.withOpacity(0),
                                          AppThemeData.grey900
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            vendorModel.title.toString(),
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 18,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.semiBold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey50,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          RoundedButtonFill(
                                            title:
                                                "${offerModel.discountType == "Fix Price" ? "${Constant.currencyModel!.symbol}" : ""}${offerModel.discount}${offerModel.discountType == "Percentage" ? "% off".tr : "off".tr}",
                                            color: Colors.primaries[Random()
                                                .nextInt(
                                                    Colors.primaries.length)],
                                            textColor: AppThemeData.grey50,
                                            width: 20,
                                            height: 3.5,
                                            onPress: () async {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  final HomeController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: GestureDetector(
        onPanStart: (_) => controller.stopBannerTimer(),
        onPanEnd: (_) => controller.startBannerTimer(),
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: controller.pageController.value,
          scrollDirection: Axis.horizontal,
          itemCount: controller.bannerModel.length,
          padEnds: false,
          pageSnapping: true,
          onPageChanged: (value) {
            controller.currentPage.value = value;
          },
          itemBuilder: (BuildContext context, int index) {
            BannerModel bannerModel = controller.bannerModel[index];
            return InkWell(
              onTap: () async {
                controller.stopBannerTimer();
                if (bannerModel.redirect_type == "store") {
                  ShowToastDialog.showLoader("Please wait".tr);
                  VendorModel? vendorModel = await FireStoreUtils.getVendorById(
                      bannerModel.redirect_id.toString());

                  if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                    ShowToastDialog.closeLoader();
                    Get.to(const RestaurantDetailsScreen(),
                        arguments: {"vendorModel": vendorModel});
                  } else {
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast(
                        "Sorry, The Zone is not available in your area. change the other location first."
                            .tr);
                  }
                } else if (bannerModel.redirect_type == "product") {
                  ShowToastDialog.showLoader("Please wait".tr);
                  ProductModel? productModel =
                      await FireStoreUtils.getProductById(
                          bannerModel.redirect_id.toString());
                  VendorModel? vendorModel = await FireStoreUtils.getVendorById(
                      productModel!.vendorID.toString());

                  if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                    ShowToastDialog.closeLoader();
                    Get.to(const RestaurantDetailsScreen(),
                        arguments: {"vendorModel": vendorModel});
                  } else {
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast(
                        "Sorry, The Zone is not available in your area. change the other location first."
                            .tr);
                  }
                } else if (bannerModel.redirect_type == "external_link") {
                  final uri = Uri.parse(bannerModel.redirect_id.toString());
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ShowToastDialog.showToast("Could not launch".tr);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: NetworkImageWidget(
                    imageUrl: bannerModel.photo.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StoryView extends StatelessWidget {
  final HomeController controller;

  const StoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      height: Responsive.height(32, context),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
              image: AssetImage("assets/images/story_bg.png"),
              fit: BoxFit.cover)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Stories".tr,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey50,
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
                GradientText(
                  'Best Food Stories Ever'.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Inter Tight',
                    fontWeight: FontWeight.w800,
                  ),
                  gradient: LinearGradient(colors: [
                    Color(0xFFF1C839),
                    Color(0xFFEA1111),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.storyList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  StoryModel storyModel = controller.storyList[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MoreStories(
                                  storyList: controller.storyList,
                                  index: index,
                                )));
                      },
                      child: SizedBox(
                        width: 134,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Stack(
                            children: [
                              NetworkImageWidget(
                                imageUrl: storyModel.videoThumbnail.toString(),
                                fit: BoxFit.cover,
                                height: Responsive.height(100, context),
                                width: Responsive.width(100, context),
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.30),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 8),
                                child: FutureBuilder(
                                    future: FireStoreUtils.getVendorById(
                                        storyModel.vendorID.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Constant.loader();
                                      } else {
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (snapshot.data == null) {
                                          return const SizedBox();
                                        } else {
                                          VendorModel vendorModel =
                                              snapshot.data!;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipOval(
                                                child: NetworkImageWidget(
                                                  imageUrl: vendorModel.photo
                                                      .toString(),
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      vendorModel.title
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                            "assets/icons/ic_star.svg"),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum!.toStringAsFixed(0))} ${'reviews'.tr}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            color: AppThemeData
                                                                .warning300,
                                                            fontSize: 10,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class BestRestaurantsSection extends StatefulWidget {
  final List<VendorModel> restaurantList;
  const BestRestaurantsSection({Key? key, required this.restaurantList}) : super(key: key);

  @override
  State<BestRestaurantsSection> createState() => _BestRestaurantsSectionState();
}

class _BestRestaurantsSectionState extends State<BestRestaurantsSection> {
  Set<FilterType> selectedFilters = {};
  late List<VendorModel> filteredList;

  double _parseRestaurantCost(String? cost) {
    if (cost == null || cost.isEmpty) return double.infinity;
    final parsed = double.tryParse(cost);
    return parsed ?? double.infinity;
  }

  @override
  void initState() {
    super.initState();
    filteredList = List.from(widget.restaurantList);
  }

  void onFilterToggled(FilterType filter) {
    setState(() {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.add(filter);
      }

      // Start with the full list
      filteredList = List.from(widget.restaurantList);

      // Apply each selected filter in order
      for (var selected in selectedFilters) {
        switch (selected) {
          case FilterType.distance:
            filteredList.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
            break;
          case FilterType.priceLowToHigh:
            filteredList.sort((a, b) => _parseRestaurantCost(a.restaurantCost).compareTo(_parseRestaurantCost(b.restaurantCost)));
            break;
          case FilterType.priceHighToLow:
            filteredList.sort((a, b) => _parseRestaurantCost(b.restaurantCost).compareTo(_parseRestaurantCost(a.restaurantCost)));
            break;
          case FilterType.rating:
            filteredList.sort((a, b) => (b.reviewsSum ?? 0).compareTo(a.reviewsSum ?? 0));
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Best Restaurants".tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                    fontSize: 18,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(const RestaurantListScreen(), arguments: {
                    "vendorList": widget.restaurantList,
                    "title": "Best Restaurants"
                  });
                },
                child: Text(
                  "See all".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppThemeData.medium,
                    color: themeChange.getThem()
                        ? AppThemeData.primary300
                        : AppThemeData.primary300,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: FilterBar(
            selectedFilters: selectedFilters,
            onFilterToggled: onFilterToggled,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: filteredList.length,
            itemBuilder: (BuildContext context, int index) {
              VendorModel vendorModel = filteredList[index];
              return InkWell(
                onTap: () {
                  Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWidget(
                            imageUrl: vendorModel.photo?.toString() ?? '',
                            height: 106,
                            width: 106,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorModel.title ?? '',
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                              Text(
                                vendorModel.location ?? '',
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey400,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Visibility(
                                    visible: (vendorModel.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_free_delivery.svg",
                                          width: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Free Delivery".tr,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.medium,
                                            fontWeight: FontWeight.w500,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_star.svg",
                                          width: 18,
                                          colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                                        ),
                                      ),
                                      Text(
                                        "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount?.toStringAsFixed(0) ?? '0'})",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          fontWeight: FontWeight.w500,
                                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Icon(
                                          Icons.circle,
                                          size: 5,
                                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                        ),
                                      ),
                                      Text(
                                        "${(vendorModel.distance ?? 0).toStringAsFixed(2)} km",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          fontWeight: FontWeight.w500,
                                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
