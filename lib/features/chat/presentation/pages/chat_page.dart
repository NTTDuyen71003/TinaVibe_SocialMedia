import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/data/chat_service.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/presentation/pages/message_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/data/firebase_profile_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final FirebaseProfileRepository _profileRepository =
      FirebaseProfileRepository();
  String _searchQuery = ""; // State variable for search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        leading: Tooltip(
          message: ("goback_arrow".tr),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(('chat_form_title'.tr)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style: const TextStyle(color: Colors.black), // Text color
              decoration: InputDecoration(
                hintText: ('search_user'.tr),
                hintStyle:
                    const TextStyle(color: Colors.black54), // Hint text color
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Update search query
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _getCurrentUser(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (authSnapshot.hasError || authSnapshot.data == null) {
            return const Center(
                child: Text("Error loading user authentication"));
          }

          final currentUser = authSnapshot.data;

          if (currentUser == null) {
            return const Center(child: Text("User not logged in"));
          }

          return FutureBuilder<ProfileUser?>(
            future: _profileRepository.fetchUserProfile(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Center(child: Text("Error loading user profile"));
              }

              final profileUser = snapshot.data;

              if (profileUser == null) {
                return const Center(child: Text("Profile not found"));
              }

              return RefreshIndicator(
                onRefresh: _refreshUserList,
                child: _buildUserList(profileUser.email),
              );
            },
          );
        },
      ),
    );
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshUserList() async {
    setState(() {});
  }

  Widget _buildUserList(String currentUserEmail) {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        final filteredUsers = snapshot.data!
            .where((userData) =>
                userData["email"] != currentUserEmail &&
                (userData["name"].toLowerCase().contains(_searchQuery) ||
                    userData["email"].toLowerCase().contains(_searchQuery)))
            .toList();

        if (filteredUsers.isEmpty) {
          return Center(child: Text('no_user_found'.tr));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          children: filteredUsers
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userData["profileImageUrl"] ?? ''),
          radius: 24,
        ),
        title: Text(
          userData["name"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(userData["email"]),
        trailing: userData['unreadCount'] > 0
            ? CircleAvatar(
                backgroundColor: Colors.red,
                radius: 12,
                child: Text(
                  userData['unreadCount'].toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
        onTap: () async {
          await _chatService.markMessagesAsRead(userData["uid"]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagePage(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          ).then((_) {
            _refreshUserList();
          });
        },
      ),
    );
  }
}
