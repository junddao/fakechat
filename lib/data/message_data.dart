import 'dart:io';

import 'package:flutter/material.dart';

class MessageData {
  String? ids;
  File? image;
  String? message;
  bool? isMine;
  bool? deviderDate;
  TimeOfDay? t;
  MessageData({
    this.ids,
    this.image,
    this.message,
    this.isMine,
    this.deviderDate,
    this.t,
  });
}
