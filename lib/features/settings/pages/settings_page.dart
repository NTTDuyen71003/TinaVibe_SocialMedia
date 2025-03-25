import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/themes/theme_cubit.dart';
import 'package:get/get.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_cubit.dart';
// Import AuthCubit

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr), // Use GetX translation
        backgroundColor: const Color(0xfff36f7d),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dark Mode Switch
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.dark_mode, color: Color(0xfff36f7d)),
                  title: Text("toggle_theme".tr,
                      style: const TextStyle(fontSize: 18)),
                  trailing: CupertinoSwitch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeCubit.toggleTheme();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Language Switch
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/language.png',
                            width: 24, // Set the width of the icon as needed
                            height: 24, // Set the height of the icon as needed
                            color: const Color(0xfff36f7d),
                          ),
                          const SizedBox(
                              width: 10), // Spacing between icon and text
                          Text(
                            "change_language".tr,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: Get.locale?.languageCode,
                        underline: const SizedBox(), // Hides the underline
                        isExpanded: false,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xfff36f7d)),
                        items: const [
                          DropdownMenuItem(
                            value: 'vi',
                            child: Text('Tiếng Việt'),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            Get.updateLocale(Locale(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Option
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xfff36f7d)),
                  title: Text(("logout".tr).tr,
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    context.read<AuthCubit>().logout(); // Perform logout
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Additional Settings can be added here in a similar card format
            ],
          ),
        ),
      ),
    );
  }
}
