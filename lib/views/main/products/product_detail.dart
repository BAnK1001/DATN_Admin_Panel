import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/models/vendor.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late DocumentSnapshot productSnapshot;
  late Vendor vendor;
  bool isLoadingProduct = true;
  bool isLoadingVendor = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      fetchVendorDetails(productSnapshot['vendorId']);
      setState(() {
        isLoadingProduct = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProduct = false;
      });
    }
  }

  Future<void> fetchVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      setState(() {
        vendor = Vendor(
          storeId: data['storeId'],
          storeName: data['storeName'],
          email: data['email'],
          phone: data['phone'],
          taxNumber: data['taxNumber'],
          storeNumber: data['storeNumber'],
          country: data['country'],
          state: data['state'],
          city: data['city'],
          storeImgUrl: data['storeImgUrl'],
          address: data['address'],
          authType: data['authType'],
        );

        isLoadingVendor = false;
      });
    } catch (e) {
      setState(() {
        isLoadingVendor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Detail',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoadingProduct
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          productSnapshot['imgUrls'][0],
                          fit: BoxFit.contain, // Adjusted to fit the image size
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      productSnapshot['productName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${productSnapshot['price']}',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Quantity: ${productSnapshot['quantity']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      productSnapshot['description'],
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text(
                      'Vendor Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    isLoadingVendor
                        ? Center(child: CircularProgressIndicator())
                        : Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${vendor.storeName}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Email: ${vendor.email}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Phone: ${vendor.phone}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Address: ${vendor.address}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'City: ${vendor.city}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'State: ${vendor.state}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Country: ${vendor.country}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  SizedBox(height: 16),
                                  vendor.storeImgUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            vendor.storeImgUrl!,
                                            fit: BoxFit
                                                .contain, // Adjusted to fit the image size
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your edit product action here
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
