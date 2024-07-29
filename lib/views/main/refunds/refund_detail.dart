import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class RefundDetailsScreen extends StatefulWidget {
  final String refundId;

  const RefundDetailsScreen({super.key, required this.refundId});

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
      if (kDebugMode) {
        print('Error fetching additional data: $e');
      }
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
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference customerRef =
            FirebaseFirestore.instance.collection('customers').doc(customerId);
        DocumentSnapshot customerSnapshot = await transaction.get(customerRef);

        if (customerSnapshot.exists) {
          double currentRefundAmount =
              customerSnapshot.get('refundAmount') ?? 0.0;
          transaction.update(
              customerRef, {'refundAmount': currentRefundAmount + amount});
        } else {
          throw Exception('Customer not found');
        }

        DocumentReference walletTransactionRef =
            FirebaseFirestore.instance.collection('walletTransactions').doc();

        transaction.set(walletTransactionRef, {
          'transactionId': walletTransactionRef.id,
          'refundId': refundId,
          'customerId': customerId,
          'amount': amount,
          'transactionDate': DateTime.now(),
          'type': 'refund',
          'status': 'completed',
        });
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error processing refund: $error');
      }
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Main content
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
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
                fetchAdditionalData(
                    refundData['customerId'], refundData['vendorId']);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Refund Details',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildInfoCard('Refund Information', [
                                    buildInfoRow(
                                        'Reason',
                                        refundData['reason'] ??
                                            'No reason provided'),
                                    buildInfoRow('Amount',
                                        '\$${refundData['amount'].toString()}'),
                                    buildInfoRow('Status',
                                        getStatusText(refundData['status'])),
                                  ]),
                                  const SizedBox(height: 24),
                                  buildInfoCard('Customer Information', [
                                    buildInfoRow(
                                        'Name',
                                        customerName.isEmpty
                                            ? 'Loading...'
                                            : customerName),
                                    buildInfoRow(
                                        'ID', refundData['customerId']),
                                  ]),
                                  const SizedBox(height: 24),
                                  buildInfoCard('Vendor Information', [
                                    buildInfoRow(
                                        'Name',
                                        vendorName.isEmpty
                                            ? 'Loading...'
                                            : vendorName),
                                    buildInfoRow('ID', refundData['vendorId']),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildMediaCard(
                                    mediaType: refundData['mediaType'],
                                    mediaUrl: refundData['mediaUrl'],
                                    videoController: _videoController,
                                  ),
                                  const SizedBox(height: 24),
                                  buildVendorCheckNotification(
                                      refundData['isVendorCheck']),
                                  const SizedBox(height: 24),
                                  buildActionButtons(refundData['status']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildMediaCard({
    required String mediaType,
    required String mediaUrl,
    VideoPlayerController? videoController,
  }) {
    if (mediaType == 'image') {
      return Card(
        child: Column(
          children: [
            Image.network(mediaUrl),
          ],
        ),
      );
    } else if (mediaType == 'video' && videoController != null) {
      return Card(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      if (_isPlaying) {
                        videoController.pause();
                      } else {
                        videoController.play();
                      }
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildVendorCheckNotification(bool isVendorCheck) {
    if (isVendorCheck) {
      return Card(
        color: Colors.green[100],
        child: const ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('Vendor has confirmed the status.'),
        ),
      );
    } else {
      return Card(
        color: Colors.red[100],
        child: const ListTile(
          leading: Icon(Icons.error, color: Colors.red),
          title: Text('Vendor has not confirmed the status.'),
        ),
      );
    }
  }

  Widget buildActionButtons(int currentStatus) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: currentStatus != 1
              ? () => showConfirmationDialog(context, 1)
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Approve'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: currentStatus != 2
              ? () => showConfirmationDialog(context, 2)
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Deny'),
        ),
      ],
    );
  }
}
