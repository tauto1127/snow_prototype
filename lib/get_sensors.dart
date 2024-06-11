import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compass Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Compass(),
    );
  }
}

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  Position myPosition = Position(
    latitude: 41.84212,
    longitude: 140.76847,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    floor: null,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

  late StreamSubscription<Position> myPositionStream;
  late double? deviceDirection;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Position markerPosition = Position(
    latitude: 35.63485362875449,
    longitude: 139.88524000230558,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    floor: null,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

  late double markerDirection;
  double directionTolerance = 5.0;

  // Function to calculate direction from startPosition to endPosition
  double calcDirection(Position startPosition, Position endPosition) {
    double direction = Geolocator.bearingBetween(
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
    if (direction < 0.0) {
      direction += 360.0;
    }
    return direction;
  }

  // Function to check if the directions are within tolerance
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

    // Request location permissions if not already granted
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    // Start listening to the user's position updates
    myPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        myPosition = position;
      });
    });
  }

  @override
  void dispose() {
    myPositionStream
        .cancel(); // Ensure to cancel the stream when disposing the widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass Flutter'),
      ),
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
              child: Text("Device does not have sensors."),
            );
          }

          markerDirection = calcDirection(myPosition, markerPosition);

          return Center(
            child: Opacity(
              opacity:
                  checkTolerance(deviceDirection!, markerDirection) ? 1.0 : 0.0,
              child: const Icon(
                Icons.expand_less,
                size: 100,
              ),
            ),
          );
        },
      ),
    );
  }
}
