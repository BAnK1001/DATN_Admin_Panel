import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../constants/color.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/loading_widget.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({Key? key}) : super(key: key);

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final ScrollController _scrollController = ScrollController();
  late final Stream<QuerySnapshot> _cashOutStream =
      FirebaseFirestore.instance.collection('cash_outs').snapshots();

  Future<void> toggleApproval(
      String id, bool status, double amount, String vendorId) async {
    await FirebaseFirestore.instance.collection('cash_outs').doc(id).update(
      {
        'status': !status,
      },
    ).whenComplete(() async {
      if (!status) {
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .update({
          'balanceAvailable': FieldValue.increment(-amount),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .update({
          'balanceAvailable': FieldValue.increment(amount),
        });
      }

      String message = status
          ? 'The cash out has been approved successfully.'
          : 'The cash out has been rejected successfully.';
    });
  }

  Future<void> _deleteCashOut(String id) async {
    await FirebaseFirestore.instance
        .collection('cash_outs')
        .doc(id)
        .delete()
        .whenComplete(() {});
  }

  void _showDeleteDialog(String id) {
    areYouSureDialog(
      title: 'Delete Cash Out',
      content: 'Are you sure you want to delete this cash out?',
      context: context,
      action: _deleteCashOut,
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
              const Icon(Icons.monetization_on),
              const SizedBox(width: 10),
              Text(
                'Cash Outs',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _cashOutStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error occurred!'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ListTile(
                        title: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(item['vendorId'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            var vendorName = snapshot.data!['storeName'];
                            return Text(
                              vendorName,
                              style: getMediumStyle(
                                  color: Colors.black, fontSize: FontSize.s16),
                            );
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${item['amount']}',
                              style: getMediumStyle(
                                  color: Colors.black, fontSize: FontSize.s14),
                            ),
                            Text(
                              intl.DateFormat.yMMMEd()
                                  .format(item['date'].toDate()),
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color:
                                    item['status'] ? primaryColor : accentColor,
                              ),
                              onPressed: () => toggleApproval(
                                item.id,
                                item['status'],
                                item['amount'],
                                item['vendorId'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(item.id),
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
