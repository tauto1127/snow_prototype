import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sinsetu_prototype/agora_call.dart';
import 'package:sinsetu_prototype/get_sensors.dart';
import 'package:sinsetu_prototype/gps_util.dart';

// 設定たち
const notifierMessage = "こんにちは";
const notifierTitle = "タイトル";
const notifierSeconds = 10;

const double widgetPaddingSize = 15;
const TextStyle titleTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    fontStyle: FontStyle.italic,
    // fontFamily: "Zapfino",
    fontSize: 25,
    fontWeight: FontWeight.bold);

final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) {});
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().notificationTapBackground();
  // await getGps(0);
  // await setGps(0, 200, 200);
  // await FlutterCallkitIncoming.requestNotificationPermission({
  //   "rationaleMessagePermission": "Notification permission is required, to show notification",
  //   "postNotificationMessageRequired": "Notification permission is required, Please allow notification permission from setting."
  // });

  // await FlutterCallkitIncoming.requestNotificationPermission({
  //   "rationaleMessagePermission": "Notification permission is required, to show notification",
  //   "postNotificationMessageRequired": "Notification permisseion is required",
  // });
  _initForegroundTask();
  runApp(MaterialApp(home: Compass()));
  // runApp(const MyApp());
}

class NotificationService {
  Future<void> notificationTapBackground() async {}
}

Future<void> startTimer() async {
  await Future.delayed(const Duration(seconds: notifierSeconds));
  const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

  const NotificationDetails notificationDetails = NotificationDetails(iOS: darwinNotificationDetails);

  flutterLocalNotificationPlugin.show(id++, notifierTitle, notifierMessage, notificationDetails, payload: 'item z');
}

void _initForegroundTask() {
  FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground service',
          channelName: 'Foreground Service Notification',
          priority: NotificationPriority.MAX,
          channelImportance: NotificationChannelImportance.MAX),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        interval: 300,
        isOnceEvent: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ));
}
//@pragma('vm:entry-point')

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const MyHomePage(
        title: "アプリ",
      ),
      debugShowCheckedModeBanner: false,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                height: 100,
              ),
              talkingWith(),
              const SizedBox(
                height: 30,
              ),
              lastTalking(),
              tuuwaButtons(),
            ],
          );
        }),
      ),
    );
  }

  final widgetDecoration = BoxDecoration(borderRadius: BorderRadius.circular(40), color: Colors.grey[200]);

  Widget talkingWith() {
    return Container(
      decoration: widgetDecoration,
      child: const Padding(
        padding: EdgeInsets.all(widgetPaddingSize),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                "Talking with ...",
                style: titleTextStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "@sinsetu_prototype",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              "同じタイミングで扉を開けました",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget lastTalking() {
    return Container(
        decoration: widgetDecoration,
        child: Padding(
          padding: const EdgeInsets.all(widgetPaddingSize),
          child: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Last talking",
                  style: titleTextStyle,
                  textAlign: TextAlign.start,
                ),
              ),
              lastTalkingDate(),
              const SizedBox(
                height: 10,
              ),
              keywordsWidget(),
            ],
          ),
        ));
  }

  Widget lastTalkingDate() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "Two months ago...",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              "2024/04/22",
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget keywordsWidget() {
    const keywords = [
      "サークル",
      "友達",
      "バイト",
    ];
    return Column(
      children: [
        const SizedBox(
          child: Text(
            "Keywords",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final keyword in keywords)
              Card(
                  margin: const EdgeInsets.all(15),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    child: Text(
                      keyword,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )),
          ],
        ),
      ],
    );
  }

  Widget tuuwaButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(200)),
                      child: const Icon(
                        size: 40,
                        Icons.volume_up,
                      ),
                    ),
                    const Text(
                      "スピーカー\nをオン",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(200)),
                      child: Icon(
                        size: 40,
                        Icons.mic_off_outlined,
                      ),
                    ),
                    const Text("マイクをオフ"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(200), color: Colors.red),
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(
                      Icons.close,
                      size: 30,
                    ),
                    onPressed: () async {
                      requestPermissionsOnIos();
                      await startTimer();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
