import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bubble/bubble.dart';
import 'package:fake_chat/data/message_data.dart';
import 'package:fake_chat/data/selected_data.dart';
import 'package:fake_chat/generated/locale_keys.g.dart';
import 'package:fake_chat/models/chat_time.dart';
import 'package:fake_chat/models/user.dart';
import 'package:fake_chat/provider/chat_time_provider.dart';
import 'package:fake_chat/provider/user_provider.dart';
import 'package:fake_chat/util/admob_service.dart';
import 'package:fake_chat/view/style/colors.dart';
import 'package:fake_chat/view/style/size_config.dart';
import 'package:fake_chat/view/style/textstyles.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:provider/src/provider.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<MessageData> _messageDatas = [];
  TextEditingController? _textController;
  DateTime? pDateTime;
  ScrollController? _scrollController;

  String? locale;
  List<User> users = [];
  late ChatTime chatTime;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = TextEditingController();
    pDateTime = DateTime.now();

    // 초기에 광고 하나 보여주자
  }

  @override
  void dispose() {
    _textController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chatTime = context.watch<ChatTimeProvider>().chatTime;
    users = context.watch<UserProvider>().users;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffb2c7da),
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      // centerTitle: true,
      elevation: 0,
      title: users.length > 1
          ? RichText(
              text: TextSpan(children: [
              TextSpan(
                text: LocaleKeys.group_chat.tr(),
                style: MTextStyles.bold18Black,
              ),
              TextSpan(
                text: '${users.length + 1}',
                style: MTextStyles.bold18WarmGrey,
              )
            ]))
          : Text(users[0].name),
      actions: const [
        Icon(Icons.search),
        SizedBox(
          width: 8,
        ),
        Icon(Icons.menu),
        SizedBox(
          width: 8,
        ),
      ],
    );
  }

  _body() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Text(
                  context.locale.languageCode == "ko" ? getFakeDate() : getFakeDateForEn(),
                  style: MTextStyles.regular12White,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: _messageDatas.length,
                itemBuilder: (context, index) {
                  if (_messageDatas[index].isMine!) {
                    return returnMyMessage(index);
                  } else {
                    return returnYourMessage(index);
                  }
                },
              ),
            ),
          ),
          Container(
            // height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: const Icon(
                      Icons.add_box_outlined,
                      color: MColors.greyish,
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _textController,
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        const InkWell(
                          child: Icon(
                            Icons.sentiment_satisfied_sharp,
                            color: MColors.greyish,
                          ),
                        ),
                        // const SizedBox(
                        //   width: 8,
                        // ),
                        TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                            ),
                            onPressed: () async {
                              final result = await showConfirmationDialog<int>(
                                context: context,
                                title: LocaleKeys.user_list.tr(),
                                message: LocaleKeys.select_user_for_send_message.tr(),
                                actions: [
                                  ...List.generate(
                                    users.length,
                                    (index) => AlertDialogAction(
                                      label: '${users[index].name}',
                                      key: index,
                                    ),
                                  ),
                                  AlertDialogAction(
                                    label: LocaleKeys.send_my_message.tr(),
                                    key: users.length,
                                  ),
                                ],
                                shrinkWrap: false,
                              );
                              print('aaa $result');
                              if (result != null) {
                                if (result == users.length) {
                                  _messageDatas.add(
                                    MessageData(
                                      ids: '',
                                      isMine: true,
                                      message: _textController!.text,
                                      t: getFakeTime(),
                                    ),
                                  );
                                } else {
                                  var file = File(users[result].imagePath);

                                  _messageDatas.add(
                                    MessageData(
                                      ids: users[result].name,
                                      image: file,
                                      isMine: false,
                                      message: _textController!.text,
                                      t: getFakeTime(),
                                    ),
                                  );
                                }

                                // scrollToBottom();

                              }
                              FocusScope.of(context).unfocus();
                              WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
                              _textController!.clear();
                              setState(() {});
                            },
                            child: const Text('#', style: TextStyle(fontSize: 24, color: MColors.greyish)))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Platform.isIOS ? Container(color: Colors.white, height: 30) : SizedBox.shrink(),
        ],
      ),
    );
  }

  _scrollToEnd() async {
    _scrollController!.animateTo(_scrollController!.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController!.position.maxScrollExtent;
    _scrollController!.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  Widget returnMyMessage(int index) {
    if (index == 0 && _messageDatas[index].isMine == true) {
      return returnMyFirstMessage(index);
    } else if (index > 0 && _messageDatas[index].isMine == true && _messageDatas[index - 1].isMine == false) {
      {
        return returnMyFirstMessage(index);
      }
    } else if (index > 0 && _messageDatas[index].t!.minute != _messageDatas[index - 1].t!.minute) {
      return returnMyFirstMessage(index);
    } else {
      return returnMyNormalMessage(index);
    }
  }

  Widget returnMyFirstMessage(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: SizeConfig.screenWidth! * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  getTime(index),
                  Flexible(child: getMyFirstMessageBox(index)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget returnMyNormalMessage(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: SizeConfig.screenWidth! * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  getTime(index),
                  Flexible(child: getMyNormalMessageBox(index)),
                ],
              ),
            ),
            // Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget returnYourMessage(int index) {
    if (index == 0 && _messageDatas[index].isMine == false) {
      return returnYourFirstMessage(index);
    } else if (index > 0 &&
        _messageDatas[index].isMine == false &&
        _messageDatas[index - 1].ids != _messageDatas[index].ids) {
      {
        return returnYourFirstMessage(index);
      }
    } else if (index > 0 && _messageDatas[index].t!.minute != _messageDatas[index - 1].t!.minute) {
      return returnYourFirstMessage(index);
    } else {
      return returnYourNormalMessage(index);
    }
  }

  Widget returnYourFirstMessage(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CircleAvatar(
            //   backgroundImage: FileImage(widget._selectedData.yourImage),
            //   radius: 20,
            // ),

            Container(
              width: 40.0,
              height: 40.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_messageDatas[index].image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_messageDatas[index].ids!),
                SizedBox(
                  height: 4,
                ),
                Container(
                  width: SizeConfig.screenWidth! * 0.5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: getYourFirstMessageBox(index),
                      ),
                      getTime(index),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget returnYourNormalMessage(int index) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      width: SizeConfig.screenWidth! * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // CircleAvatar(
          //   backgroundColor: Colors.transparent,
          //   radius: 20,
          // ),
          SizedBox(
            width: 48,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeConfig.screenWidth! * 0.5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(child: getYourNormalMessageBox(index)),
                    getTime(index),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget getYourNormalMessageBox(int index) {
    return Bubble(
      // margin: BubbleEdges.only(top: 10),

      nip: BubbleNip.leftTop,
      showNip: false,
      color: MColors.white,
      radius: Radius.circular(8.0),
      child: Text(
        _messageDatas[index].message!,
        style: MTextStyles.regular14BlackColor,
      ),
    );
  }

  Widget getMyNormalMessageBox(int index) {
    return Bubble(
      // margin: BubbleEdges.only(top: 10),

      nip: BubbleNip.rightTop,
      showNip: false,

      color: MColors.kakao_yellow,
      radius: Radius.circular(8.0),
      child: Text(
        _messageDatas[index].message!,
        style: MTextStyles.regular14BlackColor,
      ),
    );
  }

  Widget getYourFirstMessageBox(int index) {
    return Bubble(
      // margin: BubbleEdges.only(top: 10),

      // alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
      nipOffset: 3.0,
      color: MColors.white,
      radius: Radius.circular(8.0),
      child: Text(
        _messageDatas[index].message!,
        style: MTextStyles.regular14BlackColor,
      ),
    );
  }

  Widget getMyFirstMessageBox(int index) {
    return Bubble(
      // margin: BubbleEdges.only(top: 10),

      // alignment: Alignment.topRight,
      nip: BubbleNip.rightTop,
      nipOffset: 3.0,
      color: MColors.kakao_yellow,
      radius: Radius.circular(8.0),
      child: Text(
        _messageDatas[index].message!,
        style: MTextStyles.regular14BlackColor,
        maxLines: 10,
      ),
    );
  }

  Widget getTime(int index) {
    if (_messageDatas.length > index + 1) {
      if (_messageDatas[index].isMine == _messageDatas[index + 1].isMine) {
        if (_messageDatas[index].t!.minute == _messageDatas[index + 1].t!.minute) {
          return SizedBox.shrink();
        }
      }
    }

    if (_messageDatas[index].t!.hour > 12) {
      int tempHour = _messageDatas[index].t!.hour - 12;
      int tempMinutes = _messageDatas[index].t!.minute;
      String tempSMinutes;
      if (tempMinutes < 10) {
        tempSMinutes = "0" + tempMinutes.toString();
      } else
        tempSMinutes = tempMinutes.toString();
      return Text("${LocaleKeys.afternoon.tr()} ${tempHour}:" + tempSMinutes, style: MTextStyles.regular10Grey06);
    } else {
      int tempHour = _messageDatas[index].t!.hour;
      int tempMinutes = _messageDatas[index].t!.minute;
      String tempSMinutes;
      if (tempMinutes < 10) {
        tempSMinutes = "0" + tempMinutes.toString();
      } else
        tempSMinutes = tempMinutes.toString();
      return Text(
        "${LocaleKeys.morning.tr()} ${tempHour}:" + tempSMinutes,
        style: MTextStyles.regular10Grey06,
      );
    }
  }

  TimeOfDay getFakeTime() {
    Duration d = DateTime.now().difference(pDateTime!);

    int fakeMinute = (chatTime.time!.minute + d.inMinutes) % 60;
    int fakeHour = (chatTime.time!.hour + d.inHours) % 24;

    TimeOfDay fakeTime = new TimeOfDay(hour: fakeHour, minute: fakeMinute);

    return fakeTime;
  }

  String getFakeDate() {
    String year = chatTime.pickedDate!.year.toString() + "년 ";
    String month = chatTime.pickedDate!.month.toString() + "월 ";
    String day = chatTime.pickedDate!.day.toString() + "일 ";
    String? dayOfTheWeek;
    switch (chatTime.pickedDate!.weekday) {
      case 1:
        dayOfTheWeek = "월요일";
        break;
      case 2:
        dayOfTheWeek = "화요일";
        break;
      case 3:
        dayOfTheWeek = "수요일";
        break;
      case 4:
        dayOfTheWeek = "목요일";
        break;
      case 5:
        dayOfTheWeek = "금요일";
        break;
      case 6:
        dayOfTheWeek = "토요일";
        break;
      case 7:
        dayOfTheWeek = "일요일";
        break;
      default:
    }

    String fakeDate = year + month + day + dayOfTheWeek!;

    return fakeDate;
  }

  String getFakeDateForEn() {
    String year = chatTime.pickedDate!.year.toString();
    String month = months[chatTime.pickedDate!.month];
    String day = chatTime.pickedDate!.day.toString();
    String? dayOfTheWeek;
    switch (chatTime.pickedDate!.weekday) {
      case 1:
        dayOfTheWeek = "Moday";
        break;
      case 2:
        dayOfTheWeek = "Tuesday";
        break;
      case 3:
        dayOfTheWeek = "Wednesday";
        break;
      case 4:
        dayOfTheWeek = "Thursday";
        break;
      case 5:
        dayOfTheWeek = "Friday";
        break;
      case 6:
        dayOfTheWeek = "Saterday";
        break;
      case 7:
        dayOfTheWeek = "Sunday";
        break;
      default:
    }

    String fakeDate = '$dayOfTheWeek, $month $day, $year';

    return fakeDate;
  }

  returnDateLine(int index) {}
}
