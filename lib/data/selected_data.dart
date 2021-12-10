import 'dart:io';

import 'package:flutter/material.dart';

class SelectedData {
  DateTime? pickedDate;
  TimeOfDay? time;
  String? myId;
  List<String>? yourId;
  // File myImage;
  List<File>? yourImage;
  SelectedData({
    this.pickedDate,
    this.time,
    this.myId,
    this.yourId,
    // this.myImage,
    this.yourImage,
  });
}
