import 'package:dio/dio.dart';
import 'package:flutter_tenma_venture_http/config/http_config.dart';

class HttpBaseOptions extends BaseOptions {
  final CacheMode cacheMode;
  final bool isEncrypt;
  final bool isDebug;

  HttpBaseOptions({
    String method,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String baseUrl,
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType = ResponseType.json,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError = true,
    bool followRedirects = true,
    int maxRedirects = 5,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
    this.isEncrypt,
    this.isDebug,
    this.cacheMode,
  }) : super(
          baseUrl: baseUrl,
          queryParameters: queryParameters,
          connectTimeout: connectTimeout,
          method: method,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
          extra: extra,
          headers: headers,
          responseType: responseType,
          contentType: contentType,
          validateStatus: validateStatus,
          receiveDataWhenStatusError: receiveDataWhenStatusError,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          requestEncoder: requestEncoder,
          responseDecoder: responseDecoder,
        );
}
