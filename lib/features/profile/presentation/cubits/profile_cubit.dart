import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/profile_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/domain/entities/repository/profile_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/storage/domain/storage_repository.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepository profileRepository;
  final StorageRepository storageRepository;

  ProfileCubit({
    required this.profileRepository,
    required this.storageRepository,
  }) : super(ProfileInitial());

  //fetch user profile using repo -> useful for loading profile pages
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepository.fetchUserProfile(uid);
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //return user profile given uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepository.fetchUserProfile(uid);
    return user;
  }

  // update name, bio and profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? newName,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      //fetch current profile first
      final currentUser = await profileRepository.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      // profile picture update
      String? imageDownloadUrl;
      //ensure there is an image
      if (imageWebBytes != null || imageMobilePath != null) {
        //for mobile
        if (imageMobilePath != null) {
          //upload
          imageDownloadUrl = await storageRepository.uploadProfileImageMobile(
              imageMobilePath, uid);
        }
        //for web
        else if (imageWebBytes != null) {
          //upload
          imageDownloadUrl =
              await storageRepository.uploadProfileImageWeb(imageWebBytes, uid);
        }
        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }

      //update new Profile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newName: newName ?? currentUser.name,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );
      //update in repo
      await profileRepository.updateProfile(updatedProfile);

      //re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  // toggle follow/unfollow
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepository.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }
}
