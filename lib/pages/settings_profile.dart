import 'dart:io';

import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsProfilePage extends StatefulWidget {
  const SettingsProfilePage({Key? key}) : super(key: key);

  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  File? image;
  // ImagePickerのインスタンス
  ImagePicker picker = ImagePicker();

  String? imagePath;
  // 送信するテキストに何かしらの値が入ってきた場合の処理の管理
  TextEditingController controller = TextEditingController();

  //0206
  User? myProfile;
  //0206
  Future<User?> getMyImage() async {
    String? myUid = SharedPrefs.getUid();
    myProfile = await Firestore.getProfile(myUid!);
  }

  bool isUpdate() {
    return myProfile != null;
  }

  Future<void>? getImageFromGallery() async {
    // スマホの写真フォルダから写真を選択する
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickerFile != null) {
      // 取得してきた写真をimageに入れる
      image = File(pickerFile.path);
      await uploadImage();
      // 写真を表示する
      setState(() {});
    }
  }

  // 写真をStorageにアップロードする
  Future<String?> uploadImage() async {
    final ref = FirebaseStorage.instance.ref('testq.png');
    final storedImage = await ref.putFile(image!);
    imagePath = await loadImage(storedImage);
    return imagePath;
  }

  // 画像のURLの取得
  Future<String?> loadImage(TaskSnapshot storedImage) async {
    String downloadUrl = await storedImage.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール編集'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
          future: getMyImage(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 90, child: Text('Name')),
                      Container(
                        child: Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 36,
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: '${myProfile!.name}',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: Colors.white70,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // 画像選択UI
                  Row(
                    children: [
                      Container(width: 100, child: Text('Thumbnail')),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 110,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                await getImageFromGallery();
                              },
                              child: Text('画像を選択'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  // ここに自分の画像を表示させたい
                  Container(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(myProfile!.imagePath),
                    ),
                  ),
                  image == null
                      ? Container()
                      : Container(
                          width: 100,
                          height: 100,
                          child: Image.file(
                            image!,
                            fit: BoxFit.fill,
                          ),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black, //ボタンの背景色
                    ),
                    onPressed: isUpdate()
                        ? () async {
                            //ここで画像アップロード処理
                            User newProfile =
                                User(controller.text, '', imagePath!);
                            await Firestore.updeteProfile(newProfile);
                            print(controller.text);

                            if (controller.text == '') {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('名前もしくは画像を選択してください'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('編集しました'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        : null,
                    child: Text('Edit'),
                  )
                ],
              ),
            );
          }),
    );
  }
}
