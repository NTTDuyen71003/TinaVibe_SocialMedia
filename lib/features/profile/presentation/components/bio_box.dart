import 'package:flutter/material.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/en.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/vi.dart';
import 'package:get/get.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  String translate(String key) {
    final locale = Get.locale?.languageCode; // Get current locale
    if (locale == 'vi') {
      return vi[key] ?? key; // Return Vietnamese translation if available
    } else {
      return en[key] ?? key; // Return English translation if available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: double.infinity,
      child: Text(
        text.isNotEmpty ? text : translate('bio_status'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
