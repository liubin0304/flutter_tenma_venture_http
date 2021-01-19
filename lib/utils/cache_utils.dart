import 'data_base_utils.dart';
import 'md5_utils.dart';
import 'text_utils.dart';

class CacheUtils {
  /*
   * 获取get缓存请求
   */
  static Future<List<Map<String, dynamic>>> getCache(
      String path, Map<String, String> params) async {
    return DatabaseUtil.queryHttp(
        DatabaseUtil.database, getCacheKeyFromPath(path, params));
  }

  static String getCacheKeyFromPath(String path, Map<String, String> params) {
    String cacheKey = "";
    if (!(TextUtil.isEmpty(path))) {
      cacheKey = cacheKey + MD5Util.generateMd5(path);
    } else {
      throw new Exception("请求地址不能为空！");
    }
    if (params != null && params.length > 0) {
      String paramsStr = "";
      params.forEach((key, value) {
        paramsStr = paramsStr + key + value;
      });
      cacheKey = cacheKey + MD5Util.generateMd5(paramsStr);
    }
    return cacheKey;
  }

  static void saveCache(String cacheKey, String value) {
    DatabaseUtil.queryHttp(DatabaseUtil.database, cacheKey).then((list) {
      if (list != null && list.length > 0) {
        //更新数据库数据
        DatabaseUtil.updateHttp(DatabaseUtil.database, cacheKey, value);
      } else {
        //插入数据库数据
        DatabaseUtil.insertHttp(DatabaseUtil.database, cacheKey, value);
      }
    });
  }
}
