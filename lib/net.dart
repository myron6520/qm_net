import 'dart:io';

import 'package:dio/dio.dart';
import 'client/client.dart' if (dart.library.html) "client/client_web.dart" if (dart.library.io) "client/client_io.dart";
import 'resp.dart';

class Net {
  static int codeBadResponse = -1;
  static int codeSendTimeout = -1001;
  static int codeReceiveTimeout = -1002;
  static int codeCancel = -1003;
  static int codeConnectionError = -1004;
  static int codeConnectionTimeout = -1005;
  static int codeBadCertificate = -1006;
  static int codeUnknown = -1007;
  static Resp<T> Function<T>(DioException)? onError;
  static Future<Resp<T>> _handleError<T>(
    DioException e, {
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) async {
    return (Net.onError ??
            (DioException it) {
              String msg = it.message ?? "";
              int code = -1;
              switch (it.type) {
                case DioExceptionType.sendTimeout:
                  msg = "发送超时";
                  code = codeSendTimeout;
                  break;
                case DioExceptionType.receiveTimeout:
                  msg = "接收超时";
                  code = codeReceiveTimeout;
                  break;
                case DioExceptionType.cancel:
                  msg = "请求被取消";
                  code = codeCancel;
                  break;
                case DioExceptionType.connectionError:
                  msg = "连接错误";
                  code = codeConnectionError;
                  break;
                case DioExceptionType.connectionTimeout:
                  msg = "连接超时";
                  code = codeConnectionTimeout;
                  break;
                case DioExceptionType.badCertificate:
                  msg = "证书错误";
                  code = codeBadCertificate;
                  break;
                case DioExceptionType.badResponse:
                  return _handleResponse(
                    it.response,
                    convertFunc: convertFunc,
                    respConvertFunc: respConvertFunc,
                  );
                case DioExceptionType.unknown:
                  msg = "${it.error}";
                  code = codeUnknown;
                  break;
              }
              return Resp<T>(msg: msg, code: code);
            })
        .call(e);
  }

  static Resp<T> _handleResponse<T>(
    Response? res, {
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) {
    int code = res?.statusCode ?? codeBadResponse;
    String? msg = res?.statusMessage;
    if (respConvertFunc != null) {
      return respConvertFunc.call(res);
    }
    if (convertFunc != null) {
      return convertFunc.call(res?.data);
    }
    return Resp(data: res?.data as T, code: code, msg: msg);
  }

  static Future<Resp<T>> _try<T>(
    Future<Response?> Function() action,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  ) async {
    Response? res;
    try {
      res = await action();
    } catch (e) {
      if (e is DioException) {
        return _handleError(e, convertFunc: convertFunc, respConvertFunc: respConvertFunc);
      }
      return Resp();
    }

    return _handleResponse<T>(res, convertFunc: convertFunc, respConvertFunc: respConvertFunc);
  }

  static Future<Resp<T>> get<T>(
    String url, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) =>
      _try(
          () async => await Client.instance.get(
                url,
                cancelToken: cancelToken,
                data: params,
                options: Options(
                  headers: headers,
                ),
              ),
          convertFunc,
          respConvertFunc);
  static Future<Resp<T>> post<T>(
    String url, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) =>
      _try(
          () async => await Client.instance.post(
                url,
                cancelToken: cancelToken,
                data: params,
                options: Options(
                  headers: headers,
                ),
              ),
          convertFunc,
          respConvertFunc);

  static Future<Resp<T>> form<T>(
    String url, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _try(
          () async => await Client.instance.post(url,
              data: params, //FormData.fromMap(params),
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress,
              options: Options(headers: headers, followRedirects: false, validateStatus: (code) => (code ?? 0) < 500, contentType: ContentType.parse("application/x-www-form-urlencoded").value)),
          convertFunc,
          respConvertFunc);
  static Future<Resp<T>> put<T>(
    String url, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) =>
      _try(
          () async => await Client.instance.put(
                url,
                cancelToken: cancelToken,
                data: params,
                options: Options(
                  headers: headers,
                ),
              ),
          convertFunc,
          respConvertFunc);
  static Future<Resp<T>> delete<T>(
    String url, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
  }) =>
      _try(
          () async => await Client.instance.delete(
                url,
                cancelToken: cancelToken,
                data: params,
                options: Options(
                  headers: headers,
                ),
              ),
          convertFunc,
          respConvertFunc);
  static Future<Resp<T>> download<T>(
    String url,
    String savePath, {
    required dynamic params,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Resp<T> Function(Map dataMap)? convertFunc,
    Resp<T> Function(Response? res)? respConvertFunc,
    ProgressCallback? onReceiveProgress,
  }) =>
      _try(
          () async => await Client.instance.download(url, savePath,
              queryParameters: params,
              cancelToken: cancelToken,
              onReceiveProgress: onReceiveProgress,
              options: Options(
                responseType: ResponseType.stream,
                followRedirects: false,
                headers: headers,
              )),
          convertFunc,
          respConvertFunc);
}
