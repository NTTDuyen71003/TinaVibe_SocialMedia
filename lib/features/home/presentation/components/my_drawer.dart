import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/home/presentation/components/my_drawer_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  //pop menu drawer
                  Navigator.of(context).pop();

                  //get current user id
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  // navigate to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid),
                    ),
                  );
                },
              ),
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {},
              ),
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {},
              ),
              const Spacer(),
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
