import 'package:fake_chat/view/page/chat/chat_page.dart';
import 'package:fake_chat/view/page/manual/manual_page.dart';
import 'package:fake_chat/view/page/select/add_user_page.dart';
import 'package:fake_chat/view/page/select/select_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    dynamic arguments = settings.arguments;

    switch (settings.name) {
      case 'SelectPage':
        return CupertinoPageRoute(builder: (_) => SelectPage());
      case 'ManualPage':
        return CupertinoPageRoute(builder: (_) => ManualPage());
      case 'ManualPage':
        return CupertinoPageRoute(builder: (_) => AddUserPage());
      case 'ChatPage':
        return CupertinoPageRoute(builder: (_) => ChatPage());
      case 'AddUserPage':
        return CupertinoPageRoute(builder: (_) => AddUserPage());

      // case 'ClassProceedingPage':
      //   return CupertinoPageRoute(
      //       builder: (_) => ClassProceedingPage(id: arguments));

      // case 'GuestProfilePage':
      //   return CupertinoPageRoute(
      //       builder: (_) => ChangeNotifierProvider(
      //             create: (_) =>
      //                 OtherUserProfileProvider('${UserInfo.myProfile.id}'),
      //             child: GuestProfilePage(),
      //           ));

      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('${settings.name} 는 lib/route.dart에 정의 되지 않았습니다.'),
                  ),
                ));
    }
  }
}
