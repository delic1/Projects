import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import '../classes/kreator_treninga_argumenti_class.dart';
import '../classes/treninzi_class.dart';
import '../localization/locales.dart';

import '../classes/serija_class.dart';
import '../classes/trening_class.dart';
import '../config/text_styles.dart';
import '../widgets/trening_kartica.dart';

Treninzi treninzi = Treninzi();

class Home extends StatefulWidget {
  const Home({super.key,});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late File jsonFile;
  late Directory dir;
  String fileName = "myFile.json";
  bool fileExists = false;
  late Map<String, dynamic> fileContent;
  late FlutterLocalization _flutterLocalization;

  late String _currentLocale;

  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File("${dir.path}/$fileName");
      fileExists = jsonFile.existsSync();
      if (fileExists){
        setState(() {
          fileContent = json.decode(jsonFile.readAsStringSync());
          treninzi = Treninzi.fromJson(fileContent);
        });
      }
    });

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((sharedFileList) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(sharedFileList);

        if(!sharedFileList.isEmpty){
          File? f = File(sharedFileList.first.path);
          showDialog(context: context, builder: (BuildContext context) => buildImporter(f));
        }
      });
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFileList) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(sharedFileList);

        if(!sharedFileList.isEmpty){
          File? f = File(sharedFileList.first.path);
          showDialog(context: context, builder: (BuildContext context) => buildImporter(f));
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  void _setLocale(String? value) {
    if (value == null) return;
    if (value == "en") {
      _flutterLocalization.translate("en");
    }else if (value == "sr") {
      _flutterLocalization.translate("sr");
    }else {
      return;
    }
    setState(() {
      _currentLocale = value;
    });
  }

  void createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    File file = File("${dir.path}/$fileName");
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void writeToFile(Map<String, dynamic> content) {
    if (fileExists) {
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      createFile(content, dir, fileName);
    }
    fileContent = json.decode(jsonFile.readAsStringSync());
  }

  callBackShareFile(int index) async {
    Map<String, dynamic> jsonShareFileContent = treninzi.treninzi[index].toJson();
    File shareFile = File('${dir.path}/${treninzi.treninzi[index].getImeTreninga()}.json');
    shareFile.writeAsStringSync(json.encode(jsonShareFileContent));

    await Share.shareXFiles([XFile('${dir.path}/${treninzi.treninzi[index].getImeTreninga()}.json')],text: 'Workout timer :)');
  }

  Future<FilePickerResult?> chooseFile() async{
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['json']);
    return resultFile;
  }

  importTrening(File? resultFile) async {
    File importedFile;
    if(resultFile != null){
      importedFile = resultFile;
    }else return;

    try{
      Map <String, dynamic> importContent = json.decode(importedFile.readAsStringSync());
      Trening importedTrening = Trening.fromJson(importContent);
      callBackAddTrening(importedTrening.getSArr(), importedTrening.getImeTreninga(), treninzi.treninzi.length);
      return "";
    }catch(e){
      print(e.toString());
      return "error";
    }
  }

  callBackAddTrening(List<Serija> s, String ime, int index){
    Trening t = Trening();
    t.setSerije(s);
    t.setImeTreninga(ime);
    if(index < treninzi.treninzi.length){
      treninzi.treninzi[index] = t;
    }else{
      treninzi.treninzi.add(t);
    }
    setState(() {});
    writeToFile(treninzi.toJson());
  }

  callBackRemoveTrening(int index){
    treninzi.treninzi.removeAt(index);
    writeToFile(treninzi.toJson());
    setState(() {});
  }

  buildDialog() => Dialog(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                overlayColor: MaterialStateProperty.all(Colors.grey[350]),
              ),
              onPressed: (){
                Navigator.pop(context);
                _setLocale('en');
              },
              child: Text(
                'English',
                style: drawerOptionTextStyle,
              )
          ),
          TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                overlayColor: MaterialStateProperty.all(Colors.grey[350]),
              ),
              onPressed: (){
                Navigator.pop(context);
                _setLocale('sr');
              },
              child: Text(
                'Srpski',
                style: drawerOptionTextStyle,
          )
          )
        ],
      ),
    ),
  );

  buildImporter(File? f) {
    File? resultFile = f;
    //FilePickerResult? resultFile = null;
    String errorMsg = '';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
       return Dialog(
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                resultFile == null ? ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                    ),
                    onPressed: () async {
                      await chooseFile().then((chosenFile) {
                        if(chosenFile != null){
                          resultFile = File(chosenFile.files.first.path!);
                        }else resultFile = null;
                      });

                      errorMsg = '';
                      setState(() {});
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            Icons.add_box_rounded,
                          color: Colors.grey[900],
                        ),
                        Text(
                            ' ' + LocaleData.chooseFile.getString(context),
                            style: dialogTextStyle
                        ),
                      ],
                    )
                ) : Text(
                  resultFile!.path.split('/').last,
                    style: dialogTextStyle,
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: resultFile == null ? MaterialStateProperty.all(Colors.transparent) : MaterialStateProperty.all(Colors.grey[350]),
                      splashFactory: resultFile == null ? NoSplash.splashFactory : InkSplash.splashFactory,
                    ),
                    onPressed: () async {
                      if(resultFile != null){
                        String e = await importTrening(resultFile);
                        if(e == "error"){
                          errorMsg = LocaleData.badFileErrorMsg.getString(context);
                          resultFile = null;
                          setState(() {});
                        }else{
                          Navigator.of(context).pop();
                        }
                      }else{
                          errorMsg = LocaleData.noFileErrorMsg.getString(context);
                          setState(() {});
                      }
                    },
                    child: Text(
                      LocaleData.import.getString(context),
                      style: resultFile == null ? grayDialogTextStyle : dialogTextStyle,
                    )
                ),
                SizedBox(height: errorMsg != '' ? 15 : 0),
                errorMsg != '' ? Text(
                    errorMsg,
                    style: dialogErrorTextStyle,
                ) : SizedBox()
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Text(
          LocaleData.workouts.getString(context),
          style: appBarTextStyle
        ),
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        backgroundColor: Colors.white,
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
            Text(
                'Workout Timer',
                textAlign: TextAlign.center,
                style: workoutTimerDrawerTextStyle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                color: Colors.grey[300],
                height: 25,
                thickness: 0.8,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                LocaleData.language.getString(context),
                textAlign: TextAlign.center,
                style: drawerOptionTextStyle,
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (BuildContext context) => buildDialog());
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                LocaleData.importWorkout.getString(context),
                textAlign: TextAlign.center,
                style: drawerOptionTextStyle,
              ),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(context: context, builder: (BuildContext context) => buildImporter(null));
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
            itemCount: treninzi.treninzi.length,
            itemBuilder: (context, index) =>
            TrainingCard(index: index,callBackShareFile: callBackShareFile, callBackRemoveTrening: callBackRemoveTrening, trening: treninzi.treninzi[index], callBackAddTrening: callBackAddTrening,)
          ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[900],
        elevation: 7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        onPressed: (){
          Navigator.pushNamed(context, '/creator', arguments: KreatorTreningaArguments(callBackAddTrening, Trening(), treninzi.treninzi.length));
        },
        child: const Icon(
            color: Colors.white,
            Icons.add
        ),
      ),
    );
  }
}