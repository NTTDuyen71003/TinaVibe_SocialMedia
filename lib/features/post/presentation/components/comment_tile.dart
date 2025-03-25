import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/comments.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/light_mode.dart';
import 'package:get/get.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  //current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_comment_title".tr),
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
              child: Text("post_time_cancel".tr),
            ),
          ),
          // Delete button with hover effect
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: () {
                context
                    .read<PostCubit>()
                    .deleteComment(widget.comment.postId, widget.comment.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xfff36f7d), // Default background
                foregroundColor:
                    CustomThemeData.getTextColor(context), // Default text color
              ),
              child: Text("post_time_confirm".tr),
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Username and delete icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User name
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      uid: widget.comment.userId,
                    ),
                  ),
                ),
                child: Text(
                  widget.comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Delete icon (only show if it's the user's own post)
              if (isOwnPost)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: showOptions,
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
              height: 5), // Spacing between username and comment text
          // Second row: Comment text
          Text(widget.comment.text),
          const SizedBox(height: 5), // Spacing before timestamp
          // Timestamp
          Text(
            _formatTimestamp(widget.comment.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
