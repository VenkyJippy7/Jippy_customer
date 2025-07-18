import 'dart:convert';

class CartProductModel {
  String? id;
  String? categoryId;
  String? name;
  String? photo;
  String? price;
  String? discountPrice;
  String? vendorID;
  String? vendorName;
  int? quantity;
  String? extrasPrice;
  List<dynamic>? extras;
  VariantInfo? variantInfo;

  CartProductModel({
    this.id,
    this.categoryId,
    this.name,
    this.photo,
    this.price,
    this.discountPrice,
    this.vendorID,
    this.vendorName,
    this.quantity,
    this.extrasPrice,
    this.variantInfo,
    this.extras,
  });

  CartProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    name = json['name'];
    photo = json['photo'];
    price = json['price'] ?? "0.0";
    discountPrice = json['discountPrice'] ?? "0.0";
    vendorID = json['vendorID'];
    vendorName = json['vendorName'];
    quantity = json['quantity'];
    extrasPrice = json['extras_price'];

    extras = json['extras'] == "null" || json['extras'] == null
        ? null
        : "String" == json['extras'].runtimeType.toString()
            ? List<dynamic>.from(jsonDecode(json['extras']))
            : List<dynamic>.from(json['extras']);

    variantInfo = json['variant_info'] == "null" || json['variant_info'] == null
        ? null
        : "String" == json['variant_info'].runtimeType.toString()
            ? VariantInfo.fromJson(jsonDecode(json['variant_info']))
            : VariantInfo.fromJson(json['variant_info']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['name'] = name;
    data['photo'] = photo;
    data['price'] = price;
    data['discountPrice'] = discountPrice;
    data['vendorID'] = vendorID;
    data['vendorName'] = vendorName;
    data['quantity'] = quantity;
    data['extras_price'] = extrasPrice;
    data['extras'] = extras;
    if (variantInfo != null) {
      data['variant_info'] = variantInfo?.toJson(); // Handle null value
    }
    return data;
  }
}

class VariantInfo {
  String? variantId;
  String? variantPrice;
  String? variantSku;
  String? variantImage;
  Map<String, dynamic>? variantOptions;

  VariantInfo({this.variantId, this.variantPrice, this.variantSku, this.variantImage, this.variantOptions});

  VariantInfo.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'] ?? '';
    variantPrice = json['variant_price'] ?? '';
    variantSku = json['variant_sku'] ?? '';
    variantImage = json['variant_image'] ?? '';
    variantOptions = json['variant_options'] ?? {};
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_price'] = variantPrice;
    data['variant_sku'] = variantSku;
    data['variant_image'] = variantImage;
    data['variant_options'] = variantOptions;
    return data;
  }
}
