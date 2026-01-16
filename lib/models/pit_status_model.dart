class PitStatusModel {
  int? sites;
  int? systems;
  int? sensors;
  Status? status;

  // PitStatusModel({this.sites, this.systems, this.sensors, this.status});

  PitStatusModel(this.sites, this.systems, this.sensors, this.status);

  // named constructor..
  PitStatusModel.fromJson(Map<String, dynamic> json) {
    sites = json['Sites'];
    systems = json['Systems'];
    sensors = json['Sensors'];
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Sites'] = this.sites;
    data['Systems'] = this.systems;
    data['Sensors'] = this.sensors;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class Status {
  int? active;
  int? inactive;
  int? critical;

  Status({this.active, this.inactive, this.critical});

  Status.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    inactive = json['inactive'];
    critical = json['critical'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active'] = this.active;
    data['inactive'] = this.inactive;
    data['critical'] = this.critical;
    return data;
  }
}
