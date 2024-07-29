import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/views/widgets/are_you_sure_dialog.dart';

class ProductController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProductStream(String searchValue) {
    if (searchValue.isEmpty) {
      return _firebaseFirestore.collection('products').snapshots();
    } else {
      return _firebaseFirestore
          .collection('products')
          .where('productName', isGreaterThanOrEqualTo: searchValue)
          .where('productName', isLessThan: '${searchValue}z')
          .snapshots();
    }
  }

  Future<void> toggleApproval(String id, bool status) async {
    try {
      await _firebaseFirestore
          .collection('products')
          .doc(id)
          .update({'isApproved': !status});
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error toggling approval: $e');
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firebaseFirestore.collection('products').doc(id).delete();
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
    }
  }

  void showDeleteDialog(
    BuildContext context,
    String id, {
    required Future<void> Function(String) deleteAction,
  }) {
    areYouSureDialog(
      title: 'Delete Product',
      content: 'Are you sure you want to delete this product?',
      context: context,
      action: deleteAction,
      isIdInvolved: true,
      id: id,
    );
  }
}
