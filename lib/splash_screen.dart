import 'package:fake_chat/generated/locale_keys.g.dart';
import 'package:fake_chat/view/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 2000), () {});
    return true;
  }

  @override
  void initState() {
    super.initState();

    _mockCheckForSession().then((value) async {
      if (value == true) _navigatorToHome();
    });
  }

  void _navigatorToHome() {
    Navigator.of(context).pushNamed('SelectPage');
    // Navigator.of(context).pushNamed('OnBoardingScreenPage');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            LocaleKeys.splash_title.tr(),
            style: MTextStyles.bold26black,
          ),
        ],
      ),
    );
  }
}
