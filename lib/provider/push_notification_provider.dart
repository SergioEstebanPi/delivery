import 'dart:convert';

import 'package:delivery/models/user.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class PushNotificationsProvider {

  late AndroidNotificationChannel channel;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initNotifications() async {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void onMessageListener(){
    // segundo plano
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('Nueva notificacion: $message');
      }
    });

    // permite recibir las notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  void saveToken(User user, BuildContext context) async {
    String? token = await FirebaseMessaging.instance.getToken();
    UsersProvider usersProvider = UsersProvider();
    usersProvider.init(context, sessionUser: user);
    usersProvider.updateNotificationToken(user.id!, token!);
  }

  Future<void> sendMessage(
      String to,
      Map<String, dynamic> data,
      String title,
      String body) async {

    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAkVnOtOA:APA91bEjk827bZKsHG0ajzPa6iosPXxumwuYGOEbcewTCNJN8BSvZUPanFtRIlgQcygE5c3noT6lnNKYAnY4H-0XDrYzcBy8b_IakZlQ5undGvN71znGXoxvIn1GtoM4NJ-TkBhcAJEP'
    };
    var bodyData = jsonEncode(
      <String, dynamic> {
        'notification': <String, dynamic> {
          'body': body,
          'title': title
        },
        'priority': 'high',
        'ttl': '4500s',
        'data': data,
        'to': to
      }
    );
    await http.post(uri,  headers: headers, body: bodyData);
  }

}