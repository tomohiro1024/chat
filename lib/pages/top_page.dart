import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/pages/settings_profile.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom>? talkUserList = [];

  // ルーム作成メソッド
  Future<void>? createRooms() async {
    // 自分のuidを取得
    String? myUid = SharedPrefs.getUid();
    // 自分のuidをgetRooms()に送る
    talkUserList = await Firestore.getRooms(myUid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Talk', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsProfilePage()));
            },
            icon: Icon(
              Icons.edit,
              color: Colors.black,
              size: 30,
            ),
          )
        ],
      ),
      // createRooms()が完了したら下記を実行
      // 時間がかかる処理はFutureBuilderのfutureプロパティを使用する。
      // StreamBuilderを使用することによってroomに値の更新などが反映されるようになる。
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.roomSnapshot,
          builder: (context, snapshot) {
            return FutureBuilder(
                future: createRooms(),
                builder: (context, snapshot) {
                  // この処理が干渉した場合、ifの中身を表示し、elseでは処理が完了するまではグルグルを表示する
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        itemCount: talkUserList?.length,
                        itemBuilder: (context, index) {
                          // InkWellはchildの中身を押下できるようにするウィジェット
                          return InkWell(
                            onTap: () {
                              print(talkUserList![index].roomId);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TalkRoomPage(
                                          talkUserList![index].talkUser)));
                            },
                            child: Container(
                              height: 90,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          'https://pbs.twimg.com/media/EtsT0zYVgAIIu1Y.jpg'),
                                      radius: 40,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        talkUserList![index].talkUser.name,
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        'q',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                });
          }),
    );
  }
}
