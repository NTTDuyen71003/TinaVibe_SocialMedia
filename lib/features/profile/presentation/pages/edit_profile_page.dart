import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/components/my_text_field.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_states.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Mobile image pick
  PlatformFile? imagePickedFile;

  // Web image pick
  Uint8List? webImage;

  final bioTextController = TextEditingController();
  final nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameTextController.text = widget.user.name;
    bioTextController.text = widget.user.bio;
  }

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

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final String? newName =
        nameTextController.text.isNotEmpty ? nameTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    final updatedName = nameTextController.text.isNotEmpty
        ? nameTextController.text
        : widget.user.name;

    if (imagePickedFile != null || newBio != null || newName != null) {
      profileCubit.updateProfile(
        uid: uid,
        newName: updatedName,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
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
        title: Text(("edit_profile_title".tr)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xfff36f7d), width: 3),
                        ),
                        child: ClipOval(
                          child: (!kIsWeb && imagePickedFile != null)
                              ? Image.file(
                                  File(imagePickedFile!.path!),
                                  fit: BoxFit.cover,
                                )
                              : (kIsWeb && webImage != null)
                                  ? Image.memory(webImage!)
                                  : CachedNetworkImage(
                                      imageUrl: widget.user.profileImageUrl,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.person, size: 72),
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Color(0xfff36f7d),
                          radius: 18,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              // MyTextField(
              //   controller: nameTextController,
              //   hintText: "Enter your name",
              //   obscureText: false,
              // ),
              // const SizedBox(height: 20),

              // Bio
              MyTextField(
                controller: bioTextController,
                hintText: ("edit_profile_bio".tr),
                obscureText: false,
              ),
              const SizedBox(height: 40),

              // Save changes button
              ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xfff36f7d), // Set the background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white), // Set text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
