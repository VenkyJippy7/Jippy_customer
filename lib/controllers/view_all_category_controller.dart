import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ViewAllCategoryController extends GetxController {
  RxBool isLoading = true.obs;

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getCategoryData();
    super.onInit();
  }

  getCategoryData() async {
    await FireStoreUtils.getVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
      },
    );

    // Comment out category filtering logic
    // if (Constant.restaurantList != null) {
    //   List<String> usedCategoryIds = Constant.restaurantList!.expand((vendor) => vendor.categoryID ?? []).whereType<String>().toSet().toList();
    //   vendorCategoryModel.value = vendorCategoryModel.where((category) => usedCategoryIds.contains(category.id)).toList();
    // }

    isLoading.value = false;
  }
}
