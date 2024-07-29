import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/models/vendor.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
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
      await fetchVendorDetails(productSnapshot['vendorId']);
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
      setState(() {
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
        title: const Text('Product Details'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // Add your edit product action here
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Product',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoadingProduct
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildProductDetails(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildVendorInfo(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImages(),
        const SizedBox(height: 24),
        _buildProductInfo(),
        const SizedBox(height: 12),
        _buildProductDescription(),
      ],
    );
  }

  Widget _buildProductImages() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (productSnapshot['imgUrls'] as List).length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productSnapshot['imgUrls'][index],
                fit: BoxFit.cover,
                width: 200,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productSnapshot['productName'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: \$${productSnapshot['price']}',
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
                Text(
                  'Quantity: ${productSnapshot['quantity']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDescription() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              productSnapshot['description'],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            isLoadingVendor
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVendorImage(),
                      const SizedBox(height: 16),
                      _buildVendorDetail('Store Name', vendor.storeName),
                      _buildVendorDetail('Email', vendor.email),
                      _buildVendorDetail('Phone', vendor.phone),
                      _buildVendorDetail('Address', vendor.address),
                      _buildVendorDetail('City', vendor.city),
                      _buildVendorDetail('State', vendor.state),
                      _buildVendorDetail('Country', vendor.country),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorImage() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(75),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(75),
          child: vendor.storeImgUrl != null
              ? Image.network(
                  vendor.storeImgUrl!,
                  fit: BoxFit.cover,
                )
              : Container(color: Colors.grey[300]),
        ),
      ),
    );
  }

  Widget _buildVendorDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
