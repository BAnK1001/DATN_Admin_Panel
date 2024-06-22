import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.black, size: 24),
              SizedBox(width: 8),
              Text('Orders',
                  style: TextStyle(
                      fontSize: FontSize.s16, fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Delivering'),
              Tab(text: 'Approved'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersListView(status: 5),
            OrdersListView(status: 4),
            OrdersListView(status: 3),
            OrdersListView(status: 2),
            OrdersListView(status: 1),
          ],
        ),
      ),
    );
  }
}

class OrdersListView extends StatelessWidget {
  final int status;

  const OrdersListView({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .snapshots(),
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

class OrderItem extends StatelessWidget {
  final DocumentSnapshot order;

  const OrderItem({Key? key, required this.order}) : super(key: key);

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
                onPressed: () => _deleteOrder(context, order.id),
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

  void _deleteOrder(BuildContext context, String orderId) async {
    bool confirm = await _showConfirmationDialog(context);
    if (confirm) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Order deleted successfully!',
      );
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

  void _showStatusUpdateDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                onTap: () {
                  updateOrderStatus(context, orderId, 5);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Approved'),
                onTap: () {
                  updateOrderStatus(context, orderId, 2);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Processing'),
                onTap: () {
                  updateOrderStatus(context, orderId, 4);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Delivering'),
                onTap: () {
                  updateOrderStatus(context, orderId, 3);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Delivered'),
                onTap: () {
                  updateOrderStatus(context, orderId, 1);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateOrderStatus(
      BuildContext context, String orderId, int newStatus) async {
    try {
      await FirebaseFirestore.instance
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
