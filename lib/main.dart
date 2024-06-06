import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sinsetu_prototype/timer.dart';

// 設定たち
const notifierMessage = "こんにちは";
const notifierTitle = "タイトル";
const notifierSeconds = 10;

final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) {});
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().notificationTapBackground();
  runApp(const MyApp());
}

class NotificationService {
  Future<void> notificationTapBackground() async {
    final InitializationSettings initializationSettings = InitializationSettings(iOS: initializationSettingsDarwin);
    await flutterLocalNotificationPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: OnDidReceiveBackgroundNotificationResponse,
        onDidReceiveNotificationResponse: OnDidReceiveNotificationResponse);
  }
}

Future<void> startTimer() async {
  await Future.delayed(const Duration(seconds: notifierSeconds));
  const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(iOS: darwinNotificationDetails);

  flutterLocalNotificationPlugin.show(id++, notifierTitle, notifierMessage, notificationDetails, payload: 'item z');
}

//@pragma('vm:entry-point')

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: "アプリ",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  final String titleNotif = "通知";
  final String bodyNotif = "通知";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: const SizedBox.shrink(),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          requestPermissionsOnIos();
          await startTimer();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

int id = 0;

Future<void> requestPermissionsOnIos() async {
  IOSFlutterLocalNotificationsPlugin? iosFlutterLocalNotificationsPlugin =
      flutterLocalNotificationPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  if (iosFlutterLocalNotificationsPlugin != null) {
    await iosFlutterLocalNotificationsPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

// ignore: non_constant_identifier_names
void OnDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
  print(notificationResponse);
}

void OnDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
  print("通知がクリックされたとき");
  print(notificationResponse);
}
