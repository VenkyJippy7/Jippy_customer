import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/cart_screen/cart_screen.dart';
import '../app/restaurant_details_screen/restaurant_details_screen.dart';
import '../constant/constant.dart';
import '../utils/fire_store_utils.dart';
import '../constant/show_toast_dialog.dart';

class MiniCartBar extends StatelessWidget {
  const MiniCartBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int itemCount = cartItem.length;
      if (itemCount == 0) return const SizedBox.shrink();
      final String vendorName = cartItem.first.vendorName ?? 'Restaurant';
      final vendorId = cartItem.first.vendorID;
      final String productImage = cartItem.first.photo ?? '';

      return SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product image (left, small, rounded)
              if (productImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    productImage,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey, size: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 24),
                ),
              const SizedBox(width: 12),
              // Restaurant name (clickable)
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (vendorId != null) {
                      ShowToastDialog.showLoader("Loading restaurant...");
                      final vendorModel = await FireStoreUtils.getVendorById(vendorId.toString());
                      ShowToastDialog.closeLoader();
                      if (vendorModel != null) {
                        Get.to(const RestaurantDetailsScreen(), arguments: {'vendorModel': vendorModel});
                      } else {
                        ShowToastDialog.showToast("Restaurant not found");
                      }
                    }
                  },
                  child: Text(
                    vendorName,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // View Cart button with item count below
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      Get.to(const CartScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    child: Text('View Cart • $itemCount item${itemCount > 1 ? 's' : ''}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
} 