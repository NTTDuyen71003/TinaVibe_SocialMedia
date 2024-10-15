import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/home/presentation/pages/home_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/data/firebase_profile_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/storage/data/firebase_storage_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/light_mode.dart';

/*
APP - Root Level

Repositories: for the database
  -firebase

  Bloc Providers: for state management
  -auth
  -profile
  -search
  -post
  -theme

  Check Auth State
  -unauthenticated -> auth page(login/register)
  -authenticated -> home page

*/
class MyApp extends StatelessWidget {
  //auth repo
  final firebaseAuthRepository = FirebaseAuthRepository();
  //profile repo
  final firebaseProfileRepository = FirebaseProfileRepository();
  //storage repo
  final firebaseStorageRepository = FirebaseStorageRepository();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepository: firebaseAuthRepository)..checkAuth(),
        ),
        //profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepository: firebaseProfileRepository,
            storageRepository: firebaseStorageRepository,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            // unauthenticated -> auth page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }
            // authenticated -> home page
            if (authState is Authenticated) {
              return const HomePage();
            }
            //loading..
            else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
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
    );
  }
}
