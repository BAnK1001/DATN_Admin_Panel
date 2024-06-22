import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/models/vendor.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

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
        title: const Text(
          'Product Detail',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoadingProduct
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 16),
                  _buildProductDescription(),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  _buildVendorInfo(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your edit product action here
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductName(),
              const SizedBox(height: 8),
              _buildProductPrice(),
              const SizedBox(height: 8),
              _buildProductQuantity(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          productSnapshot['imgUrls'][0],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      productSnapshot['productName'],
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 26,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductPrice() {
    return Text(
      '\$${productSnapshot['price']}',
      style: const TextStyle(
        fontSize: 24,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProductQuantity() {
    return Text(
      'Quantity: ${productSnapshot['quantity']}',
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          productSnapshot['description'],
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendor Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        isLoadingVendor
            ? const Center(child: CircularProgressIndicator())
            : Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVendorImage(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVendorDetail('Name', vendor.storeName),
                            _buildVendorDetail('Email', vendor.email),
                            _buildVendorDetail('Phone', vendor.phone),
                            _buildVendorDetail('Address', vendor.address),
                            _buildVendorDetail('City', vendor.city),
                            _buildVendorDetail('State', vendor.state),
                            _buildVendorDetail('Country', vendor.country),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildVendorImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: vendor.storeImgUrl != null
            ? Image.network(
                vendor.storeImgUrl!,
                fit: BoxFit.cover,
              )
            : Container(),
      ),
    );
  }

  Widget _buildVendorDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
