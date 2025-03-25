import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/components/post_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/bio_box.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/follow_button.dart';
// import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/name_box.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/profile_stats.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/follower_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/light_mode.dart';
import 'package:get/get.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  final ScrollController _scrollController = ScrollController();

  // Current user
  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
    // Load user profile data
    profileCubit.fetchUserProfile(widget.uid);
    // Fetch all posts
    context.read<PostCubit>().fetchAllPosts();
  }

  // Follow/unfollow
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) return;

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // Optimistically update UI
    setState(() {
      isFollowing
          ? profileUser.followers.remove(currentUser!.uid)
          : profileUser.followers.add(currentUser!.uid);
    });

    // Perform actual toggle in cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      // Revert update if there's an error
      setState(() {
        isFollowing
            ? profileUser.followers.add(currentUser!.uid)
            : profileUser.followers.remove(currentUser!.uid);
      });
    });
  }

  //refesh dữ liệu
  void fetchCurrentUserProfile() {
    profileCubit.fetchUserProfile(currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final user = state.profileUser;
          final isOwnProfile = widget.uid == currentUser!.uid;

          return Scaffold(
            appBar: AppBar(
              // leading: Tooltip(
              //   message: ("goback_arrow"
              //       .tr), // Translated tooltip for the back button
              //   child: IconButton(
              //     icon: const Icon(Icons.arrow_back), // Back arrow icon
              //     onPressed: () {
              //       Navigator.of(context).pop(); // Go back when pressed
              //     },
              //   ),
              // ),
              title: Text("profile_title".tr),
              centerTitle: true,
              actions: [
                if (isOwnProfile) // Show edit button only for own profile
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        ),
                      );
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              controller: _scrollController, // Attach ScrollController
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Profile Image
                            CachedNetworkImage(
                              imageUrl: user.profileImageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 75,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CustomThemeData.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Email
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Profile Stats
                            BlocBuilder<PostCubit, PostState>(
                              builder: (context, postState) {
                                int postCount = 0;

                                if (postState is PostsLoaded) {
                                  // Filter posts by user id
                                  final userPosts = postState.posts
                                      .where(
                                          (post) => post.userId == widget.uid)
                                      .toList();
                                  postCount = userPosts.length;

                                  return ProfileStats(
                                    postCount: postCount,
                                    followerCount: user.followers.length,
                                    followingCount: user.following.length,
                                    onPostsTap: () {
                                      // Scroll to posts section logic
                                      _scrollController.animateTo(
                                        // Adjust this value to scroll to the posts section
                                        370.0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    onFollowersTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FollowerPage(
                                              followers: user.followers,
                                              following: user.following),
                                        ),
                                      ).then((_) {
                                        // Re-fetch the current user profile when returning
                                        fetchCurrentUserProfile();
                                      });
                                    },
                                    onFollowingTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FollowerPage(
                                              followers: user.followers,
                                              following: user.following),
                                        ),
                                      ).then((_) {
                                        // Re-fetch the current user profile when returning
                                        fetchCurrentUserProfile();
                                      });
                                    },
                                  );
                                }

                                // Handle loading or empty state
                                return ProfileStats(
                                  postCount: postCount,
                                  followerCount: user.followers.length,
                                  followingCount: user.following.length,
                                  onPostsTap: null,
                                  onFollowersTap: null,
                                  onFollowingTap: null,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Bio
                            BioBox(
                              text: user.bio.isNotEmpty
                                  ? user.bio
                                  : ("bio_profile".tr),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Follow Button
                  if (!isOwnPost)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FollowButton(
                        onPressed: followButtonPressed,
                        isFollowing: user.followers.contains(currentUser!.uid),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Posts Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ("bio_post_status".tr),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // List of Posts
                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, postState) {
                      if (postState is PostsLoaded) {
                        final userPosts = postState.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();

                        if (userPosts.isEmpty) {
                          return Center(
                              child: Text(("post_profile_status".tr)));
                        }

                        return ListView.builder(
                          itemCount: userPosts.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];
                            return PostTile(
                              post: post,
                              onDeletePressed: () =>
                                  context.read<PostCubit>().deletePost(post.id),
                            );
                          },
                        );
                      } else if (postState is PostsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Center(
                            child: Text(("post_profile_notfound".tr)));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text(("user_profile_notfound".tr)));
        }
      },
    );
  }
}
