class TMAliYunTokenModel {
  StsInfo stsInfo;
  String bucket;
  String endpoint;
  String regionId;
  String cdn;

  TMAliYunTokenModel(
      {this.stsInfo, this.bucket, this.endpoint, this.regionId, this.cdn});

  TMAliYunTokenModel.fromJson(Map<String, dynamic> json) {
    stsInfo = json['sts_info'] != null
        ? new StsInfo.fromJson(json['sts_info'])
        : null;
    bucket = json['bucket'];
    endpoint = json['endpoint'];
    regionId = json['region_id'];
    cdn = json['cdn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stsInfo != null) {
      data['sts_info'] = this.stsInfo.toJson();
    }
    data['bucket'] = this.bucket;
    data['endpoint'] = this.endpoint;
    data['region_id'] = this.regionId;
    data['cdn'] = this.cdn;
    return data;
  }
}

class StsInfo {
  String securityToken;
  String accessKeyId;
  String accessKeySecret;
  String expiration;

  StsInfo(
      {this.securityToken,
        this.accessKeyId,
        this.accessKeySecret,
        this.expiration});

  StsInfo.fromJson(Map<String, dynamic> json) {
    securityToken = json['SecurityToken'];
    accessKeyId = json['AccessKeyId'];
    accessKeySecret = json['AccessKeySecret'];
    expiration = json['Expiration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SecurityToken'] = this.securityToken;
    data['AccessKeyId'] = this.accessKeyId;
    data['AccessKeySecret'] = this.accessKeySecret;
    data['Expiration'] = this.expiration;
    return data;
  }
}