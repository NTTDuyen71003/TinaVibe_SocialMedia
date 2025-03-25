import 'package:get/get.dart';
import 'vi.dart';
import 'en.dart';

class TranslationService extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi': vi,
        'en': en,
      };
}
