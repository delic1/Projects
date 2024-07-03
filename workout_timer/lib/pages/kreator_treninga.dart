import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../classes/kreator_treninga_argumenti_class.dart';
import '../classes/trening_class.dart';

import '../classes/serija_class.dart';
import '../config/text_styles.dart';
import '../localization/locales.dart';
import '../widgets/serija_kartica.dart';

class TrainingCreator extends StatefulWidget {
  const TrainingCreator({super.key});

  @override
  State<TrainingCreator> createState() => _TrainingCreatorState();
}

class _TrainingCreatorState extends State<TrainingCreator> {
  final _controllerImeTreninga = TextEditingController();
  Serija? kopijaSerije;

  bool _validate = true;
  late String _imeTreninga;
  bool doOnce = true;

  List<Serija> serije = [];


  callBackSacuvajKopiranuSeriju(String name, Duration time,String reps, bool isTimed, bool isRest){
    setState(() {
      kopijaSerije ??= Serija();
      kopijaSerije?.setName(name);
      kopijaSerije?.setTime(time);
      kopijaSerije?.setReps(int.parse(reps));
      kopijaSerije?.setIsTimed(isTimed);
      kopijaSerije?.setIsRest(isRest);
    });
  }

  callBackMoveSerija(int dir, int index){
    Serija pomSerija = serije[index];
    if(dir == 0){
      setState(() {
        serije[index] = serije[index - 1];
        serije[index - 1] = pomSerija;
      });
      setState(() {

      });
    }else if(dir == 1){
      setState(() {
        serije[index] = serije[index + 1];
        serije[index + 1] = pomSerija;
      });
      setState(() {

      });
    }
  }

  setSerijaNameFromTextField(int index, String value){
    serije[index].setName(value);
  }
  setSerijaTimeFromPicker(int index, Duration value){
    serije[index].setTime(value);
  }
  setSerijaRepsFromTextField(int index, String value){
    serije[index].setReps(int.parse(value));
  }
  setSerijaIsTimedFromSwitch(int index, bool value){
      serije[index].setIsTimed(value);
  }
  callBackRemoveSerija(int index){
    serije.removeAt(index);
  }

  buildErrorMessage(String message) =>  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
        elevation: 10,
        showCloseIcon: true,
        backgroundColor: Colors.grey[800]!,
        content: Text(message),
        duration: const Duration(seconds: 3),
      )
  );

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as KreatorTreningaArguments;
    final Function callBackAddTrening = routeArgs.getCallBackAddTrening();
    final int index = routeArgs.getIndex();
    final Trening trening = routeArgs.getTrening();

    if(doOnce){
      doOnce = false;
      _imeTreninga = trening.getImeTreninga();
      for(int i = 0; i<trening.getSArr().length; i++){
        serije.add(Serija.copy(trening.getSArr()[i]));
      }
      _controllerImeTreninga.text = _imeTreninga;
      _validate = _controllerImeTreninga.text.isEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.grey[300],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Divider(
            thickness: 1.5,
            height: 0,
            color: Colors.grey[500],
          ),
        ),
        title: Text(
          LocaleData.createWorkout.getString(context),
          style: appBarTextStyle,
        ),
      ),
      body:Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: TextField(
                controller: _controllerImeTreninga,
                style: textFieldImeTreningaTextStyle,
                onChanged: (String value) {
                  setState(() {
                    _validate = _controllerImeTreninga.text.isEmpty;
                    _imeTreninga = value;
                  });
                },
                cursorColor: _validate ? Colors.red[900] : Colors.black,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1.5)),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3)), borderSide: BorderSide(color: Colors.black, width: 1)),
                  labelText: LocaleData.workoutName.getString(context),
                  labelStyle: _validate? TextStyle(color: Colors.red[900]) : const TextStyle(color: Colors.black),
                  errorText: _validate ? LocaleData.youMustProvideAName.getString(context) : null,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: serije.length,
                itemBuilder: (BuildContext context, int index) {
                  return SerijaCard(index: index, serija: serije[index], length: serije.length, callBackMoveSerija: callBackMoveSerija, callBackSacuvajKopiranuSeriju: callBackSacuvajKopiranuSeriju, setSerijaIsTimedFromSwitch: setSerijaIsTimedFromSwitch, setSerijaNameFromTextField: setSerijaNameFromTextField, setSerijaRepsFromTextField: setSerijaRepsFromTextField, setSerijaTimeFromPicker: setSerijaTimeFromPicker, callBackRemoveSerija: callBackRemoveSerija);
                }
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () {
                      if(_imeTreninga == ''){
                        buildErrorMessage(LocaleData.nameErrorMsg.getString(context));
                        return;
                      }
                      if(serije.isEmpty) {
                        buildErrorMessage(LocaleData.setErrorMsg.getString(context));
                        return;
                      }
                      for(int i = 0; i < serije.length; i++){
                        if(serije[i].getIsTimed() && serije[i].getTime() == Duration(seconds: 0)){
                          buildErrorMessage(LocaleData.timeErrorMsg.getString(context));
                          return;
                        }
                      }
                      callBackAddTrening(serije, _imeTreninga, index);
                      Navigator.pop(context);
                    },
                    child: Text(
                      LocaleData.save.getString(context),
                      style: trainingBottomButtonTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: Colors.grey[700],
                      thickness: 1,
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () {
                      setState(() {
                        serije.add(Serija.rest());
                      });
                    },
                    child: Text(
                      LocaleData.addRest.getString(context),
                      style: trainingBottomButtonTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: Colors.grey[700],
                      thickness: 1,
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () {
                      setState(() {
                        serije.add(Serija());
                      });
                    },
                    child: Text(
                      LocaleData.addExercise.getString(context),
                      style: trainingBottomButtonTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      color: Colors.grey[700],
                      thickness: 1,
                    ),
                  ),
                  TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                      ),
                    onPressed: () {
                      setState(() {
                        if(kopijaSerije != null){
                          serije.add(Serija.copy(kopijaSerije!));
                        }else{
                          buildErrorMessage(LocaleData.copyErrorMsg.getString(context));
                        }
                      });
                    },
                    child: Icon(Icons.paste, color: kopijaSerije == null ? Colors.grey : Colors.grey[900],)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
