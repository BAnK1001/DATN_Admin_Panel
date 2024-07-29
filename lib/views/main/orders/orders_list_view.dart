import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop_admin/controllers/order_controller.dart';
import 'package:shoes_shop_admin/views/main/orders/orders_item.dart'; // Ensure this file is updated accordingly.

class OrdersListView extends StatelessWidget {
  final int status;
  final OrdersController _ordersController = OrdersController();

  OrdersListView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersController.getOrdersStream(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No orders found', style: TextStyle(fontSize: 18)));
        }

        var orders = snapshot.data!.docs;
        orders.sort((a, b) => b['date'].compareTo(a['date']));

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            return OrderItem(order: order);
          },
        );
      },
    );
  }
}
