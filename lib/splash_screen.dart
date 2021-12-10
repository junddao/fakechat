import 'package:fake_chat/view/style/textstyles.dart';
import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Fake Chat',
            style: MTextStyles.bold26black,
          ),
        ],
      ),
    );
  }
}
