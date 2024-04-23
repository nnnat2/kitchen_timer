// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_notification.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DateTime _timerTime = DateTime.utc(0, 0, 0);
  late DateTime _firstTimerTime;
  Timer? _countDownTime;
  bool _isDisabledButton = false;
  String _saveDateString = '00';
  bool _switchValue = true;

  final player = AudioPlayer();


  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  // bool _notificationsEnabled = false;

  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _loadDateTime();
    _loadBool();
    LocalNotification().requestPermissions();
    player.setReleaseMode(ReleaseMode.release);

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _countDownTime?.cancel();
  }

  void _displayPicker() {
    Picker(
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kHMS,
        value: _timerTime,
        customColumnType: [3, 4, 5],
      ),
      confirmText: "OK",
      selectedTextStyle: TextStyle(color: Colors.cyan),
      onConfirm: (Picker picker, List value) {
        setState(() {
          _timerTime = DateTime.utc(0, 0, 0, value[0], value[1], value[2]);
        });
        _firstTimerTime = _timerTime;
        _saveDateTime();
      },
    ).showModal(context);
  }

  void _startTimer() {
    _countDownTime = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          _timerTime = _timerTime.add(Duration(seconds: -1));
          _timeEnd();
        });
      },
    );
  }

  void _timeEnd() {
    if (_countDownTime != null && _timerTime == DateTime.utc(0, 0, 0)) {
      LocalNotification().showNotification();
      if (_switchValue == true){
        player.play (AssetSource("ktimer.mp3"));
      }
      _controller.reverse();
      _countDownTime?.cancel();
    }
  }

  void _buttonDelay() async {
    _isDisabledButton = true;
    await Future.delayed(
      Duration(seconds: 1),
    );
    _isDisabledButton = false;
  }

  void _resetButton() {
    setState(() {
      _timerTime = _firstTimerTime;
    });
  }

  void _saveDateTime() async {
    _saveDateString = _firstTimerTime.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('dateTime', _saveDateString);
  }

  void _loadDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _saveDateString = prefs.getString('dateTime') ?? '00:00:30';
    _firstTimerTime = DateTime.parse(_saveDateString);
    _timerTime = _firstTimerTime;
    setState(() {});
  }

  void _saveBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('bool', _switchValue);
  }

  void _loadBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _switchValue = prefs.getBool('bool') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: _displayPicker,
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: 60),
                          ),
                          child: Text(DateFormat.Hms().format(_timerTime)),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 65,
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _controller,
                            ),
                            onPressed: () {
                              if (_timerTime != DateTime.utc(0, 0, 0) &&
                                  _isDisabledButton == false) {
                                if (_controller.isCompleted) {
                                  _controller.reverse();
                                  _countDownTime?.cancel();
                                  _buttonDelay();
                                } else {
                                  _controller.forward();
                                  _startTimer();
                                  _buttonDelay();
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 30  ,
                            icon: Icon(Icons.replay),
                            onPressed: _resetButton,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: SwitchListTile(
                  activeColor: Color(0xFF00a257),
                  title: Text("アラームサウンドを有効",
                  style: TextStyle(color: Colors.black, fontFamily: "M_PLUS_1p_2"),
                  ),
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() => _switchValue = value);
                    _saveBool();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          title: Text(
            "キッチンタイマーEASY",
            style: TextStyle(color: Colors.black, fontFamily: "M_PLUS_1p"),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          toolbarHeight: 125,
        ),
      ),
    );
  }
}
