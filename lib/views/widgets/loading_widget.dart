import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../constants/color.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.size = 70});
  final double size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      color: primaryColor,
      size: size,
    );
  }
}
