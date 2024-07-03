import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../classes/serija_class.dart';
import '../config/text_styles.dart';
import '../localization/locales.dart';

const boopSound = 'assets/boop.mp3';
const beepSound = 'assets/beep.mp3';

class PokreniTreningKartica extends StatefulWidget {
  const PokreniTreningKartica({Key? key, required this.serija, required this.isActive, required this.callBackNextActiveSerija, required this.isLast, required this.index, required this.activeIndex, required this.callBackTimeLeft,}) : super(key: key);

  final Serija serija;
  final int index;
  final bool isActive;
  final int activeIndex;
  final bool isLast;
  final Function callBackNextActiveSerija;
  final Function callBackTimeLeft;

  @override
  State<PokreniTreningKartica> createState() => _PokreniTreningKarticaState();
}

class _PokreniTreningKarticaState extends State<PokreniTreningKartica>{

  late double timeLeft = (widget.serija.getTime().inSeconds).toDouble();
  bool isCompleted = false;
  bool pause = false;
  bool isTimerActive = false;
  late bool isActive;
  bool doOnce = true;
  bool isBeforeReps = true;

  final player1 = AudioPlayer(handleAudioSessionActivation: false);
  final player2 = AudioPlayer(handleAudioSessionActivation: false);

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
      print("GRESKA PRI UCITAVANJU IZVORA: $e");
    }
    try {
      await player2.setAudioSource(AudioSource.asset(beepSound));
    } on PlayerException catch (e) {
      print("GRESKA PRI UCITAVANJU IZVORA: $e");
    }
  }

  _startTimer(){
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      isTimerActive = timer.isActive;
      if(pause){
        timer.cancel();
        isTimerActive = timer.isActive;
        return;
      }
      if(!widget.isActive){
        timer.cancel();
        isTimerActive = timer.isActive;
        return;
      }
      if(timeLeft <= 0) {
        timer.cancel();
        isTimerActive = timer.isActive;
        widget.callBackNextActiveSerija(true);
        return;
      }

      if(mounted){
        if(timeLeft == 3 || timeLeft == 2 || timeLeft == 1){
          player1.seek(Duration.zero);
          player1.play();
        }
        setState(() {
          timeLeft = timeLeft - 0.1;
          timeLeft = double.parse(timeLeft.toStringAsFixed(1));
          widget.callBackTimeLeft(timeLeft, (widget.serija.getTime().inSeconds).toDouble(), isBeforeReps);
        });
        if(timeLeft == 0){
          player2.seek(Duration.zero);
          player2.play();
        }
      }
    });
  }

  minutesTextOutput(){
    int timeLeftinMinutes = (timeLeft / 60).floor();
    return timeLeftinMinutes < 10 ? timeLeftinMinutes : timeLeftinMinutes;
  }

  secondsTextOutput(){
    return timeLeft % 60 < 10 ? (timeLeft % 60).floor() : (timeLeft % 60).floor();
  }

  buildTimerText(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.center,
          width: widget.activeIndex == widget.index ? 53 : 25,
          child: Text('${minutesTextOutput() ~/ 10}', style: widget.isActive ? pokreniTreningVremeVelikoTextStyle : pokreniTreningVremeTextStyle)
        ),
        Container(
            alignment: Alignment.center,
            width: widget.isActive ? 53 : 25,
            child: Text('${minutesTextOutput() % 10}', style: widget.isActive ? pokreniTreningVremeVelikoTextStyle : pokreniTreningVremeTextStyle)
        ),
        Container(
          alignment: Alignment.center,
          width: widget.isActive ? 15 : 7,
          child: Text(':', style: widget.isActive ? pokreniTreningVremeVelikoTextStyle : pokreniTreningVremeTextStyle),
        ),
        Container(
            alignment: Alignment.center,
            width: widget.isActive ? 53 : 25,
            child: Text('${secondsTextOutput() ~/ 10}', style: widget.isActive ? pokreniTreningVremeVelikoTextStyle : pokreniTreningVremeTextStyle)
        ),
        Container(
            alignment: Alignment.center,
            width: widget.isActive ? 53 : 25,
            child: Text('${secondsTextOutput() % 10}', style: widget.isActive ? pokreniTreningVremeVelikoTextStyle : pokreniTreningVremeTextStyle)
        ),
        Container(
            alignment: Alignment.center,
            width: widget.isActive ? 10 : 4,
            child: Text(".", style: widget.isActive ? pokreniTreningVremeMsVelikoTextStyle : pokreniTreningVremeMsTextStyle)
        ),
        Container(
          alignment: Alignment.centerLeft,
          width: widget.isActive ? 35 : 13,
          child: Text("${((timeLeft - timeLeft.truncate()) * 10).floor()}", style: widget.isActive ? pokreniTreningVremeMsVelikoTextStyle : pokreniTreningVremeMsTextStyle)
        )
      ],
    );
  }

  calculatePercentage(){
    late double beginTimeinSeconds = (widget.serija.getTime().inSeconds).toDouble();

    if(beginTimeinSeconds == 0){
      return 1.0;
    }
    return (beginTimeinSeconds - timeLeft) / beginTimeinSeconds;
  }

  buildControlsTimed() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.all(Colors.grey[350]),
            ),
            onPressed: (){
              timeLeft = (widget.serija.getTime().inSeconds).toDouble();
              widget.callBackTimeLeft(timeLeft, (widget.serija.getTime().inSeconds).toDouble(), isBeforeReps);
              setState(() {});
            },
            icon: Icon(
              Icons.replay,
              color: Colors.grey[900],
              size: 38,
            )
        ),
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: widget.index == 0 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
              splashFactory: widget.index == 0 ? NoSplash.splashFactory : InkSplash.splashFactory,
            ),
            onPressed: (){
              if(widget.index != 0){
                pause = true;
                widget.callBackNextActiveSerija(false);
              }
            },
            icon: Icon(
              Icons.skip_previous,
              color: widget.index == 0 ? Colors.grey : Colors.grey[900],
              size: 38,
            )
        ),
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.all(Colors.grey[350]),
            ),
            onPressed: (){
              if(widget.serija.getIsTimed()){
                setState(() {
                  pause = !pause;
                });
              }
            },
            icon: Icon(
              pause ? Icons.play_arrow : Icons.pause,
              color: Colors.grey[900],
              size: 38,
            )
        ),
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: widget.isLast ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
              splashFactory: widget.isLast ? NoSplash.splashFactory : InkSplash.splashFactory,
            ),
            onPressed: (){
              if(!widget.isLast){
                isCompleted = true;
                pause = true;
                widget.callBackNextActiveSerija(true);
              }
            },
            icon: Icon(
              Icons.skip_next,
              color: widget.isLast ? Colors.grey : Colors.grey[900],
              size: 38,
            )
        ),
      ],
    );
  }

  buildControlsReps(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: widget.index == 0 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
              splashFactory: widget.index == 0 ? NoSplash.splashFactory : InkSplash.splashFactory,
            ),
            onPressed: (){
              if(widget.index != 0){
                isBeforeReps = true;
                widget.callBackTimeLeft(0.0, -1.0, !isBeforeReps);
                doOnce = true;
                pause = true;
                widget.callBackNextActiveSerija(false);
              }
            },
            icon: Icon(
              Icons.skip_previous,
              color: widget.index == 0 ? Colors.grey : Colors.grey[900],
              size: 38,
            )
        ),
        IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: widget.isLast ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
              splashFactory: widget.isLast ? NoSplash.splashFactory : InkSplash.splashFactory,
            ),
            onPressed: (){
              if(!widget.isLast){
                doOnce = true;
                isCompleted = true;
                pause = true;
                widget.callBackNextActiveSerija(true);
              }
            },
            icon: Icon(
              Icons.skip_next,
              color: widget.isLast ? Colors.grey : Colors.grey[900],
              size: 38,
            )
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    if(!widget.serija.getIsTimed() && widget.isActive && doOnce){
      isCompleted = false;
      doOnce = false;
      isBeforeReps = false;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.callBackTimeLeft(0.0, -1.0, !isBeforeReps));
    }

    if(widget.serija.getIsTimed() && timeLeft <= 0 && !isTimerActive && widget.isActive && !widget.isLast){
      timeLeft = (widget.serija.getTime().inSeconds).toDouble();
    }

    if(widget.serija.getIsTimed() && widget.isActive && !isTimerActive) {
      if(!(widget.isLast && timeLeft <= 0)) {
        _startTimer();
      }
    }

    buildTimerIndicator() {
      return LinearPercentIndicator(
        barRadius: const Radius.circular(3),
        padding: EdgeInsets.zero,
        percent: calculatePercentage(),
        lineHeight: widget.isActive ? 300 : 60,
        progressColor: Colors.green,
        backgroundColor: Colors.grey[200],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.serija.getIsRest() ? LocaleData.rest.getString(context) : '${widget.serija.getName()}',
                  style: pokreniTreningNazivTextStyle,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 7,),
              Stack(
                alignment: Alignment.center,
                children: [
                  widget.serija.getIsTimed() ? buildTimerIndicator() : const SizedBox(),
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: widget.serija.getIsTimed() ? Colors.transparent : isCompleted ? Colors.blue : Colors.grey[200],
                      ),
                      height: widget.isActive ? 300 : 60,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    child: widget.serija.getIsTimed() ? buildTimerText() : Text(LocaleData.reps.getString(context) + ': ${widget.serija.getReps()}', style: pokreniTreningPonavljanjaTextStyle)
                  ),
                ],
              ),
              widget.isActive ? widget.serija.getIsTimed() ? buildControlsTimed() : buildControlsReps() : const SizedBox(height: 20),
            ],
          ),
        ),
        Divider(
          color: Colors.grey[300],
          height: 0,
          thickness: 0.8,
        )
      ],
    );
  }
}
