// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_notification.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TimerInfomation timerInfomation = TimerInfomation(
    countTimerTime: Timer(Duration.zero, () {}),
    timerDateTime: DateTime.utc(0, 0, 0),
    firstTimerTime: DateTime.utc(0, 0, 0),
    saveDateString: '00',
    pauseTime: DateTime.utc(0, 0, 0),
    isActive: false,
  );

  List<TimerInfomation> _timers = [];
  int _timerCount = 1;

  bool _switchValue = true;
  bool _isDisabledButton = false;

  late AudioPlayer _audioPlayer;
  bool _isSoundPlaying = false;

  late final controller = SlidableController(this);

  late final _controllers = List<AnimationController>.generate(
    6,
    (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    // _loadAudio();

    _loadAllFirstTime();
    _loadBool();
    LocalNotification().requestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in _controllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
    ;
  }

  void _pauseTimer() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive) {
        _timers[i].pauseTime = DateTime.now();
      }
    }
  }

  void _resumeTimer() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive) {
        final pausedDuration = DateTime.now().difference(_timers[i].pauseTime);
        setState(() {
          _timers[i].timerDateTime = _timers[i]
              .timerDateTime
              .add(Duration(seconds: -pausedDuration.inSeconds));
        });
        _startTimer(i);
      }
    }
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
      if (_timers.length < 6) {
        _timers.add(TimerInfomation(
          countTimerTime: Timer(Duration.zero, () {}),
          timerDateTime: DateTime.utc(0, 0, 0),
          firstTimerTime: DateTime.utc(0, 0, 0),
          saveDateString: '00',
          pauseTime: DateTime.utc(0, 0, 0),
          isActive: false,
        ));
        _timerCount = _timers.length;
        _saveTimerCount();
      }
    });
  }

  void _startTimer(int index) {
    _timers[index].isActive = true;
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

  Future<void> _timeEnd(int index) async {
    if (_timers[index].timerDateTime == DateTime.utc(0, 0, 0)) {
      _controllers[index].reverse();
      _timers[index].countTimerTime.cancel();
      _timers[index].isActive = false;
      await LocalNotification().showNotification();
      await _playSound();
    }
  }

  Future<void> _playSound() async {
    if (_switchValue == true) {
      await _audioPlayer.setAsset('assets/sounds/ktimer.mp3');
      if (_isSoundPlaying) {
        await _audioPlayer.stop();
        await _audioPlayer.play();
      } else {
        await _audioPlayer.play();
      }
    }
    setState(() {
      _isSoundPlaying = true;
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isSoundPlaying = false;
        });
      }
    });
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
    });
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

  Future<void> _loadDateTime(
      List<TimerInfomation> tempTimers, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDateString = prefs.getString('timer_$index');
    if (savedDateString != null) {
      tempTimers[index].saveDateString = savedDateString;
      tempTimers[index].firstTimerTime = DateTime.parse(savedDateString);
      tempTimers[index].timerDateTime = tempTimers[index].firstTimerTime;
    }
  }

  Future<void> _loadAllFirstTime() async {
    await _loadTimerCount();

    List<TimerInfomation> tempTimers = List.generate(
      _timerCount,
      (index) => TimerInfomation(
        countTimerTime: Timer(Duration.zero, () {}),
        timerDateTime: DateTime.utc(0, 0, 0),
        firstTimerTime: DateTime.utc(0, 0, 0),
        saveDateString: '00',
        pauseTime: DateTime.utc(0, 0, 0),
        isActive: false,
      ),
    );

    for (int i = 0; i < tempTimers.length; i++) {
      await _loadDateTime(tempTimers, i);
    }

    setState(() {
      _timers = tempTimers;
    });
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
                    return Slidable(
                      key: UniqueKey(),
                      endActionPane: ActionPane(
                        extentRatio: 0.2,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              setState(() {
                                _timers.removeAt(index);
                              });
                            },
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Row(
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
                      ),
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
  late DateTime firstTimerTime;
  late DateTime pauseTime;
  late DateTime timerDateTime;
  String saveDateString = '00';
  bool isActive = false;

  TimerInfomation({
    required this.countTimerTime,
    required this.timerDateTime,
    required this.firstTimerTime,
    required this.saveDateString,
    required this.pauseTime,
    required this.isActive,
  });
}
