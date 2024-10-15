import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/bio_box.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/name_box.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_states.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  //current user
  late AppUser? currentUser = authCubit.currentUser;

  //on startup
  @override
  void initState() {
    super.initState();
    //loading user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        //loaded
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Page'),
              centerTitle: true,
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                //edit profile button
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            //Body
            body: SingleChildScrollView(
              child: Column(
                children: [
                  //email
                  Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),

                  const SizedBox(height: 25),
                  //profile pic
                  CachedNetworkImage(
                    imageUrl: user.profileImageUrl,
                    //loading
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),

                    //error
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    //loaded
                    imageBuilder: (context, imageProvider) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  //name box
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  NameBox(text: user.name),

                  //bio box
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text(
                          "Bio",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  BioBox(text: user.bio),

                  //posts
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 25),
                    child: Row(
                      children: [
                        Text(
                          "Posts",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No Profile found.."),
          );
        }
      },
    );
  }
}
