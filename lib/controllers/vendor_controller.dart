import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class VendorController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getVendorsStream(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _firebaseFirestore.collection('vendors').snapshots();
    } else {
      return _firebaseFirestore
          .collection('vendors')
          .where('storeName', isGreaterThanOrEqualTo: searchQuery)
          .where('storeName', isLessThan: '${searchQuery}z')
          .snapshots();
    }
  }

  Future<void> toggleApproval(String docId, bool currentStatus) async {
    await _firebaseFirestore
        .collection('vendors')
        .doc(docId)
        .update({'isApproved': !currentStatus});
  }

  Future<void> banVendor(String docId) async {
    try {
      await _firebaseFirestore
          .collection('vendors')
          .doc(docId)
          .update({'isBanned': true});
    } catch (e) {
      if (kDebugMode) {
        print('Error banning vendor: $e');
      }
    }
  }

  Future<void> deleteStore(String docId) async {
    try {
      await _firebaseFirestore.collection('vendors').doc(docId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting store: $e');
      }
    }
  }
}
