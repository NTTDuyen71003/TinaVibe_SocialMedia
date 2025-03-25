import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/comments.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/components/comment_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/pages/edit_post_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/light_mode.dart';
import 'package:get/get.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  //current user
  AppUser? currentUser;
  //post user
  ProfileUser? postUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null && mounted) {
      // Kiểm tra thuộc tính `mounted`
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(("delete_post_noti".tr)),
        actions: [
          // Cancel button with hover effect
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300, // Default background
                foregroundColor: Colors.black, // Default text color
              ),
              child: Text(("delete_post_cancel".tr)),
            ),
          ),
          // Delete button with hover effect
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: () {
                widget.onDeletePressed!();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xfff36f7d), // Default background
                foregroundColor:
                    CustomThemeData.getTextColor(context), // Default text color
              ),
              child: Text(("delete_post_confirm".tr)),
            ),
          ),
        ],
      ),
    );
  }

  /* 
    LIKES POST
  */

  // comment text controller
  final commentTextController = TextEditingController();
  // Open dialog for all comments
  void showCommentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  ("comment_title_show".tr),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomThemeData.getTextColor(
                        context), // Darker color for better readability
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                    thickness: 1.2,
                    color: Colors.grey[300]), // Divider for separation
                const SizedBox(height: 10),

                // BlocBuilder to load comments inside the dialog
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostsLoaded) {
                      final post =
                          state.posts.firstWhere((p) => p.id == widget.post.id);
                      if (post.comments.isNotEmpty) {
                        return SizedBox(
                          height: 200, // Fixed height for the comment section
                          child: ListView.builder(
                            //ListView to show if all the comments over the size log,will appear a scollbar
                            itemCount:
                                post.comments.length, // Show all comments
                            itemBuilder: (context, index) {
                              final comment = post.comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top:
                                        10.0), // Added spacing between comments
                                child: CommentTile(comment: comment),
                              );
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20), // Center message
                          child: Text(
                            ("comment_form_status".tr),
                            style: const TextStyle(color: Colors.grey),
                          ), // Message if no comments
                        );
                      }
                    } else if (state is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PostsError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const SizedBox(); // Default case
                    }
                  },
                ),
                const SizedBox(height: 12),
                Divider(
                    thickness: 1.2,
                    color: Colors.grey[300]), // Another divider at the bottom
                const SizedBox(height: 10),
                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xfff36f7d), // Friendly color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
                    ),
                  ),
                  child: Text(
                    ("close_comment_form".tr),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

/* 
    COMMENTS POST
  */
  void addComment() {
    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    // giúp UI phương thức like xịn hơn ko cần phải dùng refetch user để load lại trang
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  // Thêm hàm hiển thị hình ảnh lớn
  void showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Đóng dialog khi nhấn
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    String locale = Get.locale?.languageCode ?? 'en'; // Get the current locale

    if (diff.inDays >= 30) {
      int months = (diff.inDays / 30).floor();
      String pluralSuffix = (locale == 'en' && months > 1) ? 's' : '';
      return '$months ${"post_time_month".tr}$pluralSuffix ${"post_time_ago".tr}';
    } else if (diff.inDays >= 7) {
      int weeks = (diff.inDays / 7).floor();
      String pluralSuffix = (locale == 'en' && weeks > 1) ? 's' : '';
      return '$weeks ${"post_time_week".tr}$pluralSuffix ${"post_time_ago".tr}';
    } else if (diff.inDays >= 1) {
      int days = diff.inDays;
      String pluralSuffix = (locale == 'en' && days > 1) ? 's' : '';
      return '$days ${"post_time_day".tr}$pluralSuffix ${"post_time_ago".tr}';
    } else if (diff.inHours >= 1) {
      int hours = diff.inHours;
      String pluralSuffix = (locale == 'en' && hours > 1) ? 's' : '';
      return '$hours ${"post_time_hour".tr}$pluralSuffix ${"post_time_ago".tr}';
    } else if (diff.inMinutes >= 1) {
      int minutes = diff.inMinutes;
      String pluralSuffix = (locale == 'en' && minutes > 1) ? 's' : '';
      return '$minutes ${"post_time_minute".tr}$pluralSuffix ${"post_time_ago".tr}';
    } else {
      return "post_time_now".tr; // Return "just now" or an equivalent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  uid: widget.post.userId,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert, // Menu icon
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: ("post_tasks_title".tr),
                      onSelected: (String choice) {
                        if (choice == 'edit') {
                          // Navigate to the edit post page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPostPage(post: widget.post),
                            ),
                          );
                        } else if (choice == 'delete') {
                          // Show delete confirmation or trigger delete
                          showOptions();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(("post_edit_title".tr)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(("post_delete_title".tr)),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showFullImage(widget.post.imageUrl),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(height: 430),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          //Post interact
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: showCommentsDialog,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(widget.post.comments.length.toString()),
                const Spacer(),
                Text(_formatTimestamp(widget.post.timestamp)),
              ],
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                // username
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                // text
                Expanded(
                  child: Text(widget.post.text),
                ),
              ],
            ),
          ),

          // New Comment Section
          Row(
            children: [
              // Current User Avatar
              // CachedNetworkImage(
              //   imageUrl: user.profileImageUrl,
              //   errorWidget: (context, url, error) => const CircleAvatar(
              //     radius: 20,
              //     child: Icon(Icons.person), // Adjust radius for consistency
              //   ),
              //   imageBuilder: (context, imageProvider) => Container(
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       image: DecorationImage(
              //         image: imageProvider,
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 8), // Reduced spacing for a closer look
              // Comment TextField
              Expanded(
                child: TextField(
                  controller: commentTextController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: ("comment_hidtext".tr),
                    hintStyle:
                        TextStyle(color: Colors.grey[600]), // Softer hint text
                    filled: true, // Make the TextField background white
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // More rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1, // Softer border color
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15), // Padding for better touch area
                  ),
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              // Send Button
              IconButton(
                icon: const Icon(Icons.send),
                color:
                    const Color(0xfff36f7d), // Friendly color for the send icon
                onPressed: () {
                  if (commentTextController.text.isNotEmpty) {
                    addComment();
                    commentTextController
                        .clear(); // Clear the text field after sending
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
