import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class showSensorsWidget extends StatefulWidget {
  @override
  State<showSensorsWidget> createState() => _showSensorsWidgetState();
}

class _showSensorsWidgetState extends State<showSensorsWidget> {
  AccelerometerEvent accelerometerEvent = AccelerometerEvent(0, 0, 0);
  GyroscopeEvent gyroscopeEvent = GyroscopeEvent(0, 0, 0);
  MagnetometerEvent magnetometerEvent = MagnetometerEvent(0, 0, 0);

  final TextStyle textStyle = TextStyle(fontSize: 20);
  @override
  Widget build(BuildContext context) {
    startSetState();
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Text("accelermeter"),
          Text(
            "x: ${accelerometerEvent.x}\ny: ${accelerometerEvent.y}\nz: ${accelerometerEvent.z}",
            style: textStyle,
          ),
          Divider(),
          Text("gyroscope"),
          Text(
            "x: ${gyroscopeEvent.x}\ny: ${gyroscopeEvent.y}\nz: ${gyroscopeEvent.z}",
            style: textStyle,
          ),
          Divider(),
          Text("magnetometer"),
          Text(
            "x: ${magnetometerEvent.x}\ny: ${magnetometerEvent.y}\nz: ${magnetometerEvent.z}",
            style: textStyle,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((event) {
      accelerometerEvent = event;
    });

    gyroscopeEvents.listen((event) {
      gyroscopeEvent = event;
    });

    magnetometerEvents.listen((event) {
      magnetometerEvent = event;
    });
  }

  Future<void> startSetState() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    }
  }
}
