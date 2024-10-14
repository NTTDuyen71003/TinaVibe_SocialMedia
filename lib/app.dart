import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/pages/home_page.dart';
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
  final authRepository = FirebaseAuthRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthCubit(authRepository: authRepository)..checkAuth(),
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
