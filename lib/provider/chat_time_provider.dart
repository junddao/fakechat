import 'package:fake_chat/models/chat_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatTimeProvider extends ChangeNotifier {
  ChatTime chatTime = ChatTime(pickedDate: DateTime.now(), time: TimeOfDay(hour: 8, minute: 0));

  void setTime(ChatTime _chatTime) {
    chatTime = _chatTime;

    notifyListeners();
  }
}
