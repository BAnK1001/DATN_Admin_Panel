import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

class OrdersController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOrdersStream(int status) {
    return _firebaseFirestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<void> deleteOrder(BuildContext context, String orderId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (confirm) {
      try {
        await _firebaseFirestore.collection('orders').doc(orderId).delete();
        CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: 'Order deleted successfully!',
        );
      } catch (e) {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: 'Failed to delete order: $e',
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Order',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Are you sure you want to delete this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> updateOrderStatus(
      BuildContext context, String orderId, int newStatus) async {
    try {
      await _firebaseFirestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Order status updated successfully!',
      );
    } catch (e) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: 'Failed to update order status: $e',
      );
    }
  }
}
