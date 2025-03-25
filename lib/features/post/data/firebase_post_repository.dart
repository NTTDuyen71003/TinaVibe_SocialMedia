import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/comments.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/repository/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // lưu trữ bài viết trong collection có tên là posts
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  //update post
  @override
  Future<void> updatePost(
      String postId, Map<String, dynamic> updatedData) async {
    try {
      await postsCollection.doc(postId).update(updatedData);
    } catch (e) {
      throw Exception("Error updating post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();
      // chuyển đổi mỗi dữ liệu bài viết trên firestore từ dạng json -> danh sách bài viết
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return allPosts;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      //tìm và nạp dữ liệu theo id của người dùng
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();
      // chuyển đổi mỗi dữ liệu bài viết trên firestore từ dạng json -> danh sách bài viết
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception("Error fetching post bt user: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        // kiểm tra xem người dùng đã like bài viết này hay chưa
        final hasLiked = post.likes.contains(userId);

        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }

        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        // chuyển đối tượng json -> bài viết
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        // thêm bình luận
        post.comments.add(comment);
        // cập nhật lại dữ liệu của bài viết đó trên firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        // chuyển đối tượng json -> bài viết
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        //xoá bình luận
        post.comments.removeWhere((comment) => comment.id == commentId);
        // cập nhật lại dữ liệu của bài viết đó trên firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}
