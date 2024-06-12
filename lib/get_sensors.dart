import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sinsetu_prototype/main.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  @override
  Position myPosition = Position(
    altitudeAccuracy: 0,
    headingAccuracy: 0,
    latitude: 41.84212,
    longitude: 140.76847,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    floor: null,
  );
  late StreamSubscription<Position> myPositionStream;
  late double? deviceDirection;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  Position markerPosition = Position(
      longitude: 41.767470763313604,
      latitude: 140.73334598482998,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);
  late double markerDirection;
  double directionTolerance = 5.0;

  double calcDirection(Position startPosition, Position endPosition) {
    double startLat = startPosition.latitude;
    double startLng = startPosition.longitude;
    double endLat = endPosition.latitude;
    double endLng = endPosition.longitude;
    double direction =
        Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
    if (direction < 0.0) {
      direction += 360.0;
    }
    return direction;
  }

  bool checkTolerance(double direction1, double direction2) {
    if ((direction1 - direction2).abs() < directionTolerance) {
      return true;
    } else if ((direction1 - direction2).abs() > 360 - directionTolerance) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    // 位置情報サービスが許可されていない場合は許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    // ユーザの現在位置を取得し続ける
    myPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      myPosition = position;
    });
  }

  @override
  void dispose() {
    myPositionStream.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error reading heading: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          deviceDirection = snapshot.data?.heading;
          if (deviceDirection == null) {
            return const Center(
              child: Text("Device does not have sensors !"),
            );
          }
          markerDirection = calcDirection(myPosition, markerPosition);

          return Center(
              child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2.0, color: Colors.black),
                ),
              ),
              Transform.rotate(
                angle: (deviceDirection! * (3.141592653589793 / 180) * -1),
                child: Icon(
                  Icons.navigation_outlined,
                  size: 100,
                  color: checkTolerance(deviceDirection!, markerDirection)
                      ? Colors.red
                      : Colors.blue,
                ),
              )
            ],
          )

              // Text(
              // '${direction.toStringAsFixed(0)}°',
              // style: const TextStyle(fontSize: 100),
              // ),
              );
        },
      ),
    );
  }
}
