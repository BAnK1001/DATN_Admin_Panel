import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoes_shop_admin/controllers/order_controller.dart';

class OrderItem extends StatelessWidget {
  final DocumentSnapshot order;
  final OrdersController _ordersController = OrdersController();

  OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              order['prodImg'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('customers')
                .doc(order['customerId'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              }
              if (snapshot.hasError) {
                return const Text('Error');
              }
              return Text(snapshot.data!['fullname'],
                  style: const TextStyle(fontWeight: FontWeight.bold));
            },
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order['prodName'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('\$${order['prodPrice']}',
                  style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 4),
              Text('Quantity: ${order['prodQuantity']}'),
              Text('Size: ${order['prodSize']}'),
              Text(DateFormat.yMMMEd().format(order['date'].toDate())),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _ordersController.deleteOrder(context, order.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showStatusUpdateDialog(context, order.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                onTap: () {
                  _ordersController.updateOrderStatus(context, orderId, 5);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Approved'),
                onTap: () {
                  _ordersController.updateOrderStatus(context, orderId, 2);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Processing'),
                onTap: () {
                  _ordersController.updateOrderStatus(context, orderId, 4);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Delivering'),
                onTap: () {
                  _ordersController.updateOrderStatus(context, orderId, 3);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Delivered'),
                onTap: () {
                  _ordersController.updateOrderStatus(context, orderId, 1);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
