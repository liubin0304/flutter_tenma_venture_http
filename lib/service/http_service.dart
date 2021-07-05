import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tenma_venture_http/config/http_base_options.dart';
import 'package:flutter_tenma_venture_http/config/http_config.dart';
import 'package:flutter_tenma_venture_http/models/tm_ali_yun_token_model.dart';
import 'package:flutter_tenma_venture_http/utils/cache_utils.dart';
import 'package:flutter_tenma_venture_http/utils/date_utils.dart';
import 'package:flutter_tenma_venture_http/utils/oss_utils.dart';

import './tm_encryption_tool.dart';
import '../models/base_model.dart';

///http请求成功回调
typedef HttpSuccessCallback<T> = void Function(T data);

///失败回调
typedef HttpFailureCallback = void Function(int code, String msg);

/// 文件下载成功回调
typedef DownloadSuccessCallback<T> = void Function(T data);

/// 文件下载失败回调
typedef DownloadFailureCallback = void Function(dynamic onError);

///文件上传进度回调
typedef UploadFileProgressCallback = void Function(int received, int total);

/// 错误编码
class ErrCode {
  /// 成功
  static const SUCCESS = 200;

  /// 权限错误
  static const TOKEN_ERR = 20401;

  /// 网络请求超时
  static const DEVICE_TIMEOUT = 00;
}

/// Dio 请求方法
enum TMDioMethod {
  get,
  post,
  put,
  delete,
}

/// 网络工具类
class DioManager {
  // 单例
  factory DioManager() => _getInstance();

  static DioManager _instance;

  static DioManager _getInstance() {
    if (_instance == null) {
      _instance = DioManager._init();
    }
    return _instance;
  }

  Dio _dio;
  bool isDebug;

  DioManager._init() {
    print("DioManager._init");
  }

  /// 初始化
  void init(Dio dio) {
    if (_dio == null) {
      _dio = dio;

      // 请求与响应拦截器
      _dio.interceptors.add(OnReqResInterceptors());
      // 异常拦截器
      _dio.interceptors.add(OnErrorInterceptors());

      // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      //     (client) {
      //       client.findProxy = (url) {
      //         ///设置代理 电脑ip地址
      //         return "PROXY 192.168.2.1:8888";
      //       };
      //
      //       ///忽略证书
      //       client.badCertificateCallback =
      //           (X509Certificate cert, String host, int port) => true;
      // };

    }
  }

  /// get请求
  Future get(
      {@required String url,
      Map<String, dynamic> params,
      HttpSuccessCallback successCallBack,
      HttpFailureCallback errorCallBack,
      Map<String, dynamic> header}) async {
    return await requestHttp(url,
        method: TMDioMethod.get,
        params: params,
        successCallBack: successCallBack,
        errorCallBack: errorCallBack,
        header: header);
  }

  /// post 请求
  Future post(
      {@required String url,
      Map<String, dynamic> params,
      HttpSuccessCallback successCallBack,
      HttpFailureCallback errorCallBack,
      Map<String, dynamic> header}) async {
    return await requestHttp(url,
        method: TMDioMethod.post,
        params: params,
        successCallBack: successCallBack,
        errorCallBack: errorCallBack,
        header: header);
  }

  /// put 请求
  Future put(
      {@required String url,
      Map<String, dynamic> params,
      HttpSuccessCallback successCallBack,
      HttpFailureCallback errorCallBack,
      Map<String, dynamic> header}) async {
    return await requestHttp(url,
        method: TMDioMethod.put,
        params: params,
        successCallBack: successCallBack,
        errorCallBack: errorCallBack,
        header: header);
  }

  /// delete 请求
  Future delete({
    @required String url,
    Map<String, dynamic> params,
    HttpSuccessCallback successCallBack,
    HttpFailureCallback errorCallBack,
    Map<String, dynamic> header,
  }) async {
    return await requestHttp(url,
        method: TMDioMethod.delete,
        params: params,
        successCallBack: successCallBack,
        errorCallBack: errorCallBack,
        header: header);
  }

  /// 上传文件
  Future upload({
    @required String url,
    FormData formData,
    HttpSuccessCallback successCallBack,
    HttpFailureCallback errorCallBack,
    Map<String, dynamic> header,
    UploadFileProgressCallback uploadFileProgressCallback,
  }) async {
    return await requestHttp(url,
        method: TMDioMethod.post,
        formData: formData,
        successCallBack: successCallBack,
        errorCallBack: errorCallBack,
        header: header,
        uploadFileProgressCallback: uploadFileProgressCallback);
  }

  /// 文件下载
  Future download({
    @required String url,
    @required String savePath,
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> data,
    DownloadSuccessCallback successCallBack,
    DownloadFailureCallback errorCallBack,
    ProgressCallback onReceiveProgress,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options options,
  }) async {
    LogUtil.v(url);
    LogUtil.v(savePath);
    await _dio
        .download(url, savePath, onReceiveProgress: onReceiveProgress)
        .then((value) => {
              if (successCallBack != null) {successCallBack(value)}
            })
        .catchError((onError) {
      if (errorCallBack != null) {
        errorCallBack(onError);
      }
    });
  }

  /// Dio request 方法
  Future requestHttp(String url,
      {TMDioMethod method = TMDioMethod.get,
      Map<String, dynamic> params,
      FormData formData,
      HttpSuccessCallback successCallBack,
      HttpFailureCallback errorCallBack,
      UploadFileProgressCallback uploadFileProgressCallback,
      bool isUpload = false,
      Map<String, dynamic> header}) async {
    HttpBaseOptions httpBaseOptions = _dio.options as HttpBaseOptions;

    if (httpBaseOptions.isEncrypt) {
      Map enData = TMEncryptionTool.tm_encryption(params);

      if (enData['code'] != 200) {
        if (errorCallBack != null) {
          errorCallBack(enData['code'], enData['msg']);
        }
        return;
      }

      if (enData['headers'] != null) {
        Map headers = Map<String, dynamic>.from(enData['headers']);
        _dio.options.headers.addAll(headers);
      }
      if (enData['params'] != null) {
        params = Map<String, dynamic>.from(enData['params']);
      }
    }

    if (header != null && (header is Map)) {
      _dio.options.headers.addAll(header);
    }

    try {
      Response response;
      // 不同请求方法，不同的请求参数。按实际项目需求分，这里 get 是 queryParameters，其它用 data. FormData 也是 data
      // 注意: 只有 post 方法支持发送 FormData.

      if (httpBaseOptions.cacheMode == CacheMode.FIRST_CACHE_THEN_REQUEST) {
        getCacheCallback(url, params, successCallBack);
      }

      switch (method) {
        case TMDioMethod.get:
          response = await _dio.request(url,
              queryParameters: params, options: Options(method: 'get'));
          break;
        case TMDioMethod.put:
          response = await _dio.request(url,
              queryParameters: params, options: Options(method: 'put'));
          break;
        case TMDioMethod.delete:
          response = await _dio.request(url,
              queryParameters: params, options: Options(method: 'delete'));
          break;
        default:
          if (formData != null) {
            response = await _dio
                .request(url, data: formData, options: Options(method: 'post'),
                    onSendProgress: (received, total) {
              uploadFileProgressCallback(received, total);
            });
          } else {
            response = await _dio.request(url,
                queryParameters: params,
                data: params,
                options: Options(method: 'post'));
          }
      }

      // JSON 序列化, Response<dynamic> 转 Map<String, dynamic>

      final BaseModel model = BaseModel.fromJson(response.data);

      if (model.errCode == 200) {
        // 保存缓存
        if (httpBaseOptions.cacheMode != CacheMode.NO_CACHE) {
          LogUtil.v("save cache");
          CacheUtils.saveCache(
              CacheUtils.getCacheKeyFromPath(url, params ?? {}),
              json.encoder.convert(response.data));
        }

        if (successCallBack != null) {
          successCallBack(model);
        }
      } else if (model.errCode >= 500 && model.errCode <= 510) {
        doErrorCallback(httpBaseOptions, url, params, successCallBack,
            errorCallBack, model.errCode, model.message);
      } else if (errorCallBack != null) {
        doErrorCallback(httpBaseOptions, url, params, successCallBack,
            errorCallBack, model.errCode, model.message);
      }
    } on DioError catch (e) {
      if (errorCallBack != null && e.type != DioErrorType.CANCEL) {
        doErrorCallback(httpBaseOptions, url, params, successCallBack,
            errorCallBack, 0, e.message);
      }
    } catch (e) {
      LogUtil.e(e);
      if (errorCallBack != null) {
        doErrorCallback(httpBaseOptions, url, params, successCallBack,
            errorCallBack, 0, '未知错误');
      }
    }
  }

  /// 错误回调
  void doErrorCallback(
      HttpBaseOptions httpBaseOptions,
      String url,
      Map<String, dynamic> params,
      HttpSuccessCallback successCallBack,
      HttpFailureCallback errorCallBack,
      int errorCode,
      String errorMsg) {
    if (httpBaseOptions.cacheMode == CacheMode.REQUEST_FAILED_READ_CACHE) {
      getCacheCallback(url, params, successCallBack,
          isErrorCallBack: true,
          errorCallBack: errorCallBack,
          errorCode: errorCode,
          errorMsg: errorMsg);
    } else {
      if (errorCallBack != null) {
        errorCallBack(errorCode, errorMsg);
      }
    }
  }

  /// 获取缓存并返回
  void getCacheCallback(String url, Map<String, dynamic> params,
      HttpSuccessCallback successCallBack,
      {bool isErrorCallBack = false,
      HttpFailureCallback errorCallBack,
      int errorCode,
      String errorMsg}) {
    //先获取缓存，在获取网络
    CacheUtils.getCache(url, params ?? {}).then((list) {
      if (list.length > 0) {
        LogUtil.v("getCache");
        String cacheResponseData = list[0]['value'];
        LogUtil.v(cacheResponseData);
        final BaseModel cacheModel =
            BaseModel.fromJson(jsonDecode(cacheResponseData));
        if (successCallBack != null) {
          successCallBack(cacheModel);
        }
      } else {
        // 缓存为空
        if (isErrorCallBack) {
          errorCallBack(errorCode, errorMsg);
        }
      }
    });
  }

  /// 组装数据，开始上传到OSS
  static Future<String> uploadToOss(
      File file, TMAliYunTokenModel tmAliYunTokenModel) async {
    //表单需要的参数: AccessKeyId、AccessKeySecret、SecurityToken;
    String fileName =
        "${DateUtils.instance.getFormatData(timeStamp: DateTime.now().millisecondsSinceEpoch, format: "yyyy/MM/dd")}/${DateTime.now().millisecondsSinceEpoch.toString()}_${OssUtil.instance.getImageNameByPath(file.path)}";
    LogUtil.v(fileName);
    FormData formData = new FormData.fromMap({
      //文件名，随意
      'Filename': fileName,
      //"可以填写文件夹名（对应于oss服务中的文件夹）/" + fileName
      'key': fileName,
      //上传后的文件名
      'policy': OssUtil.policy,
      //Bucket 拥有者的AccessKeyId。
      'OSSAccessKeyId': tmAliYunTokenModel.stsInfo.accessKeyId,
      //  accessKeyId 大小写 和服务端返回的对应就成，不要在意这些细节  下同
      //让服务端返回200，不然，默认会返回204
      'success_action_status': '200',
      'signature': OssUtil.instance
          .getSignature(tmAliYunTokenModel.stsInfo.accessKeySecret),
      //临时用户授权时必须，需要携带后台返回的security-token
      'x-oss-security-token': tmAliYunTokenModel.stsInfo.securityToken,
      'file': MultipartFile.fromFileSync(file.path,
          filename: OssUtil.instance.getImageNameByPath(file.path))
    });
    //然后通过存储地址直接把表单(formData)上传上去;
    Dio dio = Dio();
    dio.options.responseType = ResponseType.plain;
    String endpoint =
        "${tmAliYunTokenModel.bucket}.${tmAliYunTokenModel.endpoint}";
    if (!endpoint.startsWith("http") && !endpoint.startsWith("https")) {
      endpoint = "https://$endpoint";
    }
    LogUtil.v(endpoint);
    Response response = await dio.post(endpoint, data: formData);
    LogUtil.v(response);
    if (response.statusCode == 200) {
      return "${tmAliYunTokenModel.cdn}/$fileName";
    } else {
      return "";
    }
  }
}

/// Dio 请求与响应拦截器
class OnReqResInterceptors extends InterceptorsWrapper {
  /// 请求拦截
  @override
  Future onRequest(RequestOptions options) {
    LogUtil.v("请求baseUrl：${options.baseUrl}");
    LogUtil.v("请求url：${options.path}");
    LogUtil.v('请求头: ${options.headers.toString()}');

    if (options.data != null) {
      LogUtil.v('请求参数: ${options.data.toString()}');
    }
    if (options.queryParameters.length > 0 ?? false) {
      LogUtil.v('请求参数: ${options.queryParameters.toString()}');
    }

    return super.onRequest(options);
  }

  /// 响应拦截
  @override
  Future onResponse(Response response) {
    Response res = response;
    if (response.statusCode == 200) {
      try {
        if (response.data is String) {
          res.data = jsonDecode(response.data);
        }

        if (res.data != null) {
          int errCode = res.data["code"];
          final bool tmencrypt =
              res.data['tmencrypt'] != null && res.data['tmencrypt'] == 1;
          if (errCode == 200 && tmencrypt) {
            String tmtimestamp = res.request.headers['tmtimestamp'];
            String tmrandomnum = res.request.headers['tmrandomnum'];
            final dataStr = res.data['data'];
            if (dataStr != null &&
                dataStr is String &&
                tmtimestamp != null &&
                tmrandomnum != null) {
              Map<String, dynamic> decryption = TMEncryptionTool.tm_decryption(
                  tmtimestamp, tmrandomnum, dataStr);
              if (decryption['code'] == 200) {
                if (decryption['data'] != null) {
                  res.data['data'] = decryption['data'];
                } else {
                  res.data['data'] = null;
                }
              }
            }
          }
        }
      } catch (e) {
        try {
          res.data['code'] = 551;
          res.data['msg'] = '解密失败';
        } catch (e) {}
      }
    }
    LogUtil.v('请求结果:' + res.data?.toString());
    return super.onResponse(res);
  }
}

/// Dio OnError 拦截器
class OnErrorInterceptors extends InterceptorsWrapper {
  /// 异常拦截
  @override
  Future onError(DioError err) {
    LogUtil.e('请求异常: ${err.toString()}');
    LogUtil.e('请求异常信息: ${err.response?.toString() ?? ""}');
    // 异常分类
    switch (err.type) {
      // 4xx 5xx response
      case DioErrorType.RESPONSE:
        // JSON 序列化, Response<dynamic> 转 Map<String, dynamic>
        String jsonStr = json.encode(err.response.data);
        Map<String, dynamic> map = json.decode(jsonStr);
        BaseModel baseModel = BaseModel.fromJson(map);
        // 处理自定义错误
        switch (baseModel.errCode) {
          case ErrCode.SUCCESS:
            LogUtil.e('0 在这里是不可能出现的，出现的就是有错');
            break;
          case ErrCode.TOKEN_ERR:
            // TMToast.error('未登陆');
            // 跳转到登录页
            // Routes.toWelcome();
            break;
          case ErrCode.DEVICE_TIMEOUT:
            // TMToast.error('设备响应超时');
            break;
          default:
            LogUtil.e('DioError default');
          // 错误提示
          // TMToast.error(baseModel.message);
        }
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        // TMToast.error('连接超时');
        break;
      case DioErrorType.SEND_TIMEOUT:
        // TMToast.error('发送超时');
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        // TMToast.error('接收超时');
        break;
      case DioErrorType.CANCEL:
        // TMToast.error('取消连接');
        break;
      case DioErrorType.DEFAULT:
        // TMToast.error('连接异常');
        break;
    }
    return super.onError(err);
  }
}
