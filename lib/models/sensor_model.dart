class SensorModel {
  String? useruuid;
  String? id;
  String? systemuuid;
  String? sensorname;
  bool? isactive;
  String? sensorid;
  String? topic;

  SensorModel(
      {this.useruuid,
        this.id,
        this.systemuuid,
        this.sensorname,
        this.isactive,
        this.sensorid,
        this.topic});

  SensorModel.fromJson(Map<String, dynamic> json) {
    useruuid = json['useruuid'];
    id = json['id'];
    systemuuid = json['systemuuid'];
    sensorname = json['sensorname'];
    isactive = json['isactive'];
    sensorid = json['sensorid'];
    topic = json['topic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['useruuid'] = this.useruuid;
    data['id'] = this.id;
    data['systemuuid'] = this.systemuuid;
    data['sensorname'] = this.sensorname;
    data['isactive'] = this.isactive;
    data['sensorid'] = this.sensorid;
    data['topic'] = this.topic;
    return data;
  }
}
