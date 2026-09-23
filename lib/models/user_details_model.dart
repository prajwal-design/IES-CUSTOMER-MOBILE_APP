import 'dart:convert';

class UserDetailsModel {
  String? id;
  String? name;
  int? age;
  Null? gender;
  String? password;
  String? email;
  Null? phoneNumber;
  Null? deviceToken;
  List<Roles>? roles;
  Null? userRoleList;
  Null? phoneOrEmail;
  Null? siteList;
  List<Sites>? sites;
  bool? active;

  UserDetailsModel(
      {this.id,
        this.name,
        this.age,
        this.gender,
        this.password,
        this.email,
        this.phoneNumber,
        this.deviceToken,
        this.roles,
        this.userRoleList,
        this.phoneOrEmail,
        this.siteList,
        this.sites,
        this.active});

  UserDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    age = json['age'];
    gender = json['gender'];
    password = json['password'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    deviceToken = json['deviceToken'];
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
    userRoleList = json['userRoleList'];
    phoneOrEmail = json['phoneOrEmail'];
    siteList = json['siteList'];
    if (json['sites'] != null) {
      sites = <Sites>[];
      json['sites'].forEach((v) {
        sites!.add(new Sites.fromJson(v));
      });
    }
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['password'] = this.password;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['deviceToken'] = this.deviceToken;
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    data['userRoleList'] = this.userRoleList;
    data['phoneOrEmail'] = this.phoneOrEmail;
    data['siteList'] = this.siteList;
    if (this.sites != null) {
      data['sites'] = this.sites!.map((v) => v.toJson()).toList();
    }
    data['active'] = this.active;
    return data;
  }
}

class Roles {
  String? id;
  Null? type;
  String? name;
  Null? description;
  bool? active;
  Null? createdDate;
  Null? updatedDate;
  Null? modifiedBy;

  Roles(
      {this.id,
        this.type,
        this.name,
        this.description,
        this.active,
        this.createdDate,
        this.updatedDate,
        this.modifiedBy});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    active = json['active'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
    modifiedBy = json['modifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['name'] = this.name;
    data['description'] = this.description;
    data['active'] = this.active;
    data['createdDate'] = this.createdDate;
    data['updatedDate'] = this.updatedDate;
    data['modifiedBy'] = this.modifiedBy;
    return data;
  }
}

class Sites {
  String? id;
  String? name;
  String? description;
  List<Systems>? systems;
  int? siteExternalId;
  double? criticalResistanceValue;

  Sites(
      {this.id,
        this.name,
        this.description,
        this.systems,
        this.siteExternalId,
        this.criticalResistanceValue});

  Sites.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    if (json['systems'] != null) {
      systems = <Systems>[];
      json['systems'].forEach((v) {
        systems!.add(new Systems.fromJson(v));
      });
    }
    siteExternalId = json['siteExternalId'];
    if (json['criticalResistanceValue'] != null) {
      criticalResistanceValue = (json['criticalResistanceValue'] as num).toDouble();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.systems != null) {
      data['systems'] = this.systems!.map((v) => v.toJson()).toList();
    }
    data['siteExternalId'] = this.siteExternalId;
    data['criticalResistanceValue'] = this.criticalResistanceValue;
    return data;
  }
}

class Systems {
  String? id;
  String? name;
  String? description;
  List<Sensors>? sensors;
  int? systemExternalId;

  Systems(
      {this.id,
        this.name,
        this.description,
        this.sensors,
        this.systemExternalId});

  Systems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    if (json['sensors'] != null) {
      sensors = <Sensors>[];
      json['sensors'].forEach((v) {
        sensors!.add(new Sensors.fromJson(v));
      });
    }
    systemExternalId = json['systemExternalId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.sensors != null) {
      data['sensors'] = this.sensors!.map((v) => v.toJson()).toList();
    }
    data['systemExternalId'] = this.systemExternalId;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Sensors {
  String? name;
  String? id;
  String? description;
  int? sensorExternalId;
  String? lastUpdatedAt;
  Null data;
  Maintenance? maintenance;

  Sensors(
      {this.name,
        this.id,
        this.description,
        this.sensorExternalId,
        this.lastUpdatedAt,
        this.data,
        this.maintenance});

  Sensors.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    description = json['description'];
    sensorExternalId = json['sensorExternalId'];
    lastUpdatedAt = json['lastUpdatedAt'];
    data = json['data'];
    maintenance = json['maintenance'] != null
        ? Maintenance.fromJson(json['maintenance'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['description'] = this.description;
    data['sensorExternalId'] = this.sensorExternalId;
    data['lastUpdatedAt'] = this.lastUpdatedAt;
    data['data'] = this.data;
    if (this.maintenance != null) {
      data['maintenance'] = this.maintenance!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Maintenance {
  String? id;
  String? maintainerUserId;
  String? maintainerName;
  String? lastMaintenanceDate;
  String? nextMaintenanceDate;
  String? maintenanceNotes;
  String? status;

  Maintenance(
      {this.id,
        this.maintainerUserId,
        this.maintainerName,
        this.lastMaintenanceDate,
        this.nextMaintenanceDate,
        this.maintenanceNotes,
        this.status});

  Maintenance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    maintainerUserId = json['maintainerUserId'];
    maintainerName = json['maintainerName'];
    lastMaintenanceDate = json['lastMaintenanceDate'];
    nextMaintenanceDate = json['nextMaintenanceDate'];
    maintenanceNotes = json['maintenanceNotes'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['maintainerUserId'] = this.maintainerUserId;
    data['maintainerName'] = this.maintainerName;
    data['lastMaintenanceDate'] = this.lastMaintenanceDate;
    data['nextMaintenanceDate'] = this.nextMaintenanceDate;
    data['maintenanceNotes'] = this.maintenanceNotes;
    data['status'] = this.status;
    return data;
  }
}
