import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../classes/trening_class.dart';


import '../classes/kreator_treninga_argumenti_class.dart';
import '../classes/serija_class.dart';
import '../config/text_styles.dart';
import '../localization/locales.dart';

class TrainingCard extends StatefulWidget {
  const TrainingCard({Key? key, required this.index, required this.callBackRemoveTrening, required this.trening, required this.callBackAddTrening, required this.callBackShareFile}) : super(key: key);

  final int index;
  final Function callBackRemoveTrening;
  final Function callBackAddTrening;
  final Function callBackShareFile;
  final Trening trening;

  @override
  State<TrainingCard> createState() => _TrainingCardState();
}

class _TrainingCardState extends State<TrainingCard> {
  String izmeni = 'izmeni';
  String obrisi = 'obrisi';
  String podeli = 'podeli';

  buildDialog() => Dialog(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              LocaleData.areYouSureMsg.getString(context),
            style: dialogTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  widget.callBackRemoveTrening(widget.index);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                child: Text(
                  LocaleData.yes.getString(context),
                  style: dialogTextStyle,
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
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                ),
                child: Text(
                  LocaleData.no.getString(context),
                  style: dialogTextStyle,
                ),
              )
            ],
          ),
        ],
      ),
    ),
  );

  timeAndRepsText(){
    List<Serija> s = widget.trening.getSArr();
    Duration timeSum = Duration(seconds: 0);
    num repsSum = 0;
    for(int i = 0; i < s.length; i++){
     if(s[i].getIsTimed()){
       timeSum += s[i].getTime();
     }else{
       if(s[i].getReps() != null){
         repsSum += s[i].getReps();
       }
     }
    }
    return '${timeSum.inMinutes} min ${timeSum.inSeconds % 60} sec + $repsSum ${LocaleData.reps.getString(context)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/trening', arguments: {'trening' : widget.trening});
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.trening.getImeTreninga()}",
                          style: treningKarticaTitleTextStyle,
                          maxLines: 1,

                        ),
                        Text(
                          timeAndRepsText(),
                          style: timeAndRepsTextStyle,
                          maxLines: 1,

                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    color: Colors.white,
                    elevation: 1,
                    onSelected: (String item) {
                      if(item == izmeni){
                        Navigator.pushNamed(context, '/creator', arguments: KreatorTreningaArguments(widget.callBackAddTrening, widget.trening, widget.index));
                      }else if(item == obrisi){
                        showDialog(context: context, builder: (BuildContext context) => buildDialog());
                      }else if(item == podeli){
                        widget.callBackShareFile(widget.index);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: izmeni,
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.grey[800],),
                            const SizedBox(width: 5),
                            Text(LocaleData.edit.getString(context), style: popupMeniTextStyle),
                          ],
                        )
                      ),
                      PopupMenuItem(
                        value: obrisi,
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.grey[800],),
                            const SizedBox(width: 5),
                            Text(LocaleData.delete.getString(context), style: popupMeniTextStyle),
                          ],
                        )
                      ),
                      PopupMenuItem(
                          value: podeli,
                          child: Row(
                            children: [
                              Icon(Icons.share, size: 18, color: Colors.grey[800],),
                              const SizedBox(width: 5),
                              Text(LocaleData.share.getString(context), style: popupMeniTextStyle),
                            ],
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[300],
              height: 1,
              thickness: 0.8,
            )
          ],
        ),
      ),
    );
  }
}