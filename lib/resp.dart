import 'package:flutter/foundation.dart';

class Resp<T> {
  static const int _respOk = 200;
  final T? data;
  final int code;
  final String? msg;
  final Map<dynamic, dynamic>? originalData;
  late bool Function(int code, String? msg) respCheckFunc;
  bool get isOK => respCheckFunc.call(code, msg);
  String get info => "$msg {code:$code}";
  Resp({this.data, this.code = -1, this.msg, this.originalData, bool Function(int code, String? msg)? respCheckFunc}) {
    this.respCheckFunc = respCheckFunc ?? ((c, _) => c == _respOk);
  }
}

enum RespStatus { ready, loading, ok, empty, error }

class RespProvider extends ChangeNotifier {
  RespStatus _status = RespStatus.ready;
  String msg = "";
  int code = 0;

  RespStatus get status => _status;
  set status(RespStatus status) {
    _status = status;
    notifyListeners();
  }

  void commit() {
    notifyListeners();
  }
}
