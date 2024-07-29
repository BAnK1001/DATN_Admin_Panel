import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUsersStream(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _firebaseFirestore.collection('customers').snapshots();
    } else {
      return _firebaseFirestore
          .collection('customers')
          .where('fullname', isGreaterThanOrEqualTo: searchQuery)
          .where('fullname', isLessThan: '${searchQuery}z')
          .snapshots();
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _firebaseFirestore.collection('customers').doc(id).delete();
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }
}
