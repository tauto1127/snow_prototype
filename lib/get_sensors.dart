import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sinsetu_prototype/agora_call.dart';
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
      longitude: 140.72289,
      latitude: 41.84678,
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
    if (setStateLock) return;
    setState(() {
      markerPosition = Position(
        longitude: gps.longitude, // 140.70849955849715,
        latitude: gps.latitude, //41.7606567220339,
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
  double directionTolerance = 10.0;

  double calcDirection(Position startPosition, Position endPosition) {
    double startLat = startPosition.latitude;
    double startLng = startPosition.longitude;
    double endLat = endPosition.latitude;
    double endLng = endPosition.longitude;
    double direction = Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
    if (direction < 0.0) {
      direction += 360.0;
    }
    return direction;
  }

  bool setStateLock = false;

  Future<void> navigateToAgoraCall() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => agoraCall()));
  }

  bool checkTolerance(double direction1, double direction2) {
    if ((direction1 - direction2).abs() < directionTolerance) {
      setStateLock = true;
      return true;
    } else if ((direction1 - direction2).abs() > 360 - directionTolerance) {
      setStateLock = true;
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
    myPositionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (!setStateLock) {
        setState(() {
          myPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    myPositionStream.cancel();
    super.dispose();
  }

  bool buildLock = false;
  @override
  Widget build(BuildContext context) {
    Stream<CompassEvent>? event = FlutterCompass.events;
    return Scaffold(
      body: StreamBuilder<CompassEvent>(
        stream: event,
        builder: (context, snapshot) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            if (setStateLock && !buildLock) {
              event = null;
              buildLock = true;
              navigateToAgoraCall();
            }
            ;
          });
          if (snapshot.hasError) {
            return Center(child: Text('Error reading heading: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          deviceDirection = snapshot.data?.heading;
          if (deviceDirection == null) {
            return const Center(child: Text("Device does not have sensors!"));
          }

          markerDirection = calcDirection(myPosition, markerPosition);
          return Center(
            child: Icon(
              Icons.expand_less,
              size: 100,
              color: checkTolerance(deviceDirection!, markerDirection) ? Colors.red : Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
