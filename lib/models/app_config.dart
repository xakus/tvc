/// Конфигурация экрана `/etc/tvc/config.json` (spec/50_tvc.md R-TVC-4, `config.example.json`).
///
/// `apiUrl` — адрес pscs (запасной вариант до mDNS, 3.1); `deviceToken` — токен устройства после привязки;
/// `gpioPin` — линия реле PlayStation; `language` — переопределение языка (по умолчанию язык клуба из pscs);
/// `productsScroll` — способ автопрокрутки списков: `smooth` (плавно) или `step` (построчно без анимации, T-24).
class AppConfig {
  final String apiUrl;
  final String deviceToken;
  final int gpioPin;
  final String? language;
  final String productsScroll;

  const AppConfig({
    required this.apiUrl,
    required this.deviceToken,
    this.gpioPin = 260,
    this.language,
    this.productsScroll = 'smooth',
  });

  bool get hasToken => deviceToken.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'apiUrl': apiUrl,
    'deviceToken': deviceToken,
    'gpioPin': gpioPin,
    if (language != null) 'language': language,
    'productsScroll': productsScroll,
  };

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    apiUrl: (json['apiUrl'] as String?)?.trim() ?? '',
    deviceToken: (json['deviceToken'] as String?)?.trim() ?? '',
    gpioPin: (json['gpioPin'] as num?)?.toInt() ?? 260,
    language: json['language'] as String?,
    productsScroll: json['productsScroll'] as String? ?? 'smooth',
  );

  AppConfig copyWith({String? apiUrl, String? deviceToken}) => AppConfig(
    apiUrl: apiUrl ?? this.apiUrl,
    deviceToken: deviceToken ?? this.deviceToken,
    gpioPin: gpioPin,
    language: language,
    productsScroll: productsScroll,
  );
}
