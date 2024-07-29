import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';
import 'orders_list_view.dart'; // You need to update this file accordingly.

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
        body: TabBarView(
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
