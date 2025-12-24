import 'dart:convert';

import 'package:tvc/models/settings_dto.dart';

InfoSchedule infoScheduleFromJson(String str) =>
    InfoSchedule.fromJson(json.decode(str));

String infoScheduleToJson(InfoSchedule data) => json.encode(data.toJson());

class InfoSchedule {
  InfoSchedule({
    required this.displayText,
    required this.settings,
    required this.discountPercent,
    required this.totalPrice,
    required this.clubName,
    required this.message,
    required this.error,
    required this.done,
    required this.tableName,
    required this.unlimit,
    required this.blocked,
    required this.tableId,
    required this.startTime,
    required this.tablePricePerHour,
    required this.endTime,
    required this.timeSet,
    required this.timeLeft,
    required this.basePrice,
  });

  String displayText;
  SettingsDto settings;
  double discountPercent;
  double totalPrice;
  String clubName;
  String message;
  bool error;
  bool done;
  String tableName;
  bool unlimit;
  bool blocked;
  int tableId;
  DateTime startTime;
  double tablePricePerHour;
  DateTime endTime;
  int timeSet;
  int timeLeft;
  double basePrice;

  // Вспомогательная функция для безопасного преобразования в double
  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory InfoSchedule.fromJson(Map<dynamic, dynamic> json) => InfoSchedule(
    displayText: json["displayText"] ?? "",
    settings: SettingsDto.fromJson(json["settingsMessage"]),
    discountPercent: _toDouble(json["discountPercent"]),
    totalPrice: _toDouble(json["totalPrice"]),
    clubName: json["clubName"] ?? "",
    message: json["message"] ?? "",
    error: json["error"] ?? false,
    done: json["done"] ?? false,
    tableName: json["tableName"] ?? "",
    unlimit: json["unlimit"] ?? false,
    blocked: json["blocked"] ?? false,
    tableId: json["tableId"] ?? 0,
    startTime: DateTime.parse(json["startTime"]),

    tablePricePerHour: _toDouble(json["tablePricePerHour"]) / 100,
    endTime: DateTime.parse(
      json["endTime"] == '-----' ? DateTime.now().toString() : json["endTime"],
    ),
    timeSet: json["timeSet"] ?? 0,
    timeLeft: (json["timeLeft"] ?? 0).abs(),
    basePrice: _toDouble(json["basePrice"]),
  );

  Map<dynamic, dynamic> toJson() => {
    "displayText": displayText,
    "settingsMessage": settings.toJson(),
    "discountPercent": discountPercent,
    "totalPrice": totalPrice,
    "clubName": clubName,
    "message": message,
    "error": error,
    "done": done,
    "tableName": tableName,
    "unlimit": unlimit,
    "blocked": blocked,
    "tableId": tableId,
    "startTime": startTime.toIso8601String(),
    "tablePricePerHour": tablePricePerHour,
    "endTime": endTime.toIso8601String(),
    "timeSet": timeSet,
    "timeLeft": timeLeft,
    "basePrice": basePrice,
  };
}
