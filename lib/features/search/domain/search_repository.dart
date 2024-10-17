import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';

abstract class SearchRepository {
  Future<List<ProfileUser?>> searchUsers(String query);
}
