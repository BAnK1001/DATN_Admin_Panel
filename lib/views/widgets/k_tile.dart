import 'package:flutter/material.dart';

import '../../constants/color.dart';

class KListTile extends StatelessWidget {
  const KListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTapHandler,
    this.showSubtitle = true,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final Function? onTapHandler;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTapHandler!(),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: showSubtitle ? Text(subtitle!) : null,
      leading: Icon(
        icon,
        color: dashGrey,
      ),
    );
  }
}
