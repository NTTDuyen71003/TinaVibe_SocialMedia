import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final VoidCallback? onPostsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    this.onPostsTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    // Text style for count
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary);

    // Text style for text
    var textStyleForText =
        TextStyle(color: Theme.of(context).colorScheme.primary);

    return MouseRegion(
      cursor: SystemMouseCursors.click, // Change cursor on hover
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Posts
          GestureDetector(
            onTap: onPostsTap,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    postCount.toString(),
                    style: textStyleForCount, // Adjust the font size here
                  ),
                  Text(
                    ("bio_post_status".tr),
                    style: textStyleForText.copyWith(
                        fontSize: 12), // Adjust the font size here
                  ),
                ],
              ),
            ),
          ),

          // Followers
          GestureDetector(
            onTap: onFollowersTap,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    followerCount.toString(),
                    style: textStyleForCount, // Adjust the font size here
                  ),
                  Text(
                    ("follower_status".tr),
                    style: textStyleForText.copyWith(
                        fontSize: 12), // Adjust the font size here
                  ),
                ],
              ),
            ),
          ),

          // Following
          GestureDetector(
            onTap: onFollowingTap,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    followingCount.toString(),
                    style: textStyleForCount, // Adjust the font size here
                  ),
                  Text(
                    ("following_status".tr),
                    style: textStyleForText.copyWith(
                        fontSize: 12), // Adjust the font size here
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
