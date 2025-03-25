import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/components/my_button.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:get/get.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextStyle textStyle;
  final Color borderColor;
  final Color backgroundColor;
  final Icon prefixIcon;
  final Widget? suffixIcon;
  final double borderWidth;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.textStyle,
    required this.borderColor,
    required this.backgroundColor,
    required this.prefixIcon,
    this.suffixIcon,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: backgroundColor,
      ),
      style: textStyle,
    );
  }
}

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void register() {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        authCubit.register(name, email, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(("register_restrict_pass".tr))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(("register_restrict".tr))),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Logo_TinaVibe.png',
                    height: 100,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    ("login_navigate".tr),
                    style: TextStyle(
                      color: Colors.pink.shade200,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ("register_form_banner".tr),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: nameController,
                    hintText: ("register_user_input".tr),
                    obscureText: false,
                    textStyle: TextStyle(
                        color:
                            Colors.pink.shade200), // Change text color to pink
                    borderColor: Colors.pink.shade200,
                    backgroundColor: Colors.white,
                    prefixIcon: Icon(Icons.person, color: Colors.pink.shade200),
                    borderWidth: 2.0, // Set border thickness
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    textStyle: TextStyle(color: Colors.pink.shade200),
                    borderColor: Colors.pink.shade200,
                    backgroundColor: Colors.white,
                    prefixIcon: Icon(Icons.email, color: Colors.pink.shade200),
                    borderWidth: 2.0, // Set border thickness
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: passwordController,
                    hintText: ("login_input_pass".tr),
                    obscureText: !isPasswordVisible,
                    textStyle: TextStyle(color: Colors.pink.shade200),
                    borderColor: Colors.pink.shade200,
                    backgroundColor: Colors.white,
                    prefixIcon: Icon(Icons.lock, color: Colors.pink.shade200),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.pink.shade200,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    borderWidth: 2.0,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: ("register_input_confirmpass".tr),
                    obscureText: !isConfirmPasswordVisible,
                    textStyle: TextStyle(color: Colors.pink.shade200),
                    borderColor: Colors.pink.shade200,
                    backgroundColor: Colors.white,
                    prefixIcon: Icon(Icons.lock, color: Colors.pink.shade200),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.pink.shade200,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                    borderWidth: 2.0, // Set border thickness
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    onTap: register,
                    text: ("login_navigate".tr),
                    color: Colors.pink.shade200,
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(("register_navigate_text".tr),
                          style: const TextStyle(color: Colors.black)),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          ("login_form_title".tr),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 40,
                    width: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().signInWithGoogle();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xFFF3ECEC)),
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 8)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(color: Color(0xFFFBF8FB)),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
