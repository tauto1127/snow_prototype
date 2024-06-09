import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sinsetu_prototype/timer.dart';

// 設定たち
const notifierMessage = "こんにちは";
const notifierTitle = "タイトル";
const notifierSeconds = 10;

const double widgetPaddingSize = 15;
const TextStyle titleTextStyle = TextStyle(
  decoration: TextDecoration.underline,
  fontStyle: FontStyle.italic,
  fontFamily: "Zapfino",
  fontSize: 25,
);

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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
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
        primary: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
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
                style: TextStyle(fontSize: 20),
              ),
            ),
            Text(
              "あなたと同じ番組を見ていました",
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
            style: TextStyle(fontSize: 30),
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
      "結婚",
      "子供",
      "親戚",
    ];
    return Column(
      children: [
        const SizedBox(
          child: Text(
            "Keywords",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final keyword in keywords)
              Card(
                  margin: const EdgeInsets.all(15),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
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
    final buttonWaku = BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(200));
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
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Icon(
                    color: Colors.white,
                    Icons.close,
                    size: 40,
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
