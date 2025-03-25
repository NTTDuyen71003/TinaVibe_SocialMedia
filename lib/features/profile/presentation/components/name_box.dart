import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NameBox extends StatelessWidget {
  final String text;

  const NameBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: double.infinity,
      child: Text(
        text.isNotEmpty ? text : ("namestatus".tr),
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
