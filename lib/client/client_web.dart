import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

class Client {
  static Dio get instance => DioForBrowser();
}
