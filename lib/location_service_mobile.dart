import 'package:geolocator/geolocator.dart';

import 'location_data.dart';

Future<SosLocationData?> getCurrentSosLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
    timeLimit: const Duration(seconds: 15),
  );

  return SosLocationData(
    latitude: position.latitude,
    longitude: position.longitude,
    precisao: position.accuracy,
    timestamp: DateTime.now().toUtc(),
  );
}
