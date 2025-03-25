import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/components/user_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/presentation/cubits/search_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/presentation/cubits/search_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/en.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/vi.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

//ko tìm chính mình
  // void onSearchChanged() {
  //   final query = searchController.text;
  //   final user = context.read<AuthCubit>().currentUser; // Get the current user
  //   final String? uid = user?.uid; // Get the user's UID

  //   searchCubit.searchUsers(query, uid ?? ""); // Pass the UID to searchUsers
  // }

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: searchController,
            style: const TextStyle(
                color: Colors.black), // Set the text color to black
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              hintText: translate('search_user'),
              hintStyle: const TextStyle(
                  color: Colors.black), // Set hint text color to black
              filled: true,
              fillColor: Colors.grey[200], // Light grey background
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding:
                  const EdgeInsets.all(0), // Adjust padding as needed
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_search,
                        size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(translate('no_user_found'),
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              },
            );
          } else if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              translate('user_search_banner'),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
