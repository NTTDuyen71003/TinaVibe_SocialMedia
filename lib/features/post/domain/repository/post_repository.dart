import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/comments.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
  Future<void> updatePost(String postId, Map<String, dynamic> updatedData);
}
