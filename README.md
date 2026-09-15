# tvc — экран игрового стола (Orange Pi Zero 2W)

Показывает состояние стола, цены, скидки, товары, итог сеанса; управляет питанием PlayStation по командам pscs. Ничего не вычисляет сам.
Спецификация — [`../spec/50_tvc.md`](../spec/50_tvc.md), план — [`../plans/tvc_plan.md`](../plans/tvc_plan.md). Дизайн-токены зафиксированы в спецификации.

Flutter 3.47 / Dart 3.13. Сервер: pscs (LAN); адрес находит по mDNS, токен получает при привязке кодом.

## Запуск

```bash
flutter pub get
flutter run -d linux --dart-define=API_URL=http://192.168.1.107:8899 --dart-define=GPIO=stub   # на ноутбуке без реле
flutter run --dart-define=API_MODE=mock              # без сервера: фикстуры assets/mock/ (демо-набор spec/03)
```

Mock-сервер из контракта (когда бэкенд ещё не готов): `tool/mock-server.sh` (Prism на OpenAPI).

## Проверки

```bash
flutter analyze
flutter test
dart run tool/validate_mocks.dart                    # фикстуры соответствуют OpenAPI
```

## Сборка

См. раздел «Сборка» в плане. Секреты и `config.json` с токенами в git не коммитятся (`.gitignore`).
