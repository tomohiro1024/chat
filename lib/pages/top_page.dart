import 'package:chat_app/model/user.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<User> userList = [
    User('エレン', 'abc', 'https://images.app.goo.gl/KsM5STvL5F5vRKnK9', 'hey'),
    User('メッシ', 'abc', 'https://images.app.goo.gl/KsM5STvL5F5vRKnK9', 'hey'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('トーク'),
      ),
      body: Center(child: Text('top画面')),
    );
  }
}
