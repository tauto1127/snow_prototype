import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Gps {
  double latitude = 0;
  double longitude = 0;

  Gps.fromJson(Map<String, dynamic> json)
      : latitude = double.parse(json['latitude'].toString()),
        longitude = double.parse(json['longitude'].toString());

  Gps(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

Future<Gps> getGps(int userid) async {
  Uri uri = Uri.parse("http://10.124.75.215:5225/Mukaiawase/GetGps?userid=0");

  Gps gps;
  try {
    var response = await http.get(uri);
    gps = Gps.fromJson(json.decode(response.body));
  } catch (e) {
    print('getGpsでエラーが発生しました: $e');
    gps = Gps(0, 0);
  }
  print(gps.latitude);
  return gps;
}

Future<Gps> setGps(int userid, double latitude, double longitude) async {
  Uri uri = Uri.parse(
      "http://10.124.75.215:5225/Mukaiawase/SetGps?userid=0&latitude=$latitude&longitude=$longitude");
  Gps gps;
  try {
    var response = await http.put(uri);
    gps = Gps.fromJson(json.decode(response.body));
  } catch (e) {
    print('setGpsでエラーが発生しました: $e');
    gps = Gps(0, 0);
  }
  return gps;
}
