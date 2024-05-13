import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error occurred!'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Product not found!'));
          }

          var productData = snapshot.data!.data() as Map<String, dynamic>;

          // Get vendor information
          String vendorId = productData['vendorId'];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('vendors')
                .doc(vendorId)
                .get(),
            builder: (context, vendorSnapshot) {
              if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (vendorSnapshot.hasError) {
                return Center(
                    child: Text(
                        'Error occurred while fetching vendor information!'));
              }
              if (!vendorSnapshot.hasData || vendorSnapshot.data == null) {
                return Center(child: Text('Vendor not found!'));
              }

              var vendorData =
                  vendorSnapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // Choose your border color
                          width: 2, // Adjust the width of the border as needed
                        ),
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the border radius as needed
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          productData['imgUrls']
                              [0], // Assuming imgUrls is an array of image URLs
                          height:
                              200, // Adjust the height of the image as per your requirement
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Name: ${productData['productName']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(height: 8),
                          Text('Price: \$${productData['price']}',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Quantity: ${productData['quantity']}',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text(
                            'Description:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text(
                            productData['description'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Vendor: ${vendorData['vendorName']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          // Add more vendor details as needed
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
