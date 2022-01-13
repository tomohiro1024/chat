import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  static Future<void> addUser() async {
    try {
      final newDoc = await _firestoreInstance.collection('user').add({
        'name': 'NoName',
        'image_path': 'https://pbs.twimg.com/media/EtsT0zYVgAIIu1Y.jpg'
      });
      print('アカウント作成完了');
      print(newDoc.id);

      // アカウントが作成完了したらSharedPrefs(端末)にnewDocに入ってきたIDを保存する。
      await SharedPrefs.setUid(newDoc.id);
      String? uid = SharedPrefs.getUid();
      print(uid);

      // チャットルームの作成
      // getUser()で作成されたユーザーのIDを入れる。
      List<String>? userIds = await getUser();
      // ユーザーのIDの情報を繰り返す
      userIds?.forEach((user) async {
        // 取得したユーザーIDが自分のではない場合、以下2つをroomに追加する。
        if (user != newDoc.id) {
          await _firestoreInstance.collection('room').add({
            'joined_user_ids': [user, newDoc.id],
            'updated_time': Timestamp.now()
          });
        }
      });

      print('room作成完了');
    } catch (e) {
      print('失敗: $e');
    }
  }

  static Future<List<String>?> getUser() async {
    try {
      final snapshot = await _firestoreInstance.collection('user').get();
      // user(Firestoreのドキュメント)のIDをリストにして返すための変数
      List<String> userIds = [];
      snapshot.docs.forEach((user) {
        userIds.add(user.id);
      });

      return userIds;
    } catch (e) {
      print('取得失敗: $e');
      return null;
    }
  }
}
