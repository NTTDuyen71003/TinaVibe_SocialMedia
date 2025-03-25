import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:get/get.dart';

class EditPostPage extends StatefulWidget {
  final Post post;
  const EditPostPage({super.key, required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.post.text);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Get the updated data from the form
    final updatedData = {
      'text': textController.text,
    };

    // Call the updatePost method from PostCubit
    context.read<PostCubit>().updatePost(widget.post.id, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostUpdatedSuccess) {
          Navigator.pop(context);
        } else if (state is PostUpdatedError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update the post')),
          );
        }
      },
      builder: (context, state) {
        if (state is PostUpdating) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return buildEditPage();
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
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
        title: Text("edit_page_title".tr),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered label
            Center(
              child: Text(
                "edit_page_text".tr,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: textController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff36f7d),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "save_button_text".tr,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
