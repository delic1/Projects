import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale('sr', LocaleData.SR)
];

mixin LocaleData {
  static const String workouts = 'workouts';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String share = 'share';
  static const String createWorkout = 'createWorkout';
  static const String workoutName = 'workoutName';
  static const String youMustProvideAName = 'youMustProvideAName';
  static const String exerciseName = 'exerciseName';
  static const String repCount = 'repCount';
  static const String time = 'time';
  static const String reps = 'reps';
  static const String rest = 'rest';
  static const String copy = 'copy';
  static const String save = 'save';
  static const String addExercise = 'addExercise';
  static const String addRest = 'addRest';
  static const String nameErrorMsg = 'nameErrorMsg';
  static const String setErrorMsg = 'setErrorMsg';
  static const String timeErrorMsg = 'timeErrorMsg';
  static const String copyErrorMsg = 'copyErrorMsg';
  static const String start = 'start';
  static const String finish = 'finish';
  static const String timeUntilWorkoutStart = 'timeUntilWorkoutStart';
  static const String areYouSureMsg = 'areYouSureMsg';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String language = 'language';
  static const String importWorkout = 'importWorkout';
  static const String noFileErrorMsg = 'noFileErrorMsg';
  static const String badFileErrorMsg = 'badFileErrorMsg';
  static const String import = 'import';
  static const String chooseFile = 'chooseFile';




  static const Map<String, dynamic> EN = {
    workouts: 'Workouts',
    edit: 'Edit',
    delete: 'Delete',
    share: 'Share',
    createWorkout: 'Create workout',
    workoutName: 'Workout name',
    youMustProvideAName: 'You must provide a name',
    exerciseName: 'Exercise name',
    repCount: 'Rep count',
    time: 'Time',
    reps: 'Reps',
    rest: 'Rest',
    copy: 'Copy',
    save: 'Save',
    addExercise: 'Add exercise',
    addRest: 'Add rest',
    nameErrorMsg: 'You must enter a workout name',
    setErrorMsg: 'You must add at least one exercise',
    timeErrorMsg: 'The exercise time must not be zero',
    copyErrorMsg: 'No exercise was copied',
    start: 'Start',
    finish: 'Finish',
    timeUntilWorkoutStart: 'Time until workout starts: ',
    areYouSureMsg: 'Are you sure you want to delete the workout?',
    yes: 'Yes',
    no: 'No',
    language: 'Language',
    importWorkout: 'Import workout',
    noFileErrorMsg: 'File wasn\'t selected!',
    badFileErrorMsg: 'Selected file couldn\'t be imported!\nChoose correct file.',
    import: 'Import',
    chooseFile: 'Choose file',
  };

  static const Map<String, dynamic> SR = {
    workouts: 'Treninzi',
    edit: 'Izmeni',
    delete: 'Obriši',
    share: 'Podeli',
    createWorkout: 'Napravi trening',
    workoutName: 'Ime treninga',
    youMustProvideAName: 'Morate dati ime',
    exerciseName: 'Ime vežbe',
    repCount: 'Broj ponavljanja',
    time: 'Vreme',
    reps: 'Ponavljanja',
    rest: 'Odmor',
    copy: 'Kopiraj',
    save: 'Sačuvaj',
    addExercise: 'Dodaj vežbu',
    addRest: 'Dodaj odmor',
    nameErrorMsg: 'Morate uneti naziv treninga',
    setErrorMsg: 'Morate dodati bar jednu vežbu',
    timeErrorMsg: 'Vreme vežbe ne sme biti nula',
    copyErrorMsg: 'Nije kopirana vežba',
    start: 'Pokreni',
    finish: 'Završi',
    timeUntilWorkoutStart: 'Vreme do početka treninga: ',
    areYouSureMsg: 'Da li ste sigurni da želite da obrišete trening?',
    yes: 'Da',
    no: 'Ne',
    language: 'Jezik',
    importWorkout: 'Importuj trening',
    noFileErrorMsg: 'Nije izabran fajl!',
    badFileErrorMsg: 'Izabran fajl ne može da se importuje!\nIzaberite ispravan fajl.',
    import: 'Importuj',
    chooseFile: 'Izaberi fajl',

  };
}