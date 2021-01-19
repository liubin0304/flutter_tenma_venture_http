import 'dart:convert';

import 'package:flutter_tenma_venture_http/models/base_response_data.dart';

class BaseModel {
  String message;
  int errCode;
  dynamic data;
  int tmencrypt;
  int tmtime;

  BaseModel(
      {this.message, this.errCode, this.data, this.tmencrypt, this.tmtime});

  BaseModel.fromJson(Map<String, dynamic> json) {
    message = json['msg'];
    errCode = json['code'];
    data = json['data'];
    tmencrypt = json['tmencrypt'];
    tmtime = json['tmtime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.message;
    data['code'] = this.errCode;
    data['data'] = this.data;
    data['tmencrypt'] = this.tmencrypt;
    data['tmtime'] = this.tmtime;
    return data;
  }
}
