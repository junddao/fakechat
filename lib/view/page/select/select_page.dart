import 'dart:io';

import 'package:devicelocale/devicelocale.dart';
import 'package:fake_chat/data/selected_data.dart';
import 'package:fake_chat/generated/locale_keys.g.dart';
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

class SelectPage extends StatefulWidget {
  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  DateTime? pickedDate;
  TimeOfDay? time;

  File? _myImage;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  List<String>? _imagePaths = List.generate(5, (index) => '');
  String? _backgroundImagePath;
  final picker = ImagePicker();

  // final TextEditingController myIdController = new TextEditingController();
  // final TextEditingController yourIdController = new TextEditingController();
  List<TextEditingController> yourIdControllers = [
    for (int i = 0; i < 5; i++) TextEditingController()
  ];

  int otherUserCnt = 0;

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

  Future getYourImage(int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagePaths![index] = pickedFile.path;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Text(
          LocaleKeys.manual_title.tr(),
          style: MTextStyles.bold12Black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("ManualPage");
        },
      ),
    );
  }

  _appBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        title:
            Text(LocaleKeys.select_page.tr(), style: MTextStyles.bold18Black),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent);
  }

  _body() {
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
                      Text(LocaleKeys.chat_start_time.tr(),
                          style: MTextStyles.bold16Black),
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
                      // Container(
                      //   height: 1,
                      //   width: SizeConfig.screenWidth! - 40,
                      //   decoration: BoxDecoration(
                      //       border: Border.all(
                      //     color: MColors.white_three,
                      //   )),
                      // ),
                      // const SizedBox(height: 16),
                      // Text("채팅방 배경 사진 선택", style: MTextStyles.bold16Black),
                      // SizedBox(height: 16),
                      // Row(children: [
                      //   SizedBox(width: 16),
                      //   InkWell(
                      //     onTap: () {
                      //       getBackgroundImage();
                      //     },
                      //     child: Container(
                      //       height: 44,
                      //       width: 120,
                      //       decoration: BoxDecoration(
                      //           borderRadius:
                      //               BorderRadius.all(Radius.circular(24)),
                      //           border: Border.all(
                      //               color: MColors.white_three, width: 1),
                      //           color: MColors.white),
                      //       child: Padding(
                      //         padding:
                      //             const EdgeInsets.only(left: 10, right: 10),
                      //         child: Center(
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               SvgPicture.asset(
                      //                   'assets/icons/camera_g.svg'),
                      //               const SizedBox(
                      //                 width: 6,
                      //               ),
                      //               const Text('사진 선택',
                      //                   style:
                      //                       MTextStyles.medium12BrownishGrey),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ]),
                      // SizedBox(height: 10),
                      // Divider(),
                      SizedBox(height: 10),
                      addUser(),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      otherUserCnt > 0 ? otherUserWidget(0) : SizedBox.shrink(),
                      otherUserCnt > 1 ? otherUserWidget(1) : SizedBox.shrink(),
                      otherUserCnt > 2 ? otherUserWidget(2) : SizedBox.shrink(),
                      otherUserCnt > 3 ? otherUserWidget(3) : SizedBox.shrink(),
                      otherUserCnt > 4 ? otherUserWidget(4) : SizedBox.shrink(),
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
                    if (otherUserCnt == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(LocaleKeys.warning_message1.tr())));
                      return;
                    }
                    String myId = 'rkWkcoxld!!';
                    List<String> ids =
                        List.generate(otherUserCnt, (index) => '');
                    for (int i = 0; i < otherUserCnt; i++) {
                      ids[i] = yourIdControllers[i].text;
                    }

                    // ids.add(myIdController.text);

                    List<File>? _yourImages = [];

                    for (int i = 0; i < _imagePaths!.length; i++) {
                      if (_imagePaths![i] == '') {
                        break;
                      }
                      _yourImages.add(File(_imagePaths![i]));
                    }

                    if (_yourImages.length < otherUserCnt ||
                        ids.length < otherUserCnt) {
                      showAlertDialog(context);
                    } else {
                      SelectedData selectedData = SelectedData(
                        pickedDate: pickedDate!,
                        myId: myId,
                        yourId: ids,
                        time: time!,
                        // myImage: _myImage,
                        yourImage: _yourImages,
                      );

                      _showInterstitialAd();

                      Navigator.of(context)
                          .pushNamed("ChatPage", arguments: selectedData);
                    }
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

  Widget otherUserWidget(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          // color: MColors.white_three08,
          border: Border.all(color: Colors.black, width: 3.0),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text("${LocaleKeys.otherId.tr()} ${index + 1}",
                style: MTextStyles.bold16Black),

            SizedBox(height: 16),
            Container(
              height: 54,
              // width: SizeConfig.screenWidth - 200,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: MColors.pinkish_grey, width: 1)),
              child: TextFormField(
                controller: yourIdControllers[index],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  hintText: LocaleKeys.otherName.tr(),
                  hintStyle: MTextStyles.medium16WhiteThree,
                  labelStyle: TextStyle(color: Colors.transparent),
                  counterText: '',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // 구분줄
            Text(LocaleKeys.otherPersonImage.tr(),
                style: MTextStyles.bold16Black),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    getYourImage(index);
                  },
                  child: Container(
                    height: 44,
                    // width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        border:
                            Border.all(color: MColors.white_three, width: 1),
                        color: MColors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/camera_g.svg'),
                            SizedBox(
                              width: 6,
                            ),
                            Text(LocaleKeys.selectImage.tr(),
                                style: MTextStyles.medium12BrownishGrey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                //사진 추가 listview

                Container(
                  height: 70,
                  width: 70,
                  child: _imagePaths!.length <= index
                      ? SizedBox.shrink()
                      : CircleAvatar(
                          backgroundImage: FileImage(File(_imagePaths![index])),
                          radius: 20,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget addUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(LocaleKeys.notice.tr(), style: MTextStyles.bold16Black),
        const SizedBox(height: 16),
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  otherUserCnt = otherUserCnt + 1;
                });
              },
              child: Container(
                height: 44,
                // width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    border: Border.all(color: MColors.white_three, width: 1),
                    color: MColors.white),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.plus_one),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(LocaleKeys.add_user.tr(),
                            style: MTextStyles.medium12BrownishGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () {
                setState(() {
                  otherUserCnt = otherUserCnt - 1;
                });
              },
              child: Container(
                height: 44,
                // width: 120,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    border: Border.all(color: MColors.white_three, width: 1),
                    color: MColors.white),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.exposure_minus_1,
                            color: MColors.tomato),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(LocaleKeys.remove_user.tr(),
                            style: MTextStyles.medium12tomato),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void getBackgroundImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _backgroundImagePath = pickedFile.path;
      } else {
        print('No image selected.');
      }
    });
  }
}
