import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/*
 * 关于时间工具
 */
class DateUtils {
  // 工厂模式
  factory DateUtils() => _getInstance();

  static DateUtils get instance => _getInstance();
  static DateUtils _instance;

  DateUtils._internal() {
    // 初始化
  }

  static DateUtils _getInstance() {
    if (_instance == null) {
      _instance = new DateUtils._internal();
    }
    return _instance;
  }

  ///将时间日期格式转化为时间戳
  ///2018年12月11日
  ///2019-12-11
  ///2018年11月15 11:14分89
  ///结果是毫秒
  int getTimeStamp({formatData: String}) {
    var result = formatData.substring(0, 4) +
        "-" +
        formatData.substring(5, 7) +
        "-" +
        formatData.substring(8, 10);
    if (formatData.toString().length >= 13 &&
        formatData.substring(10, 13) != null) {
      result += "" + formatData.substring(10, 13);
    }
    if (formatData.toString().length >= 17 &&
        formatData.toString().substring(14, 16) != null) {
      result += ":" + formatData.substring(14, 16);
    }
    if (formatData.toString().length >= 19 &&
        formatData.substring(17, 19) != null) {
      result += ":" + formatData.substring(17, 19);
    }
    var dataTime = DateTime.parse(result);
    print(dataTime.millisecondsSinceEpoch);
    return dataTime.millisecondsSinceEpoch;
  }

  ///格式化时间戳
  ///timeStamp:毫秒值
  ///format:"yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"......
  ///结果： 2019?08?04  02?08?02
  getFormatData({timeStamp: int, format: String}) {
    var dataFormat = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeStamp);
    String formatResult = dataFormat.format(dateTime);
    return formatResult;
  }

  /// 计算两个时间之间的小时差
  /// -1 代表开始时间小于结束时间
  double timeDifferenceToHour({startTime: String, endTime: String}) {
    var start = getTimeStamp(formatData: startTime);
    var end = getTimeStamp(formatData: endTime);
    if (end > start) {
      return ((end - start) / 1000 / 60 / 60);
    } else if (end <= start) {
      return -1.0;
    }
    return -2.0;
  }

  ///1.获取从某一天开始到某一天结束的所有的中间日期，例如输入 startTime:2019:07:31  endTime:2019:08:31  就会返回所有的中间天数。
  ///startTime和endTime格式如下都可以
  ///使用:    List<String> mdata=DateUtils.instance.getTimeBettwenStartTimeAndEnd(startTime:"2019-07-11",endTime:"2019-08-29",format:"yyyy年MM月dd");
  ///结果:[2019年07月11, 2019年07月12, 2019年07月13, 2019年07月14, 2019年07月15, 2019年07月16, 2019年07月17, 2019年07月18, 2019年07月19, 2019年07月20, 2019年07月21, 2019年07月22, 2019年07月23, 2019年07月24, 2019年07月25, 2019年07月26, 2019年07月27, 2019年07月28, 2019年07月29, 2019年07月30, 2019年07月31, 2019年08月01, 2019年08月02, 2019年08月03, 2019年08月04, 2019年08月05, 2019年08月06, 2019年08月07, 2019年08月08, 2019年08月09, 2019年08月10, 2019年08月11, 2019年08月12, 2019年08月13, 2019年08月14, 2019年08月15, 2019年08月16, 2019年08月17, 2019年08月18, 2019年08月19, 2019年08月20, 2019年08月21, 2019年08月22, 2019年08月23, 2019年08月24, 2019年08月25, 2019年08月26, 2019年08月27, 2019年08月28, 2019年08月29]
  List<String> getTimeBetweenStartTimeAndEnd(
      {startTime: String, endTime: String, format: String}) {
    var mDataList = List<String>();
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    int allTimeEnd = 0;
    //记录当前到个数(相当于天数)
    int currentFlag = 0;
    DateTime startData = DateTime.parse(startTime);
    DateTime endData = DateTime.parse(endTime);
    var mothFormatFlag = new DateFormat(format);
    while (endData.millisecondsSinceEpoch > allTimeEnd) {
      allTimeEnd =
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000;
      var dateTime = new DateTime.fromMillisecondsSinceEpoch(
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000);
      String nowMoth = mothFormatFlag.format(dateTime);
      mDataList.add(nowMoth);
      currentFlag++;
    }
    return mDataList;
  }

  ///传入starTime格式 2012-02-27 13:27:00 或者 "2012-02-27等....
  ///dayNumber：从startTime往后面多少天你需要输出
  ///format:获取到的日期格式。"yyyy年MM月dd" "yyyy-MM-dd" "yyyy年" "yyyy年MM月" "yyyy年\nMM月dd"  等等
  ///使用：DateUtils.instance.getTimeStartTimeAndEnd(startTime:"2019-07-11",dayNumber:10,format:"yyyy年MM月dd");
  ///结果:[2019年07月11, 2019年07月12, 2019年07月13, 2019年07月14, 2019年07月15, 2019年07月16, 2019年07月17, 2019年07月18, 2019年07月19, 2019年07月20, 2019年07月21]
  List<String> getTimeStartTimeAndEnd(
      {startTime: String, dayNumber: int, format: String}) {
    var mDataList = List<String>();
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    int allTimeEnd = 0;
    //记录当前到个数(相当于天数)
    int currentFlag = 0;
    DateTime startData = DateTime.parse(startTime);
    var mothFormatFlag = new DateFormat(format);
    while (dayNumber >= currentFlag) {
      var dateTime = new DateTime.fromMillisecondsSinceEpoch(
          startData.millisecondsSinceEpoch + currentFlag * 24 * 60 * 60 * 1000);
      String nowMoth = mothFormatFlag.format(dateTime);
      mDataList.add(nowMoth);
      currentFlag++;
    }
    return mDataList;
  }

  ///startTime:输入其实时间的时间戳也可以。
  ///dayNumber:时间段
  ///输入时间格式
  List<TimeData> getTimeStartTimeAndEndTime(
      {startTime: int, dayNumber: int, format: String}) {
    var mDataList = List<TimeData>();
    //记录往后每一天的时间搓，用来和最后一天到做对比。这样就能知道什么时候停止了。
    int allTimeEnd = 0;
    //记录当前到个数(相当于天数)
    int currentFlag = 0;
    var mothFormatFlag = new DateFormat(format);
    while (dayNumber >= currentFlag) {
      TimeData timeData = new TimeData();
      var dateTime = new DateTime.fromMillisecondsSinceEpoch(
          startTime + currentFlag * 24 * 60 * 60 * 1000);
      String nowMoth = mothFormatFlag.format(dateTime);
      timeData.dataTime = nowMoth;
      timeData.week = dateTime.weekday;
      mDataList.add(timeData);
      currentFlag++;
    }
    return mDataList;
  }

  ///获取某一个月的最后一天。
  ///我们能提供和知道的条件有:(当天的时间,)
  ///timeStamp:时间戳 单位（毫秒）
  ///format:想要的格式  "yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"
  getEndMoth({timeStamp: int, format: String}) {
    var dataFormat = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeStamp);
    var dataNextMonthData = new DateTime(dateTime.year, dateTime.month + 1, 1);
    int nextTimeStamp =
        dataNextMonthData.millisecondsSinceEpoch - 24 * 60 * 60 * 1000;
    //取得了下一个月1号码时间戳
    var nextMonthDateTime =
        new DateTime.fromMillisecondsSinceEpoch(nextTimeStamp);
    String formatResult = dataFormat.format(nextMonthDateTime);
    return formatResult;
  }

  ///获取某一个月的最后一天。
  ///我们能提供和知道的条件有:(当天的时间,)
  ///timeSamp:传入的是时间格式
  ///format:想要的格式  "yyyy年MM月dd hh:mm:ss"  "yyy?MM?dd  hh?MM?dd" "yyyy:MM:dd"
  getEndMothFor({mothFormat: String, format: String}) {
    DateTime startData = DateTime.parse(mothFormat);
    var dataFormat = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(
        startData.millisecondsSinceEpoch);
    var dataNextMonthData = new DateTime(dateTime.year, dateTime.month + 1, 1);
    int nextTimeStamp =
        dataNextMonthData.millisecondsSinceEpoch - 24 * 60 * 60 * 1000;
    //取得了下一个月1号码时间戳
    var nextMonthDateTime =
        new DateTime.fromMillisecondsSinceEpoch(nextTimeStamp);
    String formatResult = dataFormat.format(nextMonthDateTime);
    return formatResult;
  }

  /// 获取今天的开始时间
  getTodayBeginTime() {
    var nowDateTimeMillisecond = DateTime.now().millisecondsSinceEpoch;
    var todayDate =
        getFormatData(timeStamp: nowDateTimeMillisecond, format: "yyyy-MM-dd");
    return getTimeStamp(formatData: "$todayDate 00:00:00");
  }

  /// 获取今天的结束时间
  getTodayEndTime() {
    var nowDateTimeMillisecond = DateTime.now().millisecondsSinceEpoch;
    var todayDate =
        getFormatData(timeStamp: nowDateTimeMillisecond, format: "yyyy-MM-dd");
    return getTimeStamp(formatData: "$todayDate 23:59:59");
  }

  /// 根据传入的时间往后推算结束时间
  getTimeMillisecond4Day({dayNumber: int, isBefore: bool}) {
    var nowDateTimeMillisecond = DateTime.now().millisecond;
    var todayDate =
        getFormatData(timeStamp: nowDateTimeMillisecond, format: "yyyy-MM-dd");
    var todayDateTime = getTimeStamp(formatData: "$todayDate 00:00:00");
    todayDateTime += (24 * 60 * 60 * 1000) * dayNumber;
    return todayDateTime;
  }

  /// 获取星期
  static String getWeek(DateTime date) {
    var week = date.weekday;
    String w = '';
    switch (week.toString()) {
      case '1':
        w = '一';
        break;
      case '2':
        w = '二';
        break;
      case '3':
        w = '三';
        break;
      case '4':
        w = '四';
        break;
      case '5':
        w = '五';
        break;
      case '6':
        w = '六';
        break;
      case '7':
        w = '日';
        break;
    }
    return '周' + w.toString();
  }

  /// 判断是否是今天
  bool isToday(int time) {
    return time >= getTodayBeginTime() && time <= getTodayEndTime();
  }

  /// 判断是否是明天
  bool isTomorrow(int time) {
    int dayTime = 24 * 60 * 60 * 1000;
    return time >= (getTodayBeginTime() + dayTime) &&
        time <= (getTodayEndTime() + dayTime);
  }

  ///判断是否数字
  bool isNumeric(String str) {
    try{
      var value = double.parse(str);
      if(value is int){
        return false;
      }else{
        return true;
      }
    } on FormatException {
      return false;
    }
  }

  String getAge(int time) {
    print('年龄测试');
    print(time);
    int age = 0;
    DateTime dateTime = DateTime.now();
    DateTime brt = DateTime.fromMillisecondsSinceEpoch(time*1000);
    print(brt);
    if (dateTime.isBefore(brt)) {
      //出生日期晚于当前时间，无法计算
      return '出生日期不正確';
    }
    int yearNow = dateTime.year; //当前年份
    int monthNow = dateTime.month; //当前月份
    int dayOfMonthNow = dateTime.day; //当前日期

    int yearBirth = brt.year;
    int monthBirth = brt.month;
    int dayOfMonthBirth = brt.day;
    age = yearNow - yearBirth; //计算整岁数
    if (monthNow <= monthBirth) {
      if (monthNow == monthBirth) {
        if (dayOfMonthNow < dayOfMonthBirth) age--; //当前日期在生日之前，年龄减一
      } else {
        age--; //当前月份在生日之前，年龄减一
      }
    }
    return age.toString();
  }
}

class TimeData {
  String dataTime;
  int week;
}
