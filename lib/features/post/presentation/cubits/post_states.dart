import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';

abstract class PostState {}

// initial
class PostsInitial extends PostState {}

// loading..
class PostsLoading extends PostState {}

// uploading..
class PostUploading extends PostState {}

class PostUpdating extends PostState {}

class PostUpdatedSuccess extends PostState {}

// error
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

// loaded
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

class PostUpdated extends PostState {
  final Post updatedPost;
  PostUpdated(this.updatedPost);
}

class PostUpdatedError extends PostState {
  final String error;
  PostUpdatedError(this.error);
}
