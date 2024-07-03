import 'trening_class.dart';

class Treninzi{
  List<Trening> treninzi = [];

  Treninzi();

  Treninzi.fromJson(Map<String, dynamic> json)
      : treninzi = (json['treninzi'] as List)
            .map((treninziJson) => Trening.fromJson(treninziJson))
            .toList();

  Map<String, dynamic> toJson() => {
    'treninzi': treninzi.map((t) => t.toJson()).toList()
  };
}