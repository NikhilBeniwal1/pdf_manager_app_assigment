import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class VandeBharatLottieLoader extends StatelessWidget {
  final double width;
  final double height;

  const VandeBharatLottieLoader({this.width = 200, this.height = 80, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
       // 'assets/animation/Animation - 1752067426989.json',
       "assets/animation/Animation - 1752067575945.json",
        repeat: true,
        animate: true,
      ),
    );
  }
}