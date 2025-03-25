import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/home/presentation/pages/home_feed_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/presentation/pages/search_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/settings/pages/settings_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/pages/upload_post_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/light_mode.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/en.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/vi.dart';
import 'package:get/get.dart';

AppBar buildCustomAppBar(BuildContext context) {
  return AppBar(
    elevation: 0, // Optional: Remove shadow
    title: Row(
      children: [
        Image.asset(
          'assets/images/Logo_TinaVibe.png', // Path to the logo image
          height: 50,
          width: 150, // Adjust size as needed
        ),
        const SizedBox(width: 2), // Spacing between logo and text
      ],
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Image.asset(
          'assets/icons/chat.png', // Path to the custom icon
          width: 24, // Adjust the size as needed
          height: 24,
          color:
              Theme.of(context).colorScheme.onSurface, // Apply color if needed
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatPage(),
            ),
          );
        },
      ),
      // const SizedBox(width: 16),
      // IconButton(
      //   icon: Image.asset(
      //     'assets/icons/notification.png', // Path to the custom icon
      //     width: 24, // Adjust the size as needed
      //     height: 24,
      //     color:
      //         Theme.of(context).colorScheme.onSurface, // Apply color if needed
      //   ),
      //   onPressed: () {
      //     // Handle notification button action
      //   },
      // ),
    ],
    iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeFeedPage(),
    const SearchPage(),
    const SizedBox(), // Placeholder for the upload button
    const ProfilePage(uid: "placeholder"),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _onUploadButtonPressed(); // Special handling for the middle button
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onUploadButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadPostPage(),
      ),
    );
  }

  String translate(String key) {
    final locale = Get.locale?.languageCode; // Get current locale
    if (locale == 'vi') {
      return vi[key] ?? key; // Return Vietnamese translation if available
    } else {
      return en[key] ?? key; // Return English translation if available
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID to pass to the ProfilePage
    final user = context.read<AuthCubit>().currentUser;
    final String? uid = user?.uid;

    // Update the ProfilePage with the correct UID
    _pages[3] = ProfilePage(uid: uid ?? "placeholder");

    return Scaffold(
      appBar: buildCustomAppBar(context),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Prevents shifting of items
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: translate('search'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/post.png', // Path to the custom icon
              width: 35, // Adjust size as needed
              height: 35,
              fit: BoxFit.contain, // Ensure the image fits well
            ),
            label: translate('upload_post'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: translate('profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: translate('other'),
          ),
        ],
        selectedItemColor: CustomThemeData.iconSelectColor,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
