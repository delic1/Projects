import 'serija_class.dart';

class Trening{
  List<Serija> _serije = [];
  String? _imeTreninga;

  Trening(){
    _imeTreninga = '';
  }

  Trening.fromJson(Map<String, dynamic> json)
      : _imeTreninga = json['ime_treninga'] as String,
        _serije = (json['serije'] as List)
            .map((serijeJson) => Serija.fromJson(serijeJson))
            .toList();

  Map<String, dynamic> toJson() => {
    'ime_treninga': _imeTreninga,
    'serije': _serije.map((s) => s.toJson()).toList(),
  };

  setImeTreninga(String imeTreninga){
    _imeTreninga = imeTreninga;
  }
  getImeTreninga() => _imeTreninga;

  setSerije(List<Serija> serije){
    _serije = serije;
  }
  getSArr() => _serije;
}