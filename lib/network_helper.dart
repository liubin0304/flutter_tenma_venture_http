import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_tenma_venture_http/config/http_base_options.dart';
import 'package:flutter_tenma_venture_http/config/http_config.dart';
import 'package:flutter_tenma_venture_http/service/http_service.dart';
import 'package:flutter_tenma_venture_http/utils/data_base_utils.dart';

class NetworkHelper {
  Dio _dio;

  // 服务器地址
  String baseUrl = "";

  // 是否加密
  bool isEncrypt = false;

  // 是否是调试模式
  bool isDebug = false;

  // header
  Map<String, dynamic> headers = {};

  // 连接超时时间
  int connectTimeout = 60 * 1000;

  // 连接超时时间
  int receiveTimeout = 60 * 1000;

  // ContentType
  String contentType = Headers.jsonContentType;

  // 响应数据类型
  ResponseType responseType = ResponseType.json;

  // 是否开启Cookie：默认不开启
  bool isCookie = false;

  // 缓存类型：默认不缓存
  CacheMode cacheMode = CacheMode.NO_CACHE;

  // 拦截器
  List<InterceptorsWrapper> interceptors;

  // 是否强制更新所有配置
  bool isForce = false;

  factory NetworkHelper() => _getInstance();

  static NetworkHelper _instance;

  static NetworkHelper _getInstance() {
    if (_instance == null) {
      _instance = NetworkHelper._init();
    }
    return _instance;
  }

  NetworkHelper._init() {
    print("NetworkHelper._init");
  }

  NetworkHelper setBaseUrl(String baseUrl) {
    this.baseUrl = baseUrl;
    return this;
  }

  NetworkHelper setDebug(bool isDebug) {
    this.isDebug = isDebug;
    return this;
  }

  NetworkHelper setCookie(bool isCookie) {
    this.isCookie = isCookie;
    return this;
  }

  NetworkHelper setEncrypt(bool isEncrypt) {
    this.isEncrypt = isEncrypt;
    return this;
  }

  NetworkHelper setHeaders(Map<String, dynamic> headers) {
    this.isEncrypt = isEncrypt;
    return this;
  }

  NetworkHelper setConnectTimeout(int connectTimeout) {
    this.connectTimeout = connectTimeout;
    return this;
  }

  NetworkHelper setReceiveTimeout(int receiveTimeout) {
    this.receiveTimeout = receiveTimeout;
    return this;
  }

  NetworkHelper setContentType(String contentType) {
    this.contentType = contentType;
    return this;
  }

  NetworkHelper setResponseType(ResponseType responseType) {
    this.responseType = responseType;
    return this;
  }

  NetworkHelper setCacheMode(CacheMode cacheMode) {
    this.cacheMode = cacheMode;
    return this;
  }

  NetworkHelper addInterceptors(List<InterceptorsWrapper> interceptors) {
    this.interceptors = interceptors;
    return this;
  }

  NetworkHelper setForce(bool isForce) {
    this.isForce = isForce;
    return this;
  }

  Future<bool> build() async {
    try {
      if (_dio == null || isForce) {
        // 设置 Dio 默认配置
        _dio = Dio(HttpBaseOptions(
            // 请求基地址
            baseUrl: baseUrl,
            // ContentType
            contentType: contentType,
            // 连接服务器超时时间，单位是毫秒
            connectTimeout: connectTimeout,
            // 接收数据的最长时限
            receiveTimeout: receiveTimeout,
            // 响应数据类型
            responseType: responseType,
            // Http请求头
            headers: headers,
            // 缓存类型
            cacheMode: cacheMode,
            // 是否是调试模式
            isDebug: isDebug,
            // 是否加密
            isEncrypt: isEncrypt));

        if (interceptors != null) {
          _dio.interceptors.addAll(interceptors);
        }

        if (isCookie) {
          _dio.interceptors.add(CookieManager(CookieJar()));
        }

        if (cacheMode != CacheMode.NO_CACHE) {
          await DatabaseUtil.initDatabase().then((value) => {
                if (value == "DatabaseReady") {LogUtil.v("DatabaseReady")}
              });
        }

        LogUtil.init(isDebug: isDebug);

        // HttpConfig.isEncrypt = isEncrypt;
        HttpConfig.isDebug = isDebug;
        // HttpConfig.cacheMode = cacheMode;
        //
        DioManager().init(_dio);
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
