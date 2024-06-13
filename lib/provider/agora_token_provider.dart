import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sinsetu_prototype/const_variables.dart';

///agoraにアクセスするためのトークンを生成する関数
///
///@param uid 参加者のuid(チャンネルの中に重複したuidはできない)
///
///@param channel 参加するチャンネル名
///
///@return トークン
Future<String> getAgoraToken(int uid, String channel) async {
  var res = await http.get(Uri.parse("${backend_base_url}/Agora/GetToken?channelName=$channel&uid=$uid"));
  return res.body;
}
