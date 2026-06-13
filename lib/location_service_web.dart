// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'location_data.dart';

Future<SosLocationData?> getCurrentSosLocation() async {
  final geolocation = html.window.navigator.geolocation;

  final completer = Completer<SosLocationData?>();
  geolocation
      .getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 15),
      )
      .then((position) {
        final coords = position.coords;
        if (coords == null ||
            coords.latitude == null ||
            coords.longitude == null) {
          completer.complete(null);
          return;
        }

        completer.complete(
          SosLocationData(
            latitude: coords.latitude!.toDouble(),
            longitude: coords.longitude!.toDouble(),
            precisao: coords.accuracy?.toDouble(),
            timestamp: DateTime.now().toUtc(),
          ),
        );
      })
      .catchError((_) {
        completer.complete(null);
      });

  return completer.future;
}
