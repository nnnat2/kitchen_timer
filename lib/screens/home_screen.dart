// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_notification.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TimerInfomation timerInfomation = TimerInfomation(
    countTimerTime: Timer(Duration.zero, () {}),
    timerDateTime: DateTime.utc(0, 0, 0),
    firstTimerTime: DateTime.utc(0, 0, 0),
    saveDateString: '00',
  );

  List<TimerInfomation> _timers = [];
  int _timerCount = 1;

  // late DateTime _firstTimerTimeCommon;
  // String _saveDateStringCommon = '00';

  bool _switchValue = true;
  bool _isDisabledButton = false;

  late AudioPlayer _audioPlayer;



  late final _controllers = List<AnimationController>.generate(
    5,
    (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ),
  );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();

    _loadAllFirstTime();
    _loadBool();
    LocalNotification().requestPermissions();
    // player.setReleaseMode(ReleaseMode.release);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
    //_countDownTimeCommon?.cancel();
  }

  void _displayPicker(BuildContext context, int index) {
    Picker(
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kHMS,
        value: _timers[index].timerDateTime,
        customColumnType: [3, 4, 5],
      ),
      confirmText: "OK",
      selectedTextStyle: TextStyle(color: Colors.green),
      onConfirm: (Picker picker, List value) {
        setState(() {
          _timers[index].timerDateTime =
              DateTime.utc(0, 0, 0, value[0], value[1], value[2]);
        });
        _timers[index].firstTimerTime = _timers[index].timerDateTime;
        _saveDateTime(index);
      },
    ).showModal(context);
  }

  void _addTimer() {
    setState(() {
      if (_timers.length < 5) {
        _timers.add(TimerInfomation(
          countTimerTime: Timer(Duration.zero, () {}),
          timerDateTime: DateTime.utc(0, 0, 0),
          firstTimerTime: DateTime.utc(0, 0, 0),
          saveDateString: '00',
        ));
        _timerCount = _timers.length;
        _saveTimerCount();
      }
    });
  }

  void _startTimer(int index) {
    _timers[index].countTimerTime = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          _timers[index].timerDateTime =
              _timers[index].timerDateTime.add(Duration(seconds: -1));
          _timeEnd(index);
        });
      },
    );
  }

  void _timeEnd(int index) {

    if (_timers[index].timerDateTime == DateTime.utc(0, 0, 0)) {
      LocalNotification().showNotification();
      _playSound();
      _controllers[index].reverse();
      _timers[index].countTimerTime.cancel();
    }
  }

  Future<void> _playSound() async{
    if (_switchValue == true) {
     await _audioPlayer.play();
    }
}

  void _buttonDelay() async {
    _isDisabledButton = true;
    await Future.delayed(
      Duration(seconds: 1),
    );
    _isDisabledButton = false;
  }

  void _resetButton(int index) {
    setState(() {
      _timers[index].timerDateTime = _timers[index].firstTimerTime;
      // var firstTimerTime = _timers[index].firstTimerTime;
      // _timers[index].firstTimerTime = firstTimerTime;
    });
  }

  Future<void> _loadAudio() async {
    await _audioPlayer.setAsset('assets/sounds/ktimer.mp3');
  }

  Future<void> _saveTimerCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timer_count', _timerCount);
  }

  Future<void> _loadTimerCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _timerCount = prefs.getInt('timer_count') ?? 1;
  }

  Future<void> _saveDateTime(int index) async {
    _timers[index].saveDateString = _timers[index].firstTimerTime.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('timer_$index', _timers[index].saveDateString);
  }

  Future<void> _loadDateTime(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _timers[index].saveDateString = prefs.getString('timer_$index') ?? '00:00:30';
    _timers[index].firstTimerTime =
        DateTime.parse(_timers[index].saveDateString);
    _timers[index].timerDateTime = _timers[index].firstTimerTime;
    setState(() {});
  }

  Future<void> _loadAllFirstTime() async {
    await _loadTimerCount();
    _timers = List.generate(_timerCount, (index) => TimerInfomation(
        countTimerTime: Timer(Duration.zero, () {}),
        timerDateTime: DateTime.utc(0, 0, 0),
        firstTimerTime: DateTime.utc(0, 0, 0),
        saveDateString: '00',
    ),
    );
    for (int i = 0; i < 5; i++) {
      await _loadDateTime(i);
    }
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
                child: ListView.builder(
                  itemCount: _timers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => _displayPicker(context, index),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: 60),
                          ),
                          child: Text(DateFormat.Hms()
                              .format(_timers[index].timerDateTime)),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 65,
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _controllers[index],
                            ),
                            onPressed: () {
                              if (_timers[index].timerDateTime !=
                                      DateTime.utc(0, 0, 0) &&
                                  _isDisabledButton == false) {
                                if (_controllers[index].isCompleted) {
                                  _controllers[index].reverse();
                                  _timers[index].countTimerTime.cancel();
                                  _buttonDelay();
                                } else {
                                  _controllers[index].forward();
                                  _startTimer(index);
                                  _buttonDelay();
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 30,
                            icon: Icon(Icons.replay),
                            onPressed: () => _resetButton(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 40,
                  onPressed: _addTimer,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: SwitchListTile(
                  activeColor: Color(0xFF00a257),
                  title: Text(
                    "アラームサウンドを有効",
                    style: TextStyle(
                        color: Colors.black, fontFamily: "M_PLUS_1p_2"),
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

class TimerInfomation {
  late Timer countTimerTime;
  DateTime timerDateTime = DateTime.utc(0, 0, 0);

  late DateTime firstTimerTime;
  String saveDateString = '00';

  TimerInfomation({
    required this.countTimerTime,
    required this.timerDateTime,
    required this.firstTimerTime,
    required this.saveDateString,
  });
}
