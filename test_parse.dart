import 'dart:convert';
import 'dart:io';

class Sensors {
  String? name;
  String? id;

  Sensors({this.name, this.id});

  @override
  String toString() {
    return 'Sensors(id: $id, name: $name)';
  }
}

class PitStatusModel {
  int? sites;
  int? systems;
  int? sensors;
  List<Sensors>? criticalSensors;
  List<Sensors>? activeSensors;
  List<Sensors>? inactiveSensors;

  PitStatusModel.fromJson(Map<String, dynamic> json) {
    sites = json['sites'] ?? json['Sites'];
    systems = json['systems'] ?? json['Systems'];
    sensors = json['sensors'] ?? json['Sensors'];
    
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
}

void main() {
  final jsonString = '''{
    "sites": 1,
    "systems": 1,
    "sensors": 3,
    "activeSensors": [
        {
            "name": "IES-0001",
            "id": "6ab12ad63fe08100bf8387df",
            "description": "No discription",
            "sensorExternalId": 27,
            "lastUpdatedAt": "2026-09-23T07:31:57.909Z",
            "data": null,
            "iesCustomerId": "6ab14f35043c431fa0d7c657",
            "maintenance": null,
            "criticalResistanceValue": null
        },
        {
            "name": "IES-0002",
            "id": "6ab12b873fe08100bf8387ec",
            "description": "No discription",
            "sensorExternalId": 28,
            "lastUpdatedAt": "2026-09-23T07:31:57.912Z",
            "data": null,
            "iesCustomerId": "6ab14f35043c431fa0d7c657",
            "maintenance": null,
            "criticalResistanceValue": null
        }
    ],
    "criticalSensors": [
        {
            "createdAt": "2026-09-23T07:31:57.959Z",
            "sensorId": "6ab12ad63fe08100bf8387df",
            "name": "IES-0001",
            "sensorData": {
                "id": "6ab3806d00a8571e5640887d",
                "sensor": "6ab12ad63fe08100bf8387df",
                "V": 1.06,
                "I": 2.48,
                "R": 3.56,
                "G": 25.0,
                "timestamp": "2026-09-23T07:31:57.855Z",
                "deviceId": "IES-0001",
                "Fault": null,
                "criticalResistanceValue": null
            },
            "iesCustomerId": "6ab14f35043c431fa0d7c657"
        }
    ],
    "inactiveSensors": []
  }''';

  try {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final model = PitStatusModel.fromJson(data);
    print('Sites: ${model.sites}');
    print('Active: ${model.activeSensors?.length}, Names: ${model.activeSensors?.map((e) => e.name).toList()}');
    print('Critical: ${model.criticalSensors?.length}, Names: ${model.criticalSensors?.map((e) => e.name).toList()}');
    print('Inactive: ${model.inactiveSensors?.length}');
  } catch (e, stackTrace) {
    print('Error: $e\\n$stackTrace');
  }
}
