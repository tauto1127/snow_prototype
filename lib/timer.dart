import 'package:flutter/material.dart';

class TimerSetting extends StatefulWidget {
  TimerSetting({super.key});
  final int seconds = 10;
  final TextEditingController textEditingController = TextEditingController();
  @override
  State<TimerSetting> createState() => _TimerSettingState();
}

class _TimerSettingState extends State<TimerSetting> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("タイマー設定"),
      ),
      body: Column(
        children: [
          Form(
              key: formKey,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "何秒にする?",
                ),
                controller: widget.textEditingController,
              )),
          Builder(builder: (context) {
            return Text(formKey.currentState!.validate().toString());
          })
        ],
      ),
    );
  }
}
