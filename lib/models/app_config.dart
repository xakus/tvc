class AppConfig {
  final String apiUrl;
  final String updateUrl;
  final int deviceId;
  final int priceHiddenTime;
  final int version;
  final int newVersion;

  AppConfig({
    required this.apiUrl,
    required this.updateUrl,
    required this.deviceId,
    required this.version,
    required this.newVersion,
    required this.priceHiddenTime,
  });

  // ВАЖНО: должен быть метод toJson
  Map<String, dynamic> toJson() {
    return {
      'apiUrl': apiUrl,
      'updateUrl': updateUrl,
      'priceHiddenTime': priceHiddenTime,
      'deviceId': deviceId,
      'version': version,
      'newVersion': newVersion,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiUrl: json['apiUrl'] as String,
      updateUrl: json['updateUrl'] as String,
      deviceId: json['deviceId'] as int,
      priceHiddenTime: json['priceHiddenTime'] as int,
      version: json['version'] as int,
      newVersion: json['newVersion'] as int,
    );
  }
}
