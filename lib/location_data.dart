class SosLocationData {
  const SosLocationData({
    required this.latitude,
    required this.longitude,
    this.precisao,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? precisao;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'timestamp': timestamp?.toUtc().toIso8601String(),
    };
  }
}
