import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RefundController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRefundsStream() {
    return _firebaseFirestore.collection('refunds').snapshots();
  }

  Future<String> getCustomerName(String customerId) async {
    String customerName = '';

    try {
      DocumentSnapshot customerDoc = await _firebaseFirestore
          .collection('customers')
          .doc(customerId)
          .get();

      customerName = customerDoc['fullname'];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer name: $e');
      }
    }

    return customerName;
  }

  Future<String> getVendorName(String vendorId) async {
    String vendorName = '';

    try {
      DocumentSnapshot vendorDoc =
          await _firebaseFirestore.collection('vendors').doc(vendorId).get();

      vendorName = vendorDoc['storeName'];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching vendor name: $e');
      }
    }

    return vendorName;
  }

  Future<void> deleteRefund(String id) async {
    try {
      await _firebaseFirestore.collection('refunds').doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting refund: $e');
      }
    }
  }
}
