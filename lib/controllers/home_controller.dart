import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

class HomeController extends GetxController {
  DashBoardController dashBoardController = Get.find<DashBoardController>();
  final CartProvider cartProvider = CartProvider();
  final ScrollController scrollController = ScrollController();
  RxBool isNavBarVisible = true.obs;

  getCartData() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    update();
  }

  RxBool isLoading = true.obs;
  RxBool isListView = true.obs;
  RxBool isPopular = true.obs;
  RxString selectedOrderTypeValue = "Delivery".tr.obs;

  Rx<PageController> pageController = PageController(viewportFraction: 1.0).obs;
  Rx<PageController> pageBottomController = PageController(viewportFraction: 1.0).obs;
  RxInt currentPage = 0.obs;
  RxInt currentBottomPage = 0.obs;

  Timer? _bannerTimer;

  var selectedIndex = 0.obs;

  @override
  void onInit() {
    getVendorCategory();
    getData();
    // startBannerTimer(); // Move to onReady
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection.toString() == 'ScrollDirection.reverse') {
        if (isNavBarVisible.value) isNavBarVisible.value = false;
      } else if (scrollController.position.userScrollDirection.toString() == 'ScrollDirection.forward') {
        if (!isNavBarVisible.value) isNavBarVisible.value = true;
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    startBannerTimer();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    pageController.value.dispose();
    pageBottomController.value.dispose();
    super.onClose();
  }

  void startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (bannerModel.isNotEmpty) {
        if (currentPage.value < bannerModel.length - 1) {
          currentPage.value++;
        } else {
          currentPage.value = 0;
        }
        // Only animate if attached
        if (pageController.value.hasClients) {
        pageController.value.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        }
      }
    });
  }

  void stopBannerTimer() {
    _bannerTimer?.cancel();
  }

  late TabController tabController;

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  RxList<AdvertisementModel> advertisementList = <AdvertisementModel>[].obs;
  RxList<VendorModel> popularRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> couponRestaurantList = <VendorModel>[].obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;

  RxList<StoryModel> storyList = <StoryModel>[].obs;
  RxList<BannerModel> bannerModel = <BannerModel>[].obs;
  RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  getData() async {
    isLoading.value = true;
    getCartData();
    // selectedOrderTypeValue.value = Preferences.getString(Preferences.foodDeliveryType, defaultValue: "Delivery".tr).tr;
    await getZone();
    FireStoreUtils.getAllNearestRestaurant().listen((event) async {
      popularRestaurantList.clear();
      newArrivalRestaurantList.clear();
      allNearestRestaurant.clear();
      advertisementList.clear();

      allNearestRestaurant.addAll(event);
      newArrivalRestaurantList.addAll(event);
      popularRestaurantList.addAll(event);
      Constant.restaurantList = allNearestRestaurant;
      
      // Set distance for each vendor
      for (var vendor in allNearestRestaurant) {
        if (vendor.latitude != null && vendor.longitude != null) {
          vendor.distance = Constant.calculateDistance(
            Constant.selectedLocation.location!.latitude!,
            Constant.selectedLocation.location!.longitude!,
            vendor.latitude!,
            vendor.longitude!,
          );
        } else {
          vendor.distance = null;
        }
      }

      // Sort by distance, then by rating
      allNearestRestaurant.sort((a, b) {
        double distanceA = Constant.calculateDistance(
          Constant.selectedLocation.location!.latitude!,
          Constant.selectedLocation.location!.longitude!,
          a.latitude!,
          a.longitude!,
        );
        double distanceB = Constant.calculateDistance(
          Constant.selectedLocation.location!.latitude!,
          Constant.selectedLocation.location!.longitude!,
          b.latitude!,
          b.longitude!,
        );
        int distanceCompare = distanceA.compareTo(distanceB);
        if (distanceCompare != 0) return distanceCompare;
        // If distance is the same, compare by rating (higher first)
        double ratingA = double.tryParse(a.reviewsSum?.toString() ?? '0') ?? 0;
        double ratingB = double.tryParse(b.reviewsSum?.toString() ?? '0') ?? 0;
        return ratingB.compareTo(ratingA);
      });

      // Comment out category filtering logic
      // List<String> usedCategoryIds = allNearestRestaurant
      //     .expand((vendor) => vendor.categoryID ?? [])
      //     .whereType<String>()
      //     .toSet()
      //     .toList();
      // vendorCategoryModel.value = vendorCategoryModel
      //     .where((category) => usedCategoryIds.contains(category.id))
      //     .toList();

      popularRestaurantList.sort(
        (a, b) => Constant.calculateReview(
                reviewCount: b.reviewsCount.toString(),
                reviewSum: b.reviewsSum.toString())
            .compareTo(Constant.calculateReview(
                reviewCount: a.reviewsCount.toString(),
                reviewSum: a.reviewsSum.toString())),
      );

      newArrivalRestaurantList.sort(
        (a, b) => (b.createdAt ?? Timestamp.now())
            .toDate()
            .compareTo((a.createdAt ?? Timestamp.now()).toDate()),
      );

      await FireStoreUtils.getHomeCoupon().then(
        (value) {
          couponRestaurantList.clear();
          couponList.clear();
          for (var element1 in value) {
            for (var element in allNearestRestaurant) {
              if (element1.resturantId == element.id &&
                  element1.expiresAt!.toDate().isAfter(DateTime.now())) {
                couponList.add(element1);
                couponRestaurantList.add(element);
              }
            }
          }
        },
      );

      await FireStoreUtils.getStory().then((value) {
        storyList.clear();
        for (var element1 in value) {
          for (var element in allNearestRestaurant) {
            if (element1.vendorID == element.id) {
              storyList.add(element1);
            }
          }
        }
      });

      if (Constant.isEnableAdsFeature == true) {
        await FireStoreUtils.getAllAdvertisement().then((value) {
          advertisementList.clear();
          for (var element1 in value) {
            for (var element in allNearestRestaurant) {
              if (element1.vendorId == element.id) {
                advertisementList.add(element1);
              }
            }
          }
        });
      }
    });
    setLoading();
  }

  setLoading() async {
    await Future.delayed(Duration(seconds: 1), () async {
      if (allNearestRestaurant.isEmpty) {
        await Future.delayed(Duration(seconds: 2), () {
          isLoading.value = false;
        });
      } else {
        isLoading.value = false;
      }
      update();
    });
  }

  getVendorCategory() async {
    await FireStoreUtils.getHomeVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
      },
    );

    await FireStoreUtils.getHomeTopBanner().then(
      (value) {
        bannerModel.value = value;
      },
    );

    await FireStoreUtils.getHomeBottomBanner().then(
      (value) {
        bannerBottomModel.value = value;
      },
    );

    await getFavouriteRestaurant();
  }

  getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }

  getZone() async {
    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          if (Constant.isPointInPolygon(
              LatLng(Constant.selectedLocation.location?.latitude ?? 0.0,
                  Constant.selectedLocation.location?.longitude ?? 0.0),
              value[i].area!)) {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = true;
            break;
          } else {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = false;
          }
        }
      }
    });
  }
}
