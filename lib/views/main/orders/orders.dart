import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/views/components/scroll_component.dart';
import '../../../constants/color.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/loading_widget.dart';
import 'package:intl/intl.dart' as intl;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Stream<QuerySnapshot> ordersStream =
      FirebaseFirestore.instance.collection('orders').snapshots();

  final ScrollController _scrollController = ScrollController();

  // called after alert for dismissal
  doneWithAction() {
    Navigator.of(context).pop();
  }

  // delete order
  Future<void> deleteOrder(String id) async {
    //pop out
    doneWithAction();

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .delete()
        .whenComplete(() {
      kCoolAlert(
        message: 'You have successfully deleted the order',
        context: context,
        alert: CoolAlertType.success,
        action: doneWithAction,
      );
    });
  }

  // toggle order approval
  Future<void> toggleApproval(String id, bool status) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).update(
      {
        'isApproved': !status,
      },
    );
  }

  // delete dialog
  void deleteDialog(String id) {
    areYouSureDialog(
      title: 'Delete order',
      content: 'Are you sure you want to delete this order?',
      context: context,
      action: deleteOrder,
      isIdInvolved: true,
      id: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout),
              const SizedBox(width: 10),
              Text(
                'Orders',
                style: getMediumStyle(
                  color: Colors.black,
                  fontSize: FontSize.s16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error occurred!'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }

                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Image.asset(AssetManager.noImagePlaceholderImg),
                  );
                }

                List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
                sortedDocs.sort((a, b) => b['date'].compareTo(a['date']));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    var item = sortedDocs[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['prodImg'],
                            width: 50,
                          ),
                        ),
                        title: FutureBuilder<String>(
                          future: FirebaseFirestore.instance
                              .collection('customers')
                              .doc(item['customerId'])
                              .get()
                              .then((DocumentSnapshot doc) => doc['fullname']),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error occurred!');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            return Text(snapshot.data ?? '',
                                style: getMediumStyle(
                                    color: Colors.black,
                                    fontSize: FontSize.s16));
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: FirebaseFirestore.instance
                                  .collection('vendors')
                                  .doc(item['vendorId'])
                                  .get()
                                  .then((DocumentSnapshot doc) =>
                                      doc['storeName']),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Error occurred!');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                return Text(snapshot.data ?? '',
                                    style: getMediumStyle(
                                        color: Colors.black,
                                        fontSize: FontSize.s14));
                              },
                            ),
                            Text('${item['prodName']}',
                                style: getRegularStyle(
                                    color: Colors.black54,
                                    fontSize: FontSize.s12)),
                            Text('\$${item['prodPrice']}',
                                style: getRegularStyle(
                                    color: Colors.black54,
                                    fontSize: FontSize.s12)),
                            Text('Quantity: ${item['prodQuantity']}',
                                style: getRegularStyle(
                                    color: Colors.black54,
                                    fontSize: FontSize.s12)),
                            Text('Size: ${item['prodSize']}',
                                style: getRegularStyle(
                                    color: Colors.black54,
                                    fontSize: FontSize.s12)),
                            Text(
                                intl.DateFormat.yMMMEd()
                                    .format(item['date'].toDate()),
                                style: getRegularStyle(
                                    color: Colors.black54,
                                    fontSize: FontSize.s12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle,
                                  color: item['isApproved']
                                      ? primaryColor
                                      : accentColor),
                              onPressed: () => toggleApproval(
                                  item['orderId'], item['isApproved']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteDialog(item['orderId']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
