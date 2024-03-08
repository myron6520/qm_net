import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class Client {
  static Dio get instance => DioForNative();
}
