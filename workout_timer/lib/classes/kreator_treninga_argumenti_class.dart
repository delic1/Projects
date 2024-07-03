import 'package:workout_timer/classes/trening_class.dart';

class KreatorTreningaArguments{
  final Function _callBackAddTrening;
  final Trening _trening;
  final int _index;

  KreatorTreningaArguments(this._callBackAddTrening, this._trening, this._index);

  getCallBackAddTrening() => _callBackAddTrening;
  getTrening() => _trening;
  getIndex() => _index;
}