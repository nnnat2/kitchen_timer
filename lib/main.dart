import 'package:flutter/material.dart';
import 'package:kitchen_timer_app/screens/home_screen.dart';
import 'package:kitchen_timer_app/screens/local_notification.dart';

// void main() => runApp(MyApp());

void main() async {

  //Widget等の初期化を明示的に行う?
  WidgetsFlutterBinding.ensureInitialized();

  // NotificationControllerの初期化
  await LocalNotification().initNotification();

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "キッチンタイマーEASY",
      //theme: ThemeData.dark(),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF00a257),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 30,
          ),
          elevation: 4,
          centerTitle: true,
        ),
      ),
    );
  }
}
