import 'dart:io';

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

  Future<void>? getImageFromGallery() async {
    // スマホの写真フォルダから写真を選択する
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickerFile != null) {
      // 取得してきた写真をimageに入れる
      image = File(pickerFile.path);
      uploadImage();
      // 写真を表示する
      setState(() {});
    }
  }

  // 写真をStorageにアップロードする
  Future<String?> uploadImage() async {
    final ref = FirebaseStorage.instance.ref('test.png');
    final storedImage = await ref.putFile(image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProFile'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
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
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
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
                        onPressed: () {
                          getImageFromGallery();
                        },
                        child: Text('画像を選択'),
                        style: ElevatedButton.styleFrom(primary: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 50),
            // 画像が選択されていなかった場合、何も表示しない
            image == null
                ? Container(
                    width: 200,
                    height: 200,
                    child: Icon(Icons.favorite),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    child: Image.file(
                      image!,
                      fit: BoxFit.fill,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
