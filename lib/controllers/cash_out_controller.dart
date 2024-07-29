import 'package:cloud_firestore/cloud_firestore.dart';

class CashOutController {
  final Stream<QuerySnapshot> cashOutStream =
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

  Future<void> deleteCashOut(String id) async {
    await FirebaseFirestore.instance
        .collection('cash_outs')
        .doc(id)
        .delete()
        .whenComplete(() {});
  }
}
