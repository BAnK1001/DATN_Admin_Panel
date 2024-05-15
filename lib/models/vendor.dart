class Vendor {
  final String storeId;
  final String storeName;
  final String email;
  final String phone;
  final String taxNumber;
  final String storeNumber;
  final String country;
  final String state;
  final String city;
  final String? storeImgUrl;
  final String address;
  final String authType;

  Vendor({
    required this.storeId,
    required this.storeName,
    required this.email,
    required this.phone,
    required this.taxNumber,
    required this.storeNumber,
    required this.country,
    required this.state,
    required this.city,
    this.storeImgUrl,
    required this.address,
    required this.authType,
  });
}
