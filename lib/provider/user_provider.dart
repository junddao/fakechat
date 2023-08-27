import 'package:fake_chat/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final List<User> users = [];

  void setUser({required String name, required String imagePath}) {
    User user = User(name: name, imagePath: imagePath);
    users.add(user);

    notifyListeners();
  }

  void setMy() {
    User user = User(name: 'rkWkcoxld', imagePath: '');
    users.add(user);
  }

  void removeUser(User user) {
    users.remove(user);

    notifyListeners();
  }
}
