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

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({Key? key}) : super(key: key);

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _vendorStream;

  @override
  void initState() {
    super.initState();
    _vendorStream =
        FirebaseFirestore.instance.collection('vendors').snapshots();
  }

  Future<void> _toggleApproval(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(docId)
        .update({'isApproved': !currentStatus});
    kCoolAlert(
      message: 'You have successfully set the approval to ${!currentStatus}',
      context: context,
      alert: CoolAlertType.success,
      action: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _banVendor(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(docId)
          .update({'isBanned': true});
      kCoolAlert(
        message: 'Vendor has been successfully banned.',
        context: context,
        alert: CoolAlertType.success,
        action: () => Navigator.of(context).pop(),
      );
    } catch (e) {
      kCoolAlert(
        message: 'Error banning vendor: $e',
        context: context,
        alert: CoolAlertType.error,
        action: () => Navigator.of(context).pop(),
      );
    }
  }

  void _showDeleteDialog(String docId, String storeName) {
    areYouSureDialog(
      title: 'Delete $storeName',
      content: 'Are you sure you want to delete this store?',
      context: context,
      action: _deleteStore,
      id: docId,
      isIdInvolved: true,
    );
  }

  Future<void> _deleteStore(String docId) async {
    await FirebaseFirestore.instance.collection('vendors').doc(docId).delete();
    kCoolAlert(
      message: 'You have successfully deleted the store',
      context: context,
      alert: CoolAlertType.success,
      action: () => Navigator.of(context).pop(),
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
              const Icon(Icons.group),
              const SizedBox(width: 10),
              Text(
                'Vendors',
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
                hintText: 'Search vendors...',
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
                  _vendorStream = FirebaseFirestore.instance
                      .collection('vendors')
                      .where('storeName', isGreaterThanOrEqualTo: value)
                      .where('storeName', isLessThan: value + 'z')
                      .snapshots();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _vendorStream,
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
                sortedDocs
                    .sort((a, b) => b['storeName'].compareTo(a['storeName']));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    var item = sortedDocs[index];
                    bool isBanned = item['isBanned'] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['storeImgUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item['storeName'],
                          style: getMediumStyle(
                              color: Colors.black, fontSize: FontSize.s16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['email'],
                              style: getMediumStyle(
                                  color: Colors.black, fontSize: FontSize.s14),
                            ),
                            Text(
                              '${item['city']}, ${item['state']}, ${item['country']}',
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                            if (isBanned)
                              Text(
                                'This vendor is banned',
                                style: getRegularStyle(
                                    color: Colors.red, fontSize: FontSize.s12),
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
                            if (!isBanned)
                              IconButton(
                                icon:
                                    const Icon(Icons.block, color: Colors.red),
                                onPressed: () => _banVendor(item.id),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _showDeleteDialog(item.id, item['storeName']),
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
