import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sinsetu_prototype/gps_util.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  Position myPosition = Position(
    latitude: 140.76722289464738,
    longitude: 41.84255807950272,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    altitudeAccuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    headingAccuracy: 0,
    floor: null,
  );

  late StreamSubscription<Position> myPositionStream;
  late double? deviceDirection;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  Position markerPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);
  Future<void> fetchMarkerPosition() async {
    Gps gps = await getGps(0);
    setState(() {
      markerPosition = Position(
        longitude: gps.longitude,
        latitude: gps.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        floor: null,
      );
    });
  }

  late double markerDirection;
  double directionTolerance = 5.0;
  bool hasNavigated = false; // 遷移を防ぐためのフラグ

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
      setState(() {
        myPosition = position;
      });
    });
    fetchMarkerPosition();
  }

  @override
  void dispose() {
    myPositionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error reading heading: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          deviceDirection = snapshot.data?.heading;
          if (deviceDirection == null) {
            return const Center(child: Text("Device does not have sensors!"));
          }

          markerDirection = calcDirection(myPosition, markerPosition);
          bool isDirectionCorrect =
              checkTolerance(deviceDirection!, markerDirection);

          // 矢印が赤くなったら画面を遷移する
          if (isDirectionCorrect && !hasNavigated) {
            hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TargetScreen()),
              );
            });
          }

          return Center(
            child: Icon(
              Icons.expand_less,
              size: 100,
              color: isDirectionCorrect ? Colors.red : Colors.blue,
            ),
          );
        },
      ),
    );
  }
}

class TargetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Target Screen')),
      body: Center(
        child: Text('You have reached your target!',
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
