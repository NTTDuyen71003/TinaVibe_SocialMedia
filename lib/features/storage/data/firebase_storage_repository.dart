import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/storage/domain/storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;

  //mobile platform
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  //web platform
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  //mobile platforms(file)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      //get file
      final file = File(path);
      //final place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload
      final uploadTask = await storageRef.putFile(file);

      //get image dowload url
      final dowloadUrl = await uploadTask.ref.getDownloadURL();
      return dowloadUrl;
    } catch (e) {
      return null;
    }
  }

  //web platform (bytes)
  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      //final place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload
      final uploadTask = await storageRef.putData(fileBytes);

      //get image dowload url
      final dowloadUrl = await uploadTask.ref.getDownloadURL();
      return dowloadUrl;
    } catch (e) {
      return null;
    }
  }
}
