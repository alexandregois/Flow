class ReasonFinishTechnicalVisitListing {
  List<ReasonFinishTechnicalVisit> reasons;
  int requestDate;

  ReasonFinishTechnicalVisitListing();

  ReasonFinishTechnicalVisitListing.fromJson(Map<String, dynamic> json) {
    if (json['reasons'] != null) {
      reasons = [];
      json['reasons'].forEach((v) {
        reasons.add(new ReasonFinishTechnicalVisit.fromJson(v));
      });
    }

    requestDate = json['requestDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.reasons != null) {
      data['reasons'] = this.reasons.map((v) => v.toJson()).toList();
    }
    data['requestDate'] = this.requestDate;
    return data;
  }
}

class ReasonFinishTechnicalVisit {
  int id;
  String name;

  ReasonFinishTechnicalVisit();

  ReasonFinishTechnicalVisit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  @override
  String toString() => name;
}
