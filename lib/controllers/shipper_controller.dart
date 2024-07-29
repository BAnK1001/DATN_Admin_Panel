import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ShipperController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getShippersStream(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _firebaseFirestore.collection('shippers').snapshots();
    } else {
      return _firebaseFirestore
          .collection('shippers')
          .where('fullname', isGreaterThanOrEqualTo: searchQuery)
          .where('fullname', isLessThan: '${searchQuery}z')
          .snapshots();
    }
  }

  Future<void> toggleApproval(String docId, bool currentStatus) async {
    try {
      await _firebaseFirestore.collection('shippers').doc(docId).update({
        'isApproved': !currentStatus,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling approval: $e');
      }
    }
  }

  Future<void> deleteShipper(String id) async {
    try {
      await _firebaseFirestore.collection('shippers').doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting shipper: $e');
      }
    }
  }
}
