import 'package:shared_preferences/shared_preferences.dart';

String? apiUrl;

Future<void> loadApiUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  apiUrl = prefs.getString('apiUrl');
}
