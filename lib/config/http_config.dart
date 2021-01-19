class HttpConfig {
  // // 是否加密
  // static bool isEncrypt = false;
  //
  // 是否是调试模式
  static bool isDebug = false;
  //
  // // 缓存类型
  // static CacheMode cacheMode = CacheMode.NO_CACHE;
}

enum CacheMode {
  NO_CACHE, //没有缓存
  REQUEST_FAILED_READ_CACHE, //先请求网络，如果请求网络失败，则读取缓存，如果读取缓存失败，本次请求失败
  FIRST_CACHE_THEN_REQUEST, //先使用缓存，不管是否存在，仍然请求网络
}
