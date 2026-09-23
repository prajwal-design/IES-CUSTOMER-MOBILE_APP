import 'package:ies_mobile/models/user_details_model.dart';

class PitStatusModel {
  int? sites;
  int? systems;
  int? sensors;
  Status? status;
  List<Sensors>? criticalSensors;
  List<Sensors>? activeSensors;
  List<Sensors>? inactiveSensors;

  // PitStatusModel({this.sites, this.systems, this.sensors, this.status});

  PitStatusModel(this.sites, this.systems, this.sensors, this.status, {this.criticalSensors, this.activeSensors, this.inactiveSensors});

  // named constructor..
  PitStatusModel.fromJson(Map<String, dynamic> json) {
    sites = json['sites'] ?? json['Sites'];
    systems = json['systems'] ?? json['Systems'];
    sensors = json['sensors'] ?? json['Sensors'];
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['criticalSensors'] != null) {
      criticalSensors = <Sensors>[];
      json['criticalSensors'].forEach((v) {
        criticalSensors!.add(Sensors(id: v['sensorId'] ?? v['id'], name: v['name']));
      });
    }
    if (json['activeSensors'] != null) {
      activeSensors = <Sensors>[];
      json['activeSensors'].forEach((v) {
        activeSensors!.add(Sensors(id: v['sensorId'] ?? v['id'], name: v['name']));
      });
    }
    if (json['inactiveSensors'] != null) {
      inactiveSensors = <Sensors>[];
      json['inactiveSensors'].forEach((v) {
        inactiveSensors!.add(Sensors(id: v['sensorId'] ?? v['id'], name: v['name']));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Sites'] = this.sites;
    data['Systems'] = this.systems;
    data['Sensors'] = this.sensors;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    if (this.criticalSensors != null) {
      data['criticalSensors'] =
          this.criticalSensors!.map((v) => {'id': v.id, 'name': v.name}).toList();
    }
    if (this.activeSensors != null) {
      data['activeSensors'] =
          this.activeSensors!.map((v) => {'id': v.id, 'name': v.name}).toList();
    }
    if (this.inactiveSensors != null) {
      data['inactiveSensors'] =
          this.inactiveSensors!.map((v) => {'id': v.id, 'name': v.name}).toList();
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
