import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoes_shop_admin/controllers/refund_controller.dart';
import 'package:shoes_shop_admin/resources/assets_manager.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';
import 'package:shoes_shop_admin/resources/styles_manager.dart';
import 'package:shoes_shop_admin/views/main/refunds/refund_detail.dart';
import 'package:shoes_shop_admin/views/widgets/are_you_sure_dialog.dart';
import 'package:shoes_shop_admin/views/widgets/loading_widget.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final ScrollController _scrollController = ScrollController();
  late Stream<QuerySnapshot> _refundsStream;
  final RefundController _refundController = RefundController();

  @override
  void initState() {
    super.initState();
    _refundsStream = _refundController.getRefundsStream();
  }

  void _showDeleteDialog(String id) {
    if (mounted) {
      areYouSureDialog(
        title: 'Delete Refund',
        content: 'Are you sure you want to delete this refund?',
        context: context,
        action: (id) => _refundController.deleteRefund(id),
        isIdInvolved: true,
        id: id,
      );
    }
  }

  void _navigateToRefundDetails(String refundId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefundDetailsScreen(refundId: refundId),
      ),
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
              const Icon(Icons.money_off, color: Colors.black),
              const SizedBox(width: 10),
              Text(
                'Refunds',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _refundsStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error occurred!'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Image.asset(AssetManager.noImagePlaceholderImg));
                }

                List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    var refund = sortedDocs[index];
                    return FutureBuilder<String>(
                      future: _refundController
                          .getCustomerName(refund['customerId']),
                      builder:
                          (context, AsyncSnapshot<String> customerSnapshot) {
                        if (customerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (customerSnapshot.hasError) {
                          return const Text('Error loading customer name');
                        }

                        return FutureBuilder<String>(
                          future: _refundController
                              .getVendorName(refund['vendorId']),
                          builder:
                              (context, AsyncSnapshot<String> vendorSnapshot) {
                            if (vendorSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (vendorSnapshot.hasError) {
                              return const Text('Error loading vendor name');
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Slidable(
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) =>
                                          _showDeleteDialog(refund.id),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) =>
                                          _navigateToRefundDetails(refund.id),
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      icon: Icons.info,
                                      label: 'Details',
                                    ),
                                  ],
                                ),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: ListTile(
                                    onTap: () =>
                                        _navigateToRefundDetails(refund.id),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: Icon(Icons.person,
                                          color: Colors.grey.shade600),
                                    ),
                                    title: Text(
                                      'Refund ${index + 1}',
                                      style: getMediumStyle(
                                          color: Colors.black,
                                          fontSize: FontSize.s16),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Customer Name: ${customerSnapshot.data}',
                                            style: getRegularStyle(
                                                color: Colors.black,
                                                fontSize: FontSize.s14),
                                          ),
                                          Text(
                                            'Vendor Name: ${vendorSnapshot.data}',
                                            style: getRegularStyle(
                                                color: Colors.black,
                                                fontSize: FontSize.s14),
                                          ),
                                          Text(
                                            'Reason: ${refund['reason']}',
                                            style: getRegularStyle(
                                                color: Colors.black,
                                                fontSize: FontSize.s14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
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
