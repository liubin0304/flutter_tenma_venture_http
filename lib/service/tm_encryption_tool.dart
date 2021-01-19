
import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';


import 'package:encrypt/encrypt.dart';


class TMEncryptionTool {
  static final charList = '0123456789zxcvbnmasdfghjklqwertyuiopZXCVBNMASDFGHJKLQWERTYUIOP';

  static String getRandomString(int length) {
    String randomStr = '';
    for (int i = 0; i < length; i ++) {
      randomStr = randomStr + charList[Random().nextInt(charList.length)];
    }
    return randomStr;
  }

  static String generateAES(String data, String keyStr, String ivStr) {

    final plainText = data;
    final key = Key.fromUtf8(keyStr);
    final iv = IV.fromUtf8(ivStr);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  static String decryptionAES(String data, String keyStr, String ivStr) {

    final key = Key.fromUtf8(keyStr);
    final iv = IV.fromUtf8(ivStr);


    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: iv);
    final decrypted64 = encrypter.decrypt64(data, iv: iv);


    return decrypted64;
  }

  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }




  static Map encryptionParams(Map params, String time, String random) {
    try {
      if (params.isEmpty) {
        return null;
      }

      ///将参数转为为json字符串
      String jsonString = jsonEncode(params);
      if (jsonString?.length == 0) {
        return null;
      }


      String timeBase64Str = base64Encode(utf8.encode(time));
      String timeMd5Str = generateMd5(time);


      String randomBase64Str = base64Encode(utf8.encode(random));
      String randomMd5Str = generateMd5(random);

      String keyBase64Str = '${timeBase64Str}${randomMd5Str}';
      String key = generateMd5(keyBase64Str);

      if (key?.length > 0) {
        key = key.substring(0, 16);
      }

      String offsetBase64Str = '${randomBase64Str}${timeMd5Str}';
      String offset = generateMd5(offsetBase64Str);
      if (offset?.length > 0) {
        offset = offset.substring(0, 16);
      }

      String enBase64 = generateAES(jsonString, key, offset);



      return {
        'tm_encrypt_data' : enBase64
      };
    } catch (e) {
      print(e);
      return null;
    }

  }



  static Map<String, dynamic> tm_encryption(Map params) {
    try {

      ///当前时间戳
      num nowTime = DateTime.now().millisecondsSinceEpoch;
      String timeMd5Str = generateMd5('${nowTime}');
      String randomStr = getRandomString(16);

      String headStr = '${timeMd5Str}${randomStr}';
      String headBase64Ecode = base64Encode(utf8.encode(headStr));
      String headTmencryptStr = '${headBase64Ecode}${randomStr}';

      Map headers = {};
      headers['tmencrypt'] = '1';
      headers['tmtimestampnew'] = '${nowTime}';
      headers['tmrandomnumnew'] = randomStr;
      headers['tmencryptkeynew'] = generateMd5(headTmencryptStr);

      headers['tmtimestamp'] = '${nowTime}';
      headers['tmrandomnum'] = randomStr;
      headers['tmencryptkey'] = generateMd5(headTmencryptStr);


      Map<String, dynamic> enData = {
        'headers' : headers
      };
      if (params == null) {
        enData['code'] = 200;
        enData['msg'] = '加密成功';
        return enData;
      }


      params = encryptionParams(params, '${nowTime}', randomStr);

      if (params?.isNotEmpty) {
        enData['params'] = params;
      }
      enData['code'] = 200;
      enData['msg'] = '加密成功';
      return enData;
    } catch (e) {
      return {
        'code' : 0,
        'msg' : '加密失败'
      };
    }

  }


  static Map<String, dynamic> tm_decryption(String time, String random, String content) {
    try {
      String timeBase64Str = base64Encode(utf8.encode(time));
      String timeMd5Str = generateMd5(time);


      String keyBase64Str = '${timeBase64Str}${timeMd5Str}';
      String key = generateMd5(keyBase64Str);

      if (key?.length > 0) {
        key = key.substring(0, 16);
      }

      String offset = generateMd5(random);
      if (offset?.length > 0) {
        offset = offset.substring(0, 16);
      }

      String deBase64 = decryptionAES(content, key, offset);

      final jsonObject = jsonDecode(deBase64);

      return {
        'code' : 200,
        'msg' : '解密成功',
        'data' : jsonObject
      };
    } catch (e) {
      print(e);
      return {
        'code' : 0,
        'msg' : '解密失败',
      };
    }


  }



}