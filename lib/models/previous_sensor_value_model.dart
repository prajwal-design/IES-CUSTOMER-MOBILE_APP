class PreviousSensorValueModel {
  final String id;
  final String sensor;
  final double V;
  final double I;
  final double R;
  final double G;
  final String timestamp;
  final String deviceId;
  final String fault;

  PreviousSensorValueModel({
    required this.id,
    required this.sensor,
    required this.V,
    required this.I,
    required this.R,
    required this.G,
    required this.timestamp,
    required this.deviceId,
    required this.fault,
  });

  factory PreviousSensorValueModel.fromJson(Map<String, dynamic> json) {
    return PreviousSensorValueModel(
      id: json['id'] ?? '',
      sensor: json['sensor'] ?? '',
      V: double.tryParse(json['V']?.toString() ?? "0") ?? 0.0,
      I: double.tryParse(json['I']?.toString() ?? "0") ?? 0.0,
      R: double.tryParse(json['R']?.toString() ?? "0") ?? 0.0,
      G: double.tryParse(json['G']?.toString() ?? "0") ?? 0.0,
      timestamp: json['timestamp'] ?? '',
      deviceId: json['deviceId'] ?? '',
      fault: json['Fault'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sensor': sensor,
      'V': V,
      'I': I,
      'R': R,
      'G': G,
      'timestamp': timestamp,
      'deviceId': deviceId,
      'Fault': fault,
    };
  }
}
