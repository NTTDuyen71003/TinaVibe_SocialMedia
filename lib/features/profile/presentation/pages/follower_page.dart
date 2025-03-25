import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/user_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:get/get.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage(
      {super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Tooltip(
            message:
                ("goback_arrow".tr), // Translated tooltip for the back button
            child: IconButton(
              icon: const Icon(Icons.arrow_back), // Back arrow icon
              onPressed: () {
                Navigator.of(context).pop(); // Go back when pressed
              },
            ),
          ),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: ("follower_status".tr)),
              Tab(text: ("following_status".tr)),
            ],
          ),
        ),
        //Tab bar view
        body: TabBarView(children: [
          _buildUserList(followers, ("no_follower_status".tr), context),
          _buildUserList(following, ("no_following_status".tr), context),
        ]),
      ),
    );
  }

  //build user list, given a list of profile uids
  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];
              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return UserTile(user: user);
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text(("loading_status".tr)),
                    );
                  } else {
                    return ListTile(
                      title: Text(("user_notfound_error".tr)),
                    );
                  }
                },
              );
            },
          );
  }
}
