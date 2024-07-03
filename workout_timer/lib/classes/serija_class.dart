class Serija{
  String? _name;
  Duration? _time;
  int? _reps;
  bool? _isTimed;
  bool? _isRest;

  Serija(){
    _name = " ";
    _time = const Duration(seconds: 0);
    _reps = 0;
    _isTimed = true;
    _isRest = false;
  }

  Serija.rest(){
    _name = " ";
    _time = const Duration(seconds: 0);
    _reps = 0;
    _isTimed = true;
    _isRest = true;
  }

  Serija.copy(Serija s){
    _name = s._name;
    _time = s._time;
    _reps = s._reps;
    _isTimed = s._isTimed;
    _isRest = s._isRest;
  }

  Serija.fromJson(Map<String, dynamic> json)
      : _name = json['name'] as String,
        _time = Duration(seconds: json['time'] as int ),
        _reps = json['reps'] as int,
        _isTimed = json['isTimed'] as bool,
        _isRest = json['isRest'] as bool;

  Map<String, dynamic> toJson() => {
    'name' : _name,
    'time' : _time?.inSeconds,
    'reps' : _reps,
    'isTimed' : _isTimed,
    'isRest' : _isRest
  };

  setName(String name){
    if(name == '') name = ' ';
    _name = name;
  }
  getName() => _name;

  setTime(Duration time){
    _time = time;
  }
  getTime() => _time;

  setReps(int reps){
    _reps = reps;
  }
  getReps() => _reps;

  setIsTimed(bool isTimed){
    _isTimed = isTimed;
  }
  getIsTimed() => _isTimed;

  setIsRest(bool isRest){
    _isRest = isRest;
  }
  getIsRest() => _isRest;
}