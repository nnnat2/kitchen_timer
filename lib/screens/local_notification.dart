import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class LocalNotification {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  //bool _notificationsEnabled = false;

  Future<void> initNotification() async{

    // プラットフォームごとの初期設定
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('alarm_icon');
    // final DarwinInitializationSettings initializationSettingsDarwin =
    // DarwinInitializationSettings(
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        // iOS: initializationSettingsDarwin,
        );

    // 通知設定を初期化(先程の設定＋通知をタップしたときの処理)
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      // 通知をタップしたときの処理(今回はprint)
      // onDidReceiveNotificationResponse:
      //     (NotificationResponse notificationResponse) async{
      //   print('id=${notificationResponse.id}の通知に対してアクション。');
      // },
    );
  }


  

  Future<void> requestPermissions() async {

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // final bool? grantedNotificationPermission =
      await androidImplementation?.requestNotificationsPermission();
      // setState(() {
      //   _notificationsEnabled = grantedNotificationPermission ?? false;
      // });
    }
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('0', 'Kitchen Timer',
        // channelDescription: 'Timer App notification',
        importance: Importance.max,
        priority: Priority.high,
        // ticker: 'ticker'
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'タイマー終了', 'Timer Stop', notificationDetails,
        );
  }
}