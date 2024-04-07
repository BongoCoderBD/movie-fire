import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Movie"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: image == null
                ? Center(
                    child: IconButton(
                      onPressed: () async {
                        image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                : Image.file(
                    File(
                      (image!.path),
                    ),
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                File imgFile = File(image!.path);
                // upload to stroage
                UploadTask _uploadTask =
                    storage.ref('images').child(image!.name).putFile(imgFile);

                TaskSnapshot snapshot = await _uploadTask;
                // get the image download link
                var imageUrl = await snapshot.ref.getDownloadURL();
                // store the image & name to our database
                FirebaseFirestore.instance.collection('moviesC').add(
                  {
                    'image': imageUrl,
                  },
                ).whenComplete(
                  () {
                    // after adding data to the database
                    Fluttertoast.showToast(msg: 'Added Successfully');
                    image = null;
                    Navigator.of(context).pop();
                  },
                );
              } catch (e) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }
}
