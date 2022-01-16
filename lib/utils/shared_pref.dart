import 'dart:convert';

import 'package:delivery/provider/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  void save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    String? value = prefs.getString(key);
    if(value == null) {
      return null;
    } else {
      return json.decode(value);
    }
  }

  Future<dynamic> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  void logout(BuildContext context, {String? idUser}) async {
    UsersProvider usersProvider = UsersProvider();
    usersProvider.init(context);
    await usersProvider.logout(idUser!);
    await remove('user');
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

}