import 'dart:io';

import 'package:fake_chat/generated/locale_keys.g.dart';
import 'package:fake_chat/provider/user_provider.dart';
import 'package:fake_chat/view/style/colors.dart';
import 'package:fake_chat/view/style/size_config.dart';
import 'package:fake_chat/view/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/single_child_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/src/provider.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  TextEditingController controller = TextEditingController();
  final picker = ImagePicker();
  String imagePath = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      foregroundColor: MColors.black,
      title: Text(LocaleKeys.select_page.tr(), overflow: TextOverflow.ellipsis, style: MTextStyles.bold18Black),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Text(LocaleKeys.selectImage.tr(), style: MTextStyles.bold16Black),
            SizedBox(height: 10),
            imagePath.isEmpty
                ? SizedBox.shrink()
                : Container(
                    height: 200,
                    width: 200,
                    child: CircleAvatar(
                      backgroundImage: FileImage(File(imagePath)),
                      radius: 20,
                    ),
                  ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                await getYourImage();
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
                        SvgPicture.asset('assets/icons/camera_g.svg'),
                        SizedBox(
                          width: 6,
                        ),
                        Text(LocaleKeys.selectImage.tr(), style: MTextStyles.medium12BrownishGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(LocaleKeys.otherId.tr(), style: MTextStyles.bold16Black),
            SizedBox(height: 16),
            Container(
              height: 54,
              // width: SizeConfig.screenWidth - 200,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: MColors.pinkish_grey, width: 1)),
              child: TextFormField(
                controller: controller,
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
            Container(
              decoration: BoxDecoration(
                color: MColors.tomato,
              ),
              child: Center(
                child: InkWell(
                  onTap: () {
                    if (controller.text.isEmpty || imagePath.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            LocaleKeys.error_contents.tr(),
                          ),
                        ),
                      );
                      return;
                    }
                    context.read<UserProvider>().setUser(name: controller.text, imagePath: imagePath);

                    Navigator.of(context).pop();
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

  Future getYourImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imagePath = pickedFile.path;
      } else {
        print('No image selected.');
      }
    });
  }
}
