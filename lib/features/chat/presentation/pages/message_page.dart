import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/data/chat_service.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/presentation/components/chat_bubble.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/chat/presentation/components/my_chat_text_field.dart';
import 'package:get/get.dart';

class MessagePage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const MessagePage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuthRepository _authRepository = FirebaseAuthRepository();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Tooltip(
          message: ("goback_arrow".tr),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(
          ('conversation_title'.tr),
        ),
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return FutureBuilder<AppUser?>(
      future: _authRepository.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        AppUser? currentUser = snapshot.data;
        if (currentUser == null) {
          return const Center(child: Text("User not logged in."));
        }

        String senderID = currentUser.uid;
        return StreamBuilder(
          stream: _chatService.getMessages(widget.receiverID, senderID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading messages"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text(('status_chat'.tr)));
            }

            return ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: snapshot.data!.docs
                  .map((doc) => _buildMessageItem(doc))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return FutureBuilder<AppUser?>(
      future: _authRepository.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error occurred");
        }

        AppUser? currentUser = snapshot.data;

        if (currentUser == null) {
          return const SizedBox(); // Return an empty widget if user is not logged in
        }

        bool isCurrentUser = data['senderID'] == currentUser.uid;
        var alignment =
            isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

        return Container(
          alignment: alignment,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ChatBubble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                messageId: doc.id,
                userId: data["senderID"],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: MyChatTextField(
              controller: _messageController,
              hintText: ('chat_send_field'.tr),
              obscureText: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xfff36f7d),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
