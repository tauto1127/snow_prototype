import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sinsetu_prototype/const_variables.dart';
import 'package:sinsetu_prototype/provider/agora_token_provider.dart';

class agoraCall extends StatefulWidget {
  @override
  State<agoraCall> createState() => _agoraCallState();
}

Future<void> getToken() async {
  HttpClient httpClient = HttpClient();
}

class _agoraCallState extends State<agoraCall> {
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

  Future<void> getToken() async =>
      tokenEditingController.text = await getAgoraToken(int.parse(uidEditingController.text), channelNameEditingController.text);

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

  Future<void> changeChannelAsync() async {
    await getToken();
    _engine.joinChannel(
        token: tokenEditingController.text,
        channelId: channelNameEditingController.text,
        uid: int.parse(uidEditingController.text),
        options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
  }

  @override
  Widget build(BuildContext context) {
    channelNameEditingController.addListener(() => setState(() {}));
    uidEditingController.addListener(() => setState(() {}));
    tokenEditingController.addListener(() => setState(() {}));

    return Scaffold(
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
    );
  }
}
