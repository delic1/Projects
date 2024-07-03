import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../classes/serija_class.dart';

import '../config/text_styles.dart';
import '../localization/locales.dart';

class SerijaCard extends StatefulWidget {
  const SerijaCard({Key? key, required this.index, required this.serija, required this.setSerijaNameFromTextField, required this.setSerijaRepsFromTextField, required this.setSerijaTimeFromPicker ,required this.callBackRemoveSerija, required this.setSerijaIsTimedFromSwitch, required this.callBackSacuvajKopiranuSeriju, required this.callBackMoveSerija, required this.length}) : super(key: key);

  final int index;
  final int length;
  final Serija serija;
  final Function callBackSacuvajKopiranuSeriju;
  final Function callBackMoveSerija;
  final Function setSerijaNameFromTextField;
  final Function setSerijaTimeFromPicker;
  final Function setSerijaRepsFromTextField;
  final Function setSerijaIsTimedFromSwitch;
  final Function callBackRemoveSerija;


  @override
  State<SerijaCard> createState() => _SerijaCardState();
}

class _SerijaCardState extends State<SerijaCard> {
  final _controllerImeSerije = TextEditingController();
  final _controllerBrojReps = TextEditingController();
  bool _isTimed = true;
  late String _name;
  String _reps = '0';
  Duration _time = const Duration(minutes: 0, seconds: 0);
  bool toggle = true;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 220,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  textOutput(){
    if(_time.inMinutes < 10){
      return _time.inSeconds % 60 < 10 ? '0${_time.inMinutes} : 0${_time.inSeconds % 60}' : '0${_time.inMinutes} : ${_time.inSeconds % 60}';
    }else{
      return _time.inSeconds % 60 < 10 ? '${_time.inMinutes} : 0${_time.inSeconds % 60}' : '${_time.inMinutes} : ${_time.inSeconds % 60}';
    }
  }

  buildToggleSwitch() =>
    Container(
      height: 40,
      margin: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[900]!,width: 1),
        borderRadius: BorderRadius.circular(3)
      ),
      child: Row(
        children: [
          TextButton(
            clipBehavior: Clip.none,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight:  Radius.circular(3),bottomRight: Radius.circular(3), topLeft:  Radius.circular(2.5),bottomLeft: Radius.circular(2.5)))),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(_isTimed ? Colors.grey[900] : Colors.white),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
            ),
            onPressed: (){
              setState(() {
                widget.setSerijaIsTimedFromSwitch(widget.index, true);
              });
            },
            child: Text(LocaleData.time.getString(context), style: _isTimed ? toggleSwitchTextStyle1 : toggleSwitchTextStyle2),
          ),
          TextButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3),topLeft: Radius.circular(3),bottomRight: Radius.circular(2.5),topRight: Radius.circular(2.5)))),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(_isTimed ? Colors.white : Colors.grey[900]),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory
            ),
            onPressed: (){
              setState(() {
                widget.setSerijaIsTimedFromSwitch(widget.index, false);
              });
            },
            child: Text(LocaleData.reps.getString(context), style: _isTimed ? toggleSwitchTextStyle2 : toggleSwitchTextStyle1),
          ),
        ],
      ),
    );


  buildTimerPicker() => Container(
    width: 117,
    height: 55,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
        onPressed: () => _showDialog(
            CupertinoTimerPicker(
              initialTimerDuration: _time,
              mode: CupertinoTimerPickerMode.ms,
              onTimerDurationChanged: (Duration value) {
              setState(() {
              _time = value;
              widget.setSerijaTimeFromPicker(widget.index, _time);
              });
              },
            ),
        ),
        child: Text(
          textOutput(),
          style: _time == Duration(seconds: 0) ? invalidTimerButtonTextStyle : timerButtonTextStyle,
        )
    ),
  );

  buildRepsTextField() => SizedBox(
    width: 117,
    height: 55,
    child: TextField(
      textAlign: TextAlign.center,
      controller: _controllerBrojReps,
      style: textFieldRepsTextStyle,
      onChanged: (String value) {
        if(value == '') value = '0';
        _reps = value;
        widget.setSerijaRepsFromTextField(widget.index, _reps);
      },
      keyboardType: TextInputType.number,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1.5)),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1)),
        labelText: LocaleData.repCount.getString(context),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: textFieldLabelTextStyle,
        hintText: '  0',
      ),
    ),
  );

  buildEcerciseCard(){
    String kopiraj = 'kopiraj';
    String obrisi = 'obrisi';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          controller: _controllerImeSerije,
                          style: textFieldImeVezbeTextStyle,
                          maxLines: 1,
                          onChanged: (String value) {
                            _name = value;
                            widget.setSerijaNameFromTextField(widget.index, _name);
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1.5)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1)),
                            labelText: LocaleData.exerciseName.getString(context),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: widget.index == 0 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
                        splashFactory: widget.index == 0 ? NoSplash.splashFactory : InkSplash.splashFactory,
                      ),
                      onPressed: (){
                        if(widget.index == 0){
                          return;
                        }else{
                          widget.callBackMoveSerija(0, widget.index);
                        }
                      },
                      icon: Icon(Icons.arrow_upward, color: widget.index == 0 ? Colors.grey : Colors.grey[900],),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: widget.index == widget.length - 1 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
                        splashFactory: widget.index == widget.length - 1 ? NoSplash.splashFactory : InkSplash.splashFactory,
                      ),
                      onPressed: (){
                        if(widget.index == widget.length - 1){
                          return;
                        }else{
                          widget.callBackMoveSerija(1, widget.index);
                        }
                      },
                      icon: Icon(Icons.arrow_downward, color: widget.index == widget.length - 1 ? Colors.grey : Colors.grey[900],),
                    )
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isTimed ? buildTimerPicker() : buildRepsTextField(),
                    buildToggleSwitch(),
                    PopupMenuButton(
                      iconColor: Colors.grey[900],
                      color: Colors.white,
                      elevation: 1,
                      onSelected: (String item) {
                        if(item == kopiraj){
                          widget.callBackSacuvajKopiranuSeriju(_name, _time, _reps, _isTimed, false);
                        }else if(item == obrisi){
                          widget.callBackRemoveSerija(widget.index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: kopiraj,
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 18, color: Colors.grey[800],),
                                const SizedBox(width: 5,),
                                Text(LocaleData.copy.getString(context), style: popupMeniTextStyle),
                              ],
                            )
                        ),
                        PopupMenuItem(
                            value: obrisi,
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.grey[800],),
                                const SizedBox(width: 5,),
                                Text(LocaleData.delete.getString(context) ,style: popupMeniTextStyle),
                              ],
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[300],
            height: 15,
            thickness: 0.8,
          )
        ],
      ),
    );
  }

  buildRestCard(){
    String kopiraj = 'kopiraj';
    String obrisi = 'obrisi';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 7, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleData.rest.getString(context),
                        style: restSerijaKarticaTextStyle
                      ),
                    ),
                    Expanded(child: buildTimerPicker()),
                    IconButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: widget.index == 0 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
                        splashFactory: widget.index == 0 ? NoSplash.splashFactory : InkSplash.splashFactory,
                      ),
                      onPressed: (){
                        if(widget.index == 0){
                          return;
                        }else{
                          widget.callBackMoveSerija(0, widget.index);
                        }
                      },
                      icon: Icon(Icons.arrow_upward, color: widget.index == 0 ? Colors.grey : Colors.grey[900],),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: widget.index == widget.length - 1 ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
                        splashFactory: widget.index == widget.length - 1 ? NoSplash.splashFactory : InkSplash.splashFactory,
                      ),
                      onPressed: (){
                        if(widget.index == widget.length - 1){
                          return;
                        }else{
                          widget.callBackMoveSerija(1, widget.index);
                        }
                      },
                      icon: Icon(Icons.arrow_downward, color: widget.index == widget.length - 1 ? Colors.grey : Colors.grey[900],),
                    ),
                    PopupMenuButton(
                      iconColor: Colors.grey[900],
                      color: Colors.white,
                      elevation: 1,
                      onSelected: (String item) {
                        if(item == kopiraj){
                          widget.callBackSacuvajKopiranuSeriju(_name, _time, _reps, _isTimed, true);
                        }else if(item == obrisi){
                          widget.callBackRemoveSerija(widget.index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: kopiraj,
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 18, color: Colors.grey[800],),
                                const SizedBox(width: 5,),
                                Text(LocaleData.copy.getString(context), style: popupMeniTextStyle),
                              ],
                            )
                        ),
                        PopupMenuItem(
                            value: obrisi,
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.grey[800],),
                                const SizedBox(width: 5,),
                                Text(LocaleData.delete.getString(context) ,style: popupMeniTextStyle),
                              ],
                            )
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 13),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[300],
            height: 15,
            thickness: 0.8,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    _isTimed = widget.serija.getIsTimed();
    _name = widget.serija.getName();
    _reps = widget.serija.getReps().toString();
    _time = widget.serija.getTime();
    _controllerImeSerije.text = _name;

    return widget.serija.getIsRest() ? buildRestCard() :buildEcerciseCard();
  }
}
