import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ApBar extends StatefulWidget {
  const ApBar({Key? key}) : super(key: key);

  @override
  State<ApBar> createState() => _ApBarState();
}

class _ApBarState extends State<ApBar> {
  File? profilepic;
  String downloadurl = '';

  SelectImage() async {
    try {
      XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        File convertedFile = File(selectedImage.path);
        setState(() {
          profilepic = convertedFile;
        });
        log("Image Selected!");
      } else {
        log("No Image Selected!");
      }
    } catch (e) {
      print(e);
    }
  }

  UpLoad() async {
    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("ProfilePictures")
          .child(Uuid().v1())
          .putFile(profilepic!);

      TaskSnapshot taskSnapshot = await uploadTask;
      downloadurl = await taskSnapshot.ref.getDownloadURL();

      FirebaseFirestore.instance.collection("Users").add({
        "ProfilePic": downloadurl,
      });
      setState(() {
        profilepic = null;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Storage"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    SelectImage();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 80,
                    backgroundImage:
                        (profilepic != null) ? FileImage(profilepic!) : null,
                  ),
                ),
                MaterialButton(
                  color: Colors.red,
                  child: Text("UpLoad"),
                  onPressed: () {
                    UpLoad();
                  },
                ),
              ],
            ),
            Visibility(
              visible: downloadurl != '',
              child: SizedBox(width: 200, child: Image.network(downloadurl)),
            ),
            // Expanded(
            //   child: StreamBuilder<QuerySnapshot>(
            //     stream:
            //         FirebaseFirestore.instance.collection("Users").snapshots(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         return ListView.builder(
            //             shrinkWrap: true,
            //             physics: ScrollPhysics(),
            //             itemCount: snapshot.data!.docs.length,
            //             itemBuilder: (context, index) {
            //               QueryDocumentSnapshot a = snapshot.data!.docs[index];
            //               return ListTile(
            //                 title: Text("Abdul Khaliq"),
            //                 subtitle: Text("Engineer"),
            //                 leading: IconButton(
            //                   onPressed: () {},
            //                   icon: Icon(Icons.delete),
            //                 ),
            //                 trailing: CircleAvatar(
            //                   radius: 30,
            //                   backgroundImage: NetworkImage(a["ProfilePic"]),
            //                 ),
            //               );
            //             });
            //       } else {
            //         return Center(
            //           child: CircularProgressIndicator(),
            //         );
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
