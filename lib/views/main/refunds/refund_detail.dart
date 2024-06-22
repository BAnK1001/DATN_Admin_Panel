import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/resources/font_manager.dart';
import 'package:shoes_shop_admin/resources/styles_manager.dart';
import 'package:video_player/video_player.dart';

class RefundDetailsScreen extends StatefulWidget {
  final String refundId;

  const RefundDetailsScreen({Key? key, required this.refundId})
      : super(key: key);

  @override
  State<RefundDetailsScreen> createState() => _RefundDetailsScreenState();
}

class _RefundDetailsScreenState extends State<RefundDetailsScreen> {
  late Future<DocumentSnapshot> _refundDetails;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  String customerName = '';
  String vendorName = '';

  @override
  void initState() {
    super.initState();
    _refundDetails = getRefundDetails();
  }

  Future<DocumentSnapshot> getRefundDetails() async {
    return await FirebaseFirestore.instance
        .collection('refunds')
        .doc(widget.refundId)
        .get();
  }

  Future<void> fetchAdditionalData(String customerId, String vendorId) async {
    try {
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (mounted) {
        setState(() {
          customerName = customerDoc['fullname'];
          vendorName = vendorDoc['storeName'];
        });
      }
    } catch (e) {
      print('Error fetching additional data: $e');
    }
  }

  Future<void> updateRefundStatus(
      BuildContext context, String refundId, int newStatus) async {
    try {
      DocumentSnapshot refundSnapshot = await FirebaseFirestore.instance
          .collection('refunds')
          .doc(refundId)
          .get();

      if (refundSnapshot.exists) {
        int currentStatus = refundSnapshot['status'];
        if (newStatus == 1 && currentStatus != 1) {
          await FirebaseFirestore.instance
              .collection('refunds')
              .doc(refundId)
              .update({'status': newStatus, 'isAdminCheck': true});

          // Call the method to process the refund
          await processRefund(
              refundSnapshot['customerId'], refundSnapshot['amount'], refundId);

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Status updated successfully and refund processed!')),
          );

          // Refresh refund details
          setState(() {
            _refundDetails = getRefundDetails();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to update status to Approved.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund document does not exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> processRefund(
      String customerId, double amount, String refundId) async {
    DocumentReference customerWalletRef =
        FirebaseFirestore.instance.collection('wallets').doc(customerId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot walletSnapshot =
          await transaction.get(customerWalletRef);

      if (walletSnapshot.exists) {
        double currentBalance = walletSnapshot['balance'];
        double newBalance = currentBalance + amount;

        transaction.update(customerWalletRef, {'balance': newBalance});
      } else {
        transaction.set(customerWalletRef, {'balance': amount});
      }

      transaction.set(
        FirebaseFirestore.instance.collection('walletTransactions').doc(),
        {
          'transactionId': FirebaseFirestore.instance
              .collection('walletTransactions')
              .doc()
              .id,
          'refundId': refundId,
          'customerId': customerId,
          'amount': amount,
          'transactionDate': DateTime.now(),
          'status': 1,
        },
      );
    });
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Requested';
      case 1:
        return 'Approved';
      case 2:
        return 'Denied';
      default:
        return 'Unknown';
    }
  }

  void showConfirmationDialog(BuildContext context, int newStatus) {
    String statusText = getStatusText(newStatus);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Status Update'),
          content: Text(
              'Are you sure you want to update the status to "$statusText"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                updateRefundStatus(context, widget.refundId,
                    newStatus); // Call the method to update status
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Details'),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: _refundDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasError) {
                return Container();
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Container();
              }

              var refundData = snapshot.data!.data() as Map<String, dynamic>;
              int currentStatus = refundData['status'];
              if (currentStatus == 1) {
                return Container();
              }

              return PopupMenuButton<int>(
                onSelected: (int newStatus) {
                  if (newStatus != 0 || currentStatus == 0) {
                    showConfirmationDialog(context, newStatus);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cannot update status to Requested.')),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  // Create the list of menu items based on the current status
                  List<PopupMenuEntry<int>> menuItems = [];
                  List<int> statusOptions = [0, 1, 2, 3];

                  // Remove the current status from the list
                  statusOptions.remove(currentStatus);

                  for (int status in statusOptions) {
                    menuItems.add(PopupMenuItem<int>(
                      value: status,
                      child: Text(getStatusText(status)),
                    ));
                  }

                  return menuItems;
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _refundDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Refund not found'));
          }

          var refundData = snapshot.data!.data() as Map<String, dynamic>;
          fetchAdditionalData(refundData['customerId'], refundData['vendorId']);

          if (refundData['mediaType'] == 'video') {
            _videoController =
                VideoPlayerController.networkUrl(refundData['mediaUrl'])
                  ..initialize().then((_) {
                    setState(() {});
                  });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refund Information',
                    style: getMediumStyle(
                        color: Colors.black, fontSize: FontSize.s20),
                  ),
                  const SizedBox(height: 16),
                  buildDetailCard(
                    icon: Icons.report_problem,
                    title: 'Reason',
                    content: refundData['reason'],
                  ),
                  buildDetailCard(
                    icon: Icons.comment,
                    title: 'Comment',
                    content: refundData['comment'],
                  ),
                  buildDetailCard(
                    icon: Icons.attach_money,
                    title: 'Amount',
                    content: '\$${refundData['amount']}',
                  ),
                  buildDetailCard(
                    icon: Icons.person,
                    title: 'Customer Name',
                    content: customerName,
                  ),
                  buildDetailCard(
                    icon: Icons.store,
                    title: 'Vendor Name',
                    content: vendorName,
                  ),
                  buildDetailCard(
                    icon: Icons.receipt,
                    title: 'Order ID',
                    content: refundData['orderId'],
                  ),
                  buildDetailCard(
                    icon: Icons.assignment_turned_in,
                    title: 'Status',
                    content: getStatusText(refundData['status']),
                  ),
                  buildDetailCard(
                    icon: Icons.date_range,
                    title: 'Request Date',
                    content: refundData['requestDate'].toDate().toString(),
                  ),
                  if (refundData.containsKey('isVendorCheck'))
                    buildVendorCheckNotification(refundData['isVendorCheck']),
                  if (refundData['mediaType'] == 'image')
                    buildMediaCard(
                      mediaType: 'image',
                      mediaUrl: refundData['mediaUrl'],
                    ),
                  if (refundData['mediaType'] == 'video' &&
                      _videoController != null)
                    buildMediaCard(
                      mediaType: 'video',
                      videoController: _videoController,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getMediumStyle(
                        color: Colors.black, fontSize: FontSize.s16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: getRegularStyle(
                        color: Colors.black54, fontSize: FontSize.s14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMediaCard({
    required String mediaType,
    String? mediaUrl,
    VideoPlayerController? videoController,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: mediaType == 'image'
            ? Image.network(mediaUrl!)
            : Column(
                children: [
                  AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  ),
                  VideoProgressIndicator(videoController, allowScrubbing: true),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        _isPlaying
                            ? videoController.pause()
                            : videoController.play();
                        _isPlaying = !_isPlaying;
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildVendorCheckNotification(bool isVendorChecked) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isVendorChecked ? Icons.check_circle : Icons.error,
              color: isVendorChecked ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isVendorChecked
                    ? 'This request has been checked by the Vendor.'
                    : 'This request has not been reviewed by the Vendor.',
                style: TextStyle(
                  fontSize: FontSize.s16,
                  color: isVendorChecked ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
