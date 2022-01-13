import 'package:shared_preferences/shared_preferences.dart';

// 端末保存クラス
class SharedPrefs {
  static SharedPreferences? prefsInstance;

  // setUid(),getUid()を実行するためのインスタンス
  static Future<void> setInstance() async {
    if (prefsInstance == null) {
      prefsInstance = await SharedPreferences.getInstance();
    }
    print('インスタンス生成');
  }

  // 送られてくる新しいユーザーID(newUid)をキー(uid)に紐づけて保存する処理
  static Future<void> setUid(String newUid) async {
    await prefsInstance?.setString('uid', newUid);
    print('保存完了');
  }

  // ID取得処理
  static String? getUid() {
    // uidが取得できなかった場合、空の値を返すようにする。
    String? uid = prefsInstance?.getString('uid') ?? '';
    return uid;
  }
}
