import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import '../../../constants/color.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/loading_widget.dart';

class ShipperScreen extends StatefulWidget {
  const ShipperScreen({Key? key}) : super(key: key);

  @override
  State<ShipperScreen> createState() => _ShipperScreenState();
}

class _ShipperScreenState extends State<ShipperScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _shippersStream;

  @override
  void initState() {
    super.initState();
    _shippersStream =
        FirebaseFirestore.instance.collection('shippers').snapshots();
  }

  Future<void> _toggleApproval(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('shippers')
        .doc(docId)
        .update({'isApproved': !currentStatus});
    kCoolAlert(
      message: 'You have successfully set the approval to ${!currentStatus}',
      context: context,
      alert: CoolAlertType.success,
      action: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _deleteShipper(String id) async {
    await FirebaseFirestore.instance
        .collection('shippers')
        .doc(id)
        .delete()
        .whenComplete(() {
      kCoolAlert(
        message: 'You have successfully deleted the shipper',
        context: context,
        alert: CoolAlertType.success,
        action: () => Navigator.of(context).pop(),
      );
    });
  }

  void _showDeleteDialog(String id) {
    areYouSureDialog(
      title: 'Delete Shipper',
      content: 'Are you sure you want to delete this shipper?',
      context: context,
      action: _deleteShipper,
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
              const Icon(Icons.local_shipping),
              const SizedBox(width: 10),
              Text(
                'Shippers',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search shippers...',
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _shippersStream = FirebaseFirestore.instance
                      .collection('shippers')
                      .where('fullname', isGreaterThanOrEqualTo: value)
                      .where('fullname', isLessThan: value + 'z')
                      .snapshots();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _shippersStream,
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
                    var item = sortedDocs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item['fullname'],
                          style: getMediumStyle(
                              color: Colors.black, fontSize: FontSize.s16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone: ${item['phone']}',
                              style: getMediumStyle(
                                  color: Colors.black, fontSize: FontSize.s14),
                            ),
                            Text(
                              'Email: ${item['email']}',
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                            Text(
                              'Address: ${item['address']}',
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                            Text(
                              item['isApproved'] ? 'Approved' : 'Not Approved',
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
                                color: item['isApproved']
                                    ? primaryColor
                                    : accentColor,
                              ),
                              onPressed: () =>
                                  _toggleApproval(item.id, item['isApproved']),
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
