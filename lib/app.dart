import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/home/presentation/pages/home_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/data/firebase_post_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/data/firebase_profile_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/data/firebase_search_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/search/presentation/cubits/search_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/storage/data/firebase_storage_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/theme_cubit.dart';
import 'package:get/get.dart';
import 'translations/translation_service.dart';

/*
Bloc Providers: quản lý trạng thái
  -auth
  -profile
  -post
  -search
  -theme

  Kiểm tra trạng thái xác thực
  -unauthenticated -> chuyển tới trang login/register
  -authenticated -> sẽ chuyển tới Home page
*/
class MyApp extends StatelessWidget {
  // Repositories
  final firebaseAuthRepository = FirebaseAuthRepository();
  final firebaseProfileRepository = FirebaseProfileRepository();
  final firebaseStorageRepository = FirebaseStorageRepository();
  final firebasePostRepository = FirebasePostRepository();
  final firebaseSearchRepository = FirebaseSearchRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepository: firebaseAuthRepository)..checkAuth(),
        ),
        // Profile Cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepository: firebaseProfileRepository,
            storageRepository: firebaseStorageRepository,
          ),
        ),
        // Post Cubit
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepository: firebasePostRepository,
            storageRepository: firebaseStorageRepository,
          ),
        ),
        // Search Cubit
        BlocProvider<SearchCubit>(
          create: (context) =>
              SearchCubit(searchRepository: firebaseSearchRepository),
        ),
        // Theme Cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) => GetMaterialApp(
          // Use GetMaterialApp
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          translations: TranslationService(), // Add translation service
          locale: const Locale('vi'), // Set default locale
          fallbackLocale: const Locale('en'), // Set fallback locale
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Unauthenticated) {
                return const AuthPage();
              }
              if (authState is Authenticated) {
                return const HomePage();
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
