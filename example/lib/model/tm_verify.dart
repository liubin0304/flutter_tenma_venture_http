import 'package:flutter/material.dart';
import 'package:flutter_tenma_venture_http/models/base_model.dart';
import 'package:flutter_tenma_venture_http/models/base_response_data.dart';

class TMVerify extends BaseResponseData {
  String verify;

  TMVerify({this.verify});

  TMVerify.fromJson(Map<String, dynamic> json) {
    verify = json['verify'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['verify'] = this.verify;
    return data;
  }
}
