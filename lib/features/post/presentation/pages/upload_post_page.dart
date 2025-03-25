import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/components/my_text_field.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/domain/entities/post.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/en.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/vi.dart';
import 'package:get/get.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  //mobile image pick
  PlatformFile? imagePickedFile;

  //web image pick
  Uint8List? webImage;

  // text controller -> caption
  final textController = TextEditingController();

  //current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  //get current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  //pick image
  /*kIsWeb
  - Nếu chạy trên web sẽ dùng webImage
  - Nếu không thì sử dụng thư viện imagePickedFile
  */
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // Modify the uploadPost method
  void uploadPost() {
    // Check if both image and caption are provided
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('error_post_upload'))));
      return;
    }

    // Create a new post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );
    //post cubit
    final postCubit = context.read<PostCubit>();

    //web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    //mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
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

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        //loading or uploading..
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        leading: Tooltip(
          message: ("goback_arrow".tr),
          child: IconButton(
            icon: const Icon(Icons.arrow_back), // Back arrow icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back when pressed
            },
          ),
        ),
        title: Text(translate('upload_post_title')),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Tooltip(
            message: translate(
                'upload_post_noti'), // Tooltip message to display on hover
            child: GestureDetector(
              onTap: uploadPost, // Trigger the uploadPost function
              child: Container(
                margin: const EdgeInsets.only(
                    right: 16), // Add some margin to the right
                decoration: const BoxDecoration(
                  color: Color(0xfff36f7d), // Circle color
                  shape: BoxShape.circle, // Circular shape
                ),
                padding: const EdgeInsets.all(
                    8), // Padding to increase the circle size
                child: const Icon(
                  Icons.upload, // Upload icon
                  color: Colors.white, // Icon color set to white
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the selected image
              if (kIsWeb && webImage != null)
                Image.memory(webImage!, height: 300, fit: BoxFit.cover),
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!),
                    height: 300, fit: BoxFit.cover),

              const SizedBox(height: 16), // Space between image and button

              // Pick Image Button
              OutlinedButton(
                onPressed: pickImage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xfff36f7d)), // Border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0), // Vertical padding
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the button's content
                  children: [
                    const Icon(Icons.photo,
                        color: Color(0xfff36f7d)), // Icon color
                    const SizedBox(width: 8), // Space between icon and text
                    Text(
                      translate('upload_choose_image'),
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xfff36f7d)), // Text color
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16), // Space before the caption text box

              // Caption Text Box
              MyTextField(
                controller: textController,
                hintText: translate('upload_post_status'),
                obscureText: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
