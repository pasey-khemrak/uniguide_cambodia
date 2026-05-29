import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/google_g_logo.svg',
      width: size,
      height: size,
      semanticsLabel: 'Google',
    );
  }
}
