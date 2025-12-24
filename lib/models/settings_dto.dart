class SettingsDto {
  final String updateUrl;
  final int priceHiddenTime;
  final int version;

  SettingsDto({
    required this.updateUrl,
    required this.version,
    required this.priceHiddenTime,
  });

  // ВАЖНО: должен быть метод toJson
  Map<String, dynamic> toJson() {
    return {
      'updateUrl': updateUrl,
      'priceHiddenTime': priceHiddenTime,
      'version': version,
    };
  }

  factory SettingsDto.fromJson(Map<String, dynamic> json) {
    return SettingsDto(
      updateUrl: json['updateUrl'] as String,
      priceHiddenTime: json['priceHiddenTime'] as int,
      version: json['version'] as int,
    );
  }
}
