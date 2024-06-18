import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sinsetu_prototype/const_variables.dart';
import 'package:sinsetu_prototype/main.dart';
import 'package:sinsetu_prototype/provider/agora_token_provider.dart';

class agoraCall extends StatefulWidget {
  @override
  State<agoraCall> createState() => _agoraCallState();
}

Future<void> getToken() async {
  HttpClient httpClient = HttpClient();
}

class _agoraCallState extends State<agoraCall> with WidgetsBindingObserver {
  TextEditingController uidEditingController = TextEditingController(text: "1");
  TextEditingController tokenEditingController = TextEditingController(text: token_agora);
  TextEditingController channelNameEditingController = TextEditingController(text: "test");

  late RtcEngine _engine;
  String channel = "test";
  String token_temp = "49aa047c914e4af4a7f646d8a3f78f2c";
  @override
  void initState() {
    super.initState();
  }

  Future<void> initAgoraCalling() async {
    debugPrint("initAgoraCalling");
    await getToken();
    await initAgoraEngine();
    await _engine.setDefaultAudioRouteToSpeakerphone(true);
    debugPrint("initAgoraCalling");
    await _engine.joinChannel(
        token: tokenEditingController.text,
        channelId: channel_agora,
        uid: int.parse(uidEditingController.text),
        // Set the user role as host
        // To set the user role to audience, change clientRoleBroadcaster to clientRoleAudience
        options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
  }

  Future<String> getToken() async {
    String _token = await getAgoraToken(int.parse(uidEditingController.text), channelNameEditingController.text);
    tokenEditingController.text = _token;
    return _token;
  }

  Future<void> initAgoraEngine() async {
    _engine = createAgoraRtcEngineEx();
    await _engine.initialize(const RtcEngineContext(appId: appId_agora, channelProfile: ChannelProfileType.channelProfileCommunication));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onError: (err, msg) => debugPrint("エラーが発生したでー${err.toString()}"),
      onJoinChannelSuccess: (connection, elapsed) => debugPrint("成功したでー${connection.toString()}"),
      onUserJoined: (connection, remoteUid, elapsed) => debugPrint("誰か来たでー${connection.toString()}"),
      onUserOffline: (connection, remoteUid, reason) => debugPrint(connection.localUid.toString()),
    ));
    await _engine.enableWebSdkInteroperability(true);
    await _engine.enableAudio();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // await _engine.setAudioProfile(
    //   profile: AudioProfileType.audioProfileDefault,
    //   scenario: AudioScenarioType.audioScenarioDefault,
    // );
  }

  bool screenOn = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      screenOn = true;
    } else if (state == AppLifecycleState.inactive) {
      screenOn = false;
    } else if (state == AppLifecycleState.paused) {
      screenOn = false;
    }
  }

  Future<void> waitUntilScreenOn() async {
    while (screenOn == false) {
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> changeChannelAsync() async {
    await getToken();
    FlutterForegroundTask.launchApp();
    await waitUntilScreenOn();
    _engine.leaveChannel();
    _engine.joinChannel(
        token: tokenEditingController.text,
        channelId: channelNameEditingController.text,
        uid: int.parse(uidEditingController.text),
        options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
  }

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  bool lock = false;

  @override
  Widget build(BuildContext context) {
    channelNameEditingController.addListener(() => setState(() {}));
    uidEditingController.addListener(() => setState(() {}));
    tokenEditingController.addListener(() => setState(() {}));

    if (!lock) {
      initAgoraCalling();
      lock = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      debugPrint("postFrameCallback");
    });
    return WithForegroundTask(
        child: Scaffold(
      body: MyHomePage(title: "BATTARI"),
      // appBar: AppBar(),
      // floatingActionButton: TextButton(
      //   child: Text("call"),
      //   onPressed: () async {
      //     debugPrint("what");
      //     initAgoraCalling();
      //   },
      // ),
    ));
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                child: Text("電話を切る"),
                onPressed: () {
                  _engine.leaveChannel();
                  _engine.release();
                }),
            TextButton(
              child: Text("チャンネルを変更"),
              onPressed: () async {
                changeChannelAsync();
              },
            ),
            IconButton(
              onPressed: () => getToken(),
              icon: Icon(Icons.warning),
            ),
            TextButton(
              child: Text("permission"),
              onPressed: () async => await [Permission.microphone].request(),
            ),
          ],
        ),
        body: Column(
          children: [
            Text("a"),
            TextButton(
              child: Text("通話する"),
              onPressed: () async {
                await initAgoraEngine();
                await _engine.joinChannel(
                    token: tokenEditingController.text,
                    channelId: channel_agora,
                    uid: int.parse(uidEditingController.text),
                    // Set the user role as host
                    // To set the user role to audience, change clientRoleBroadcaster to clientRoleAudience
                    options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
                debugPrint("通話開始" + uidEditingController.text);
              },
            ),
            TextFormField(
              controller: uidEditingController,
            ),
            Text(uidEditingController.text),
            TextFormField(
              controller: tokenEditingController,
            ),
            Text(channelNameEditingController.text),
            TextFormField(
              controller: channelNameEditingController,
            ),
            TextButton(
              child: Text("start foreground service"),
              onPressed: () =>
                  FlutterForegroundTask.startService(notificationTitle: "notificationTitle", notificationText: "notificationText"),
            ),
            TextButton(
              child: Text("権限フォア"),
              onPressed: _requestPermissionForAndroid,
            )
          ],
        ),
        floatingActionButton: TextButton(
          child: Text("start timer"),
          onPressed: () async {
            await Future.delayed(Duration(seconds: 10));
            channelNameEditingController.text = "timer";
            changeChannelAsync();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
