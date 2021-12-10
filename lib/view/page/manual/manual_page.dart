import 'package:fake_chat/view/style/size_config.dart';
import 'package:fake_chat/view/style/textstyles.dart';
import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: Text("사용법", style: MTextStyles.bold18Black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text('1. 아래 그림처럼 채팅방 생성', style: MTextStyles.bold26black),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/images/manual0.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('2. 보내기 방법', style: MTextStyles.bold26black),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/images/manual1.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('3. 유저 선택', style: MTextStyles.bold26black),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/images/manual2.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('4. 결과 확인', style: MTextStyles.bold26black),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/images/manual3.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
