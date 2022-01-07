import 'package:chat_app/model/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoom extends StatefulWidget {
  // トップページから名前を受け取る変数
  final String name;
  TalkRoom(this.name);
  //const TalkRoom({Key? key}) : super(key: key);

  @override
  _TalkRoomState createState() => _TalkRoomState();
}

class _TalkRoomState extends State<TalkRoom> {
  List<Message> messageList = [
    Message('Hello', true, DateTime(2022, 1, 1, 10, 20)),
    Message('안녕하세요', false, DateTime(2022, 1, 1, 11, 15)),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.name, style: TextStyle(color: Colors.black)),
      ),
      body: ListView.builder(
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            return Row(
              textDirection: messageList[index].isMe
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              children: [
                Container(
                    color: messageList[index].isMe
                        ? Colors.greenAccent
                        : Colors.yellow,
                    child: Text(messageList[index].message)),
                Text(intl.DateFormat('HH:mm')
                    .format(messageList[index].sendTime)),
              ],
            );
          }),
    );
  }
}
