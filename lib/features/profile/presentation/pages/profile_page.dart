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
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/name_box.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/profile_stats.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/follower_page.dart';
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

  @override
  Widget build(BuildContext context) {
    // Check if the user is the current user
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final user = state.profileUser;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Page'),
              centerTitle: true,
              actions: [
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user)),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text(user.email,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 25),
                  CachedNetworkImage(
                    imageUrl: user.profileImageUrl,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.person,
                        size: 72, color: Theme.of(context).colorScheme.primary),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover)),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Profile stats
                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, postState) {
                      int postCount = 0;

                      if (postState is PostsLoaded) {
                        // Filter posts by user id
                        final userPosts = postState.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();
                        postCount = userPosts.length;

                        return ProfileStats(
                          postCount: postCount,
                          followerCount: user.followers.length,
                          followingCount: user.following.length,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowerPage(
                                  followers: user.followers,
                                  following: user.following),
                            ),
                          ),
                        );
                      }

                      // Handle loading or empty state
                      return ProfileStats(
                        postCount: postCount,
                        followerCount: user.followers.length,
                        followingCount: user.following.length,
                        onTap: null,
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // Follow button
                  if (!isOwnPost)
                    SizedBox(
                      width: 350,
                      height: 60,
                      child: FollowButton(
                        onPressed: followButtonPressed,
                        isFollowing: user.followers.contains(currentUser!.uid),
                      ),
                    ),

                  // Name box
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text("Name",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  NameBox(text: user.name),

                  // Bio box
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text("Bio",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  BioBox(text: user.bio),

                  // Posts section
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 25),
                    child: Row(
                      children: [
                        Text("Posts",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // List of posts from this user
                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, postState) {
                      if (postState is PostsLoaded) {
                        final userPosts = postState.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();

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
                        return const Center(child: Text("No posts.."));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text("No Profile found.."));
        }
      },
    );
  }
}
