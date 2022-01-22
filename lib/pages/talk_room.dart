import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoomPage extends StatefulWidget {
  // トップページからユーザーを受け取る変数
  final TalkRoom room;
  TalkRoomPage(this.room);
  //const TalkRoom({Key? key}) : super(key: key);

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  List<Message>? messageList = [];
  // 送信するテキストに何かしらの値が入ってきた場合の処理の管理
  TextEditingController controller = TextEditingController();

  Future<void>? getMessage() async {
    messageList = await Firestore.getMessages(widget.room.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.room.talkUser.name,
            style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            // StreamBuilderを使用すればstream:に値が入ってくればbuilder:が動作する。
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.messageSnapshot(widget.room.roomId),
                builder: (context, snapshot) {
                  return FutureBuilder(
                      future: getMessage(),
                      builder: (context, snapshot) {
                        return ListView.builder(
                            // お互いのコメントが画面幅を超過した場合、スクロールできるようにする。
                            physics: RangeMaintainingScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: messageList?.length,
                            itemBuilder: (context, index) {
                              Message _message = messageList![index];
                              // Firestoreのmessageの中のtimestamp型をDateTimeにする。
                              DateTime sendTime = _message.sendTime.toDate();
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  textDirection: messageList![index].isMe
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            // コメントの幅を6割程度にする。（コメントが長すぎたら改行する）
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 6.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: messageList![index].isMe
                                                  ? Colors.greenAccent
                                                  : Colors.yellow,
                                            ),
                                            child: Text(
                                                messageList![index].message)),
                                        // 0120仮で書いたコード
                                        Text(messageList![index].isMe
                                            ? widget.room.talkUser.name
                                            : ''),
                                      ],
                                    ),
                                    Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        intl.DateFormat('HH:mm')
                                            .format(sendTime),
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      });
                }),
          ),
          // 入力ボックスのUI
          Align(
            // 入力ボックスを画面の下に配置する
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              color: Colors.orange,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    )),
                    IconButton(
                      onPressed: () async {
                        print('send');
                        // テキストボックスが空欄ではない場合メッセージを送る
                        if (controller.text.isNotEmpty) {
                          await Firestore.sendMessage(
                              widget.room.roomId, controller.text);
                        }
                        print(controller.text);
                        // テキストの内容を送信した場合、消す。
                        controller.clear();
                      },
                      icon: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
