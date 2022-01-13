import 'package:chat_app/model/user.dart';
import 'package:chat_app/pages/settings_profile.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<User> userList = [
    User('エレン', 'abc', 'https://pbs.twimg.com/media/EtsT0zYVgAIIu1Y.jpg'),
    User('メッシ', 'def', 'https://www.crank-in.net/img/db/1369427_1200.jpg'),
  ];

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
      body: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            // InkWellはchildの中身を押下できるようにするウィジェット
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TalkRoom(userList[index].name)));
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
                          userList[index].name,
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w500),
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
          }),
    );
  }
}
