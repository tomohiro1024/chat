import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  // collection('room')に何かしら値が追加された場合、画面を更新する。
  static final roomSnapshot = _firestoreInstance.collection('room').snapshots();

  static Future<void> addUser() async {
    try {
      final newDoc = await _firestoreInstance.collection('user').add({
        'name': 'NoName',
        'image_path': 'https://pbs.twimg.com/media/EtsT0zYVgAIIu1Y.jpg'
      });
      print('アカウント作成完了');

      // アカウントが作成完了したらSharedPrefs(端末)にnewDocに入ってきたIDを保存する。
      await SharedPrefs.setUid(newDoc.id);

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

  // 自分のFirestoreのプロフィール情報を取得
  static Future<User?> getProfile(String uid) async {
    final profile = await _firestoreInstance.collection('user').doc(uid).get();
    Map<String, dynamic> data = profile.data() as Map<String, dynamic>;
    User myProfile = User(data['name'], uid, data['image_path']);
    return myProfile;
  }

  // トークルームの取得
  static Future<List<TalkRoom>?> getRooms(String myUid) async {
    final snapshot = await _firestoreInstance.collection('room').get();
    List<TalkRoom> roomList = [];
    // 自分のUidの選別
    await Future.forEach(snapshot.docs, (DocumentSnapshot doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // 自分のUidかどうかのチェック
      if (data['joined_user_ids'].contains(myUid)) {
        String? yourUid;
        data['joined_user_ids'].forEach((id) {
          if (id != myUid) {
            yourUid = id;
            return;
          }
        });
        // プロフィール情報の取得
        User? yourProfile = await getProfile(yourUid!);
        TalkRoom room =
            TalkRoom(doc.id, yourProfile!, data['lastMessage'] ?? '');
        roomList.add(room);
      }
    });
    print(roomList.length);

    return roomList;
  }

  // メッセージの取得
  static Future<List<Message>?> getMessages(String roomId) async {
    final messageRef =
        _firestoreInstance.collection('room').doc(roomId).collection('message');
    List<Message> messageList = [];
    final snapshot = await messageRef.get();
    await Future.forEach(snapshot.docs, (DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // 自分のuidかどうかの判定処理
      bool isMe;
      String? myUid = SharedPrefs.getUid();
      if (data['sender_id'] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(data['message'], isMe, data['send_time']);
      messageList.add(message);
    });
    // メッセージの時間によって並べ変える
    messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));
    return messageList;
  }

  static Future<void>? sendMessage(String roomId, String message) async {
    // Firestoreの'room'のdocにあるIDのコレクションにある'message'にアクセス
    final messageRef =
        _firestoreInstance.collection('room').doc(roomId).collection('message');
    // 自分のuidを取得
    String? myUid = SharedPrefs.getUid();
    await messageRef.add({
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot>? messageSnapshot(String roomId) {
    // コレクションのmessageに何かしら値が入ってきた場合、画面を更新する。
    return _firestoreInstance
        .collection('room')
        .doc(roomId)
        .collection('message')
        .snapshots();
  }
}
