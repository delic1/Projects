import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:just_audio/just_audio.dart';
import '../classes/trening_class.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../classes/serija_class.dart';
import '../config/text_styles.dart';
import '../localization/locales.dart';
import '../widgets/pokreni_trening_kartica.dart';

const boopSound = 'assets/boop.mp3';
const beepSound = 'assets/beep.mp3';

class PokreniTrening extends StatefulWidget {
  const PokreniTrening({Key? key}) : super(key: key);

  @override
  State<PokreniTrening> createState() => _PokreniTreningState();
}

class _PokreniTreningState extends State<PokreniTrening> {
  int activeSerija = -1;
  bool start = false;
  int timeToStart = 5;
  late int serijeLength;
  late List<double> timeElapsedList;
  bool doOnce = true;

  final _controller = ScrollController();

  final player1 = AudioPlayer(handleAudioSessionActivation: false);
  final player2 = AudioPlayer(handleAudioSessionActivation: false);

  late double heightOfTimeInterval;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    player1.dispose();
    super.dispose();
  }

  Future<void> _init()async {
    try {
      await player1.setAudioSource(AudioSource.asset(boopSound));
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
    try {
      await player2.setAudioSource(AudioSource.asset(beepSound));
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
  }

  callBackTimeLeft(double timeLeft, double startTime, bool isActive){
    double timeElapsed = startTime - timeLeft;
    if(timeElapsed == -1){
      if(isActive == false){
        setState(() {
          timeElapsedList[activeSerija] = 0.0;
        });
        return;
      }
      double bodyWidth = MediaQuery.of(context).size.width - (serijeLength - 1) * 1;
      timeElapsed = bodyWidth / (serijeLength * heightOfTimeInterval);
      setState(() {
        //negativna vrednost znaci da je tip serije reps
        timeElapsedList[activeSerija] = -timeElapsed;
      });
    }else{
      setState(() {
        timeElapsedList[activeSerija] = timeElapsed;
      });
    }
  }

  callBackNextActiveSerija(bool dir){
    setState(() {
      if(dir){
        activeSerija++;
      }
      else{
        activeSerija--;
      }
      if(activeSerija < 0){
        activeSerija = 0;
      }
      if(activeSerija >= serijeLength){
        activeSerija = serijeLength - 1;
      }
    });

    if(activeSerija != 0){
      _controller.animateTo(
          clampDouble((activeSerija - 1) * 125, 0, _controller.position.maxScrollExtent),
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut
      );
    }
  }

  buildStartDialog() {
    timeToStart = 5;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState){
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(LocaleData.timeUntilWorkoutStart.getString(context), style: vremeDoPocetkaTextStyle, textAlign: TextAlign.center,),
              IconButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                onPressed: () {
                  setState(() {
                    timeToStart += 5;
                    if (timeToStart > 30) {
                      timeToStart = 30;
                    }
                  });
                },
                icon: const Icon(Icons.arrow_drop_up_sharp, size: 55, color: Colors.white,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$timeToStart', style: startTimeTextStyle),
                  Text('s', style: sTextStyle)
                ],
              ),
              IconButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                onPressed: () {
                  setState(() {
                    timeToStart -= 5;
                    if (timeToStart < 5) {
                      timeToStart = 5;
                    }
                  });
                },
                icon: const Icon(Icons.arrow_drop_down_sharp, size: 55, color: Colors.white,),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(barrierDismissible: false, context: context, builder: (BuildContext context) => buildStartTimerDialog());
                },
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Text(LocaleData.start.getString(context), style: pokreniButtonTextStyle,),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildStartTimerDialog(){
    bool doOnce = true;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState){

        startTimer(){
          Timer.periodic(const Duration(seconds: 1), (timer) {
            if(timeToStart <= 0) {
              timer.cancel();
              Navigator.pop(context);
              setState(() {
                start = true;
                activeSerija = 0;
                WakelockPlus.enable();
                _controller.animateTo(
                    0,
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeInOutCubic
                );
              });
              return;
            }
            if(mounted){
              setState(() {
                timeToStart--;
              });
              if(timeToStart == 3 || timeToStart == 2 || timeToStart == 1){
                player1.seek(Duration.zero);
                player1.play();
              }
              if(timeToStart == 0){
                player2.seek(Duration.zero);
                player2.play();
              }
            }
          });
        }

        if(doOnce){
          doOnce = false;
          startTimer();
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$timeToStart', style: startTimeTextStyle),
              Text('s', style: sTextStyle)
            ],
          ),
        );
      },
    );
  }

  calculateSumTime(List<Serija> s){
    Duration timeSum = Duration(seconds: 0);
    for(int i = 0; i < s.length; i++){
      if(s[i].getIsTimed()){
        timeSum += s[i].getTime();
      }
    }
    return timeSum.inSeconds == 0 ? 1 : timeSum.inSeconds;
  }

  calculateNumOfRepExercises(List<Serija> s){
    int numOfRepExercises = 0;
    for(int i = 0; i < s.length; i++){
      if(!s[i].getIsTimed()){
        numOfRepExercises++;
      }
    }
    return numOfRepExercises;
  }


  buildSumTimer(double heightOfTimeInterval, double timeElapsed){
    return Row(
      children: [
        Container(
          height: 1000,
          width: heightOfTimeInterval * timeElapsed.abs(),
          color: timeElapsed < 0 ? Colors.blue : Colors.green,
        ),
        SizedBox(width: heightOfTimeInterval * timeElapsed.abs() == 0 ?  0 : 1, height: 10,)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, Trening>;
    final Trening? trening = routeArgs['trening'];
    List<Serija> s = trening?.getSArr();
    serijeLength = s.length;

    if(doOnce){
      timeElapsedList = List<double>.filled(serijeLength, 0, growable: false);
      doOnce = false;
    }

    //velicina jedne desetine sekunde na brojacu ukupnog vremena sa strane.
    //bodyWidth = ukupna sirina ekrana - razmaci izmedju intervala sem poslednjeg(s.length - 1)
    //Jednak je: (bodyWidth - brojRepExc * velicina jednog intervala proporcionalno sa brojem svih vezbi) / (ukupan broj sekundi)
    double bodyWidth = MediaQuery.of(context).size.width - (s.length - 1) * 1;
    heightOfTimeInterval = (bodyWidth - calculateNumOfRepExercises(s) * (bodyWidth / s.length)) / (calculateSumTime(s));
    if(heightOfTimeInterval == 0) heightOfTimeInterval = 1;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        actions: [
          if (!start) Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
              onPressed: (){
                if(kDebugMode){
                  setState(() {
                    start = true;
                    activeSerija = 0;
                    WakelockPlus.enable();
                    _controller.animateTo(
                        0,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOutCubic
                    );
                  });
                }else{
                  showDialog(context: context, builder: (BuildContext context) => buildStartDialog());
                }
              },
              child: Text(LocaleData.start.getString(context), style: pokreniAppBarButtonTextStyle)),
          ) else Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                onPressed: (){
                  WakelockPlus.disable();
                  Navigator.pop(context);
                },
                child: Text(LocaleData.finish.getString(context), style: pokreniAppBarButtonTextStyle)),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            thickness: 1.5,
            height: 0,
            color: Colors.grey[500],
          ),
        ),
        backgroundColor: Colors.grey[300],
        title: Text(
          trening?.getImeTreninga(),
          style: appBarTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                  controller: _controller,
                  itemCount: serijeLength,
                itemBuilder: (BuildContext context, int index) => PokreniTreningKartica(serija: s[index],index: index,activeIndex: activeSerija, isActive: index == activeSerija,isLast: index == s.length - 1, callBackNextActiveSerija: callBackNextActiveSerija, callBackTimeLeft: callBackTimeLeft,)
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey[500]!,width: 1.5)),
              color: Colors.grey[200],
            ),
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              itemCount: serijeLength,
                itemBuilder: (BuildContext context, int index) => buildSumTimer(heightOfTimeInterval, timeElapsedList[index])
            ),
          ),
        ],
      ),
    );
  }
}
