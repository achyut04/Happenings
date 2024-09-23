class GetPlaces {
  List<Predictions>? predictions;
  String? status;

  GetPlaces({this.predictions, this.status});

  GetPlaces.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Predictions>[];
      json['predictions'].forEach((v) {
        predictions!.add(Predictions.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (predictions != null) {
      data['predictions'] = predictions!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Predictions {
  String? description;
  String? placeId;
  String? reference;

  Predictions({this.description, this.placeId, this.reference});

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
    reference = json['reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['place_id'] = placeId;
    data['reference'] = reference;
    return data;
  }
}
