import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
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
  TextEditingController textEditingController = TextEditingController(text: "1");
  TextEditingController tokenEditingController = TextEditingController(text: token_agora);
  late RtcEngine _engine;
  int uid = 0;
  String channel = "test";
  String token_temp = "49aa047c914e4af4a7f646d8a3f78f2c";
  @override
  void initState() {
    super.initState();
    getToken();
    initAgoraEngine();
  }

  Future<void> getToken() async => tokenEditingController.text = await getAgoraToken(uid, channel);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              child: Text("電話を切る"),
              onPressed: () {
                _engine.leaveChannel();
                _engine.release();
              })
        ],
      ),
      body: Column(
        children: [
          Text("a"),
          TextButton(
            child: Text("通話する"),
            onPressed: () async {
              await _engine.joinChannel(
                  token: tokenEditingController.text,
                  channelId: channel_agora,
                  uid: uid,
                  // Set the user role as host
                  // To set the user role to audience, change clientRoleBroadcaster to clientRoleAudience
                  options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
              debugPrint("通話開始" + uid.toString());
            },
          ),
          TextFormField(
            controller: textEditingController,
          ),
          Text(uid.toString()),
          TextButton(
            child: Text("uidを適用"),
            onPressed: () => setState(
              () => uid = int.parse(textEditingController.text),
            ),
          ),
          TextFormField(
            controller: tokenEditingController,
          ),
          TextButton(child: Text("tokenを適用"), onPressed: () => setState(() => token_temp = tokenEditingController.text)),
        ],
      ),
      floatingActionButton: TextButton(
        child: Text("permission"),
        onPressed: () async => await [Permission.microphone].request(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
