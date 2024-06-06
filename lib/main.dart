import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    print("notify");
    final InitializationSettings initializationSettings = InitializationSettings(iOS: initializationSettingsDarwin);
    await flutterLocalNotificationPlugin.initialize(
      initializationSettings,
    );
  }
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Future<void> _showNotificationWithActions() async {
//   print("_showNotificationWithActions");
//   // const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//   //   '...',
//   //   '...',
//   //   actions: <AndroidNotificationAction>[
//   //     AndroidNotificationAction('id_1', 'Action 1'),
//   //     AndroidNotificationAction('id_2', 'Action 2'),
//   //     AndroidNotificationAction('id_3', 'Action 3'),
//   //   ],
//   // );
//   const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
//   await flutterLocalNotificationPlugin.show(0, '...', '...', notificationDetails);
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          requestPermissionsOnIos();
          // _showNotificationWithActions();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> showNotificationOnIos() async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'id_1',
    'Action 1',
  );
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
  if (iosFlutterLocalNotificationsPlugin != null) {
    print("wao");
    // await iosFlutterLocalNotificationsPlugin.show(1, 'Action 1', "こんにちは", const NotificationDetails());
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(iOS: darwinNotificationDetails);

    flutterLocalNotificationPlugin.show(id++, 'でも', 'そうだね 明日やろっか', notificationDetails, payload: 'item z');
  }
}
