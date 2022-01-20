import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoomPage extends StatefulWidget {
  // トップページからユーザーを受け取る変数
  final User talkUser;
  TalkRoomPage(this.talkUser);
  //const TalkRoom({Key? key}) : super(key: key);

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  List<Message> messageList = [
    Message('Hello', true, DateTime(2022, 1, 1, 10, 20)),
    Message('안녕하세요ああああああああああああいいいいいいいいいいいいいいいいいいいいいいい', false,
        DateTime(2022, 1, 1, 11, 15)),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title:
            Text(widget.talkUser.name, style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: ListView.builder(
                // お互いのコメントが画面幅を超過した場合、スクロールできるようにする。
                physics: RangeMaintainingScrollPhysics(),
                shrinkWrap: true,
                reverse: true,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: messageList[index].isMe
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      children: [
                        Column(
                          children: [
                            Container(
                                // コメントの幅を6割程度にする。（コメントが長すぎたら改行する）
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.6),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: messageList[index].isMe
                                      ? Colors.greenAccent
                                      : Colors.yellow,
                                ),
                                child: Text(messageList[index].message)),
                            // 0120仮で書いたコード
                            Text(messageList[index].isMe
                                ? widget.talkUser.name
                                : ''),
                          ],
                        ),
                        Opacity(
                          opacity: 0.6,
                          child: Text(
                            intl.DateFormat('HH:mm')
                                .format(messageList[index].sendTime),
                            style:
                                TextStyle(fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
          // 入力ボックスのUI
          Align(
            // 入力ボックスを画面の下に配置する
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              color: Colors.orange,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
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
                    onPressed: () {
                      print('send');
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
        ],
      ),
    );
  }
}
