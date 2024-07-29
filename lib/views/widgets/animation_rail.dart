import 'package:flutter/material.dart';
import 'package:shoes_shop_admin/constants/color.dart';

class AnimatedRail extends StatelessWidget {
  const AnimatedRail({super.key, required this.widget, required this.fnc});
  final Widget widget;
  final VoidCallback fnc;

  @override
  Widget build(BuildContext context) {
    // Obtain the current animation from NavigationRail
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => SizedBox(
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: FloatingActionButton.extended(
            backgroundColor: accentColor,
            onPressed: () => fnc(),
            label: widget,
            isExtended: animation.status == AnimationStatus.completed,
          ),
        ),
      ),
    );
  }
}
