import 'dart:io';

import 'package:devicelocale/devicelocale.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

class SelectPage extends StatefulWidget {
  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  DateTime? pickedDate;
  TimeOfDay? time;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  String? _backgroundImagePath;

  // final TextEditingController myIdController = new TextEditingController();
  // final TextEditingController yourIdController = new TextEditingController();
  List<TextEditingController> yourIdControllers = [for (int i = 0; i < 5; i++) TextEditingController()];

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

    pickedDate = DateTime.now();
    time = TimeOfDay.now();

    _createInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _createInterstitialAd() {
    String adId = AdMobService().getInterstitialAdId()!;
    // String adId = 'ca-app-pub-3940256099942544/1033173712';
    InterstitialAd.load(
        adUnitId: adId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pushNamed("AddUserPage");
        },
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(LocaleKeys.select_page.tr(), overflow: TextOverflow.ellipsis, style: MTextStyles.bold18Black),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed("ManualPage");
            },
            child: Text(LocaleKeys.manual_title.tr(), style: MTextStyles.bold12Tomato))
      ],
    );
  }

  Widget _body() {
    // final usersProvider = context.watch<UserProvider>();
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocaleKeys.chat_start_time.tr(), style: MTextStyles.bold16Black),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () async {
                          _pickDate().then((value) {
                            _pickTime();
                          });
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/icons/calendar.svg'),
                            const SizedBox(
                              width: 8,
                            ),
                            context.locale.languageCode == "ko"
                                ? Text(
                                    "${pickedDate!.year}년 ${pickedDate!.month}월 ${pickedDate!.day}일,  ${time!.hour}시 ${time!.minute}분",
                                    style: MTextStyles.regular14BlackColor,
                                  )
                                : Text(
                                    " ${months[pickedDate!.month - 1]} ${pickedDate!.day}, ${pickedDate!.year}, ${time!.hour}:${time!.minute}",
                                    style: MTextStyles.regular14BlackColor,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 구분줄
                      const Divider(),

                      SizedBox(height: 18),

                      Consumer(builder: (ctx, UserProvider watch, child) {
                        final users = watch.users;
                        print(users.length);
                        return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (__, index) {
                            var imagePath = users[index].imagePath;
                            return ListTile(
                              leading: Container(
                                height: 70,
                                width: 70,
                                child: CircleAvatar(
                                  backgroundImage: FileImage(File(imagePath)),
                                  radius: 20,
                                ),
                              ),
                              title: Text(users[index].name, style: MTextStyles.regular14BlackColor),
                              trailing: InkWell(
                                  onTap: () {
                                    context.read<UserProvider>().removeUser(users[index]);
                                    // setState(() {});
                                  },
                                  child: Icon(Icons.remove_circle, color: MColors.tomato)),
                            );
                          },
                          itemCount: users.length,
                        );
                      }),

                      // divideLine(),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: MColors.tomato,
              ),
              child: Center(
                child: InkWell(
                  onTap: () {
                    if (context.read<UserProvider>().users.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(LocaleKeys.warning_message1.tr())));
                      return;
                    }

                    // context.read<UserProvider>().setMy();

                    ChatTime chatTime = ChatTime(pickedDate: pickedDate, time: time);
                    context.read<ChatTimeProvider>().setTime(chatTime);

                    _showInterstitialAd();

                    Navigator.of(context).pushNamed("ChatPage");
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    width: SizeConfig.screenWidth! - 48,
                    child: Center(
                      child: Text(
                        LocaleKeys.open_chat_room.tr(),
                        style: MTextStyles.bold12White,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget divideLine() {
    return Container(
      height: 1,
      width: SizeConfig.screenWidth! - 40,
      decoration: BoxDecoration(
          border: Border.all(
        color: MColors.white_three,
      )),
    );
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: pickedDate!,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (date != null) {
      setState(() {
        pickedDate = date;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: time!);
    if (t != null) {
      setState(() {
        time = t;
      });
    }
  }

  Future<void> showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.error_title.tr()),
          content: Text(LocaleKeys.error_contents.tr()),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
          ],
        );
      },
    );
  }
}
