import 'package:flutter/material.dart';
import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';

Future<void> areYouSureDialog({
  required String title,
  required String content,
  required BuildContext context,
  required Function action,
  bool isIdInvolved = false,
  String id = '',
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: getMediumStyle(
          color: Colors.black,
          fontSize: FontSize.s16,
        ),
      ),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            Navigator.of(context).pop(); // This will close the dialog

            if (isIdInvolved) {
              await action(id);
            } else {
              await action();
            }
            // ignore: use_build_context_synchronously
          },
          child: const Text('Yes'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No'),
        ),
      ],
    ),
  );
}
