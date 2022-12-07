import 'package:flutter/material.dart';

class BuildLogo extends StatelessWidget {
  const BuildLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Hero(
        tag: "logo",
        child: SizedBox(
          height: 200.0,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}