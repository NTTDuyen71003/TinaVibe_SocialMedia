import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/domain/search_repository.dart';

class FirebaseSearchRepository implements SearchRepository {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try {
      // Chuyển đổi query về chữ thường
      final lowerCaseQuery = query.toLowerCase();

      // Lấy tất cả người dùng từ Firestore
      final result = await FirebaseFirestore.instance.collection("users").get();

      // Lọc ra những người dùng có tên chứa query không phân biệt chữ hoa thường
      final users = result.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .where((user) => user.name.toLowerCase().contains(lowerCaseQuery))
          .toList();

      return users;
    } catch (e) {
      throw Exception("Error searching users: $e");
    }
  }
}
