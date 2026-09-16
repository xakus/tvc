# tvc — экран игрового стола (Orange Pi Zero 2W)

Показывает состояние стола, цены, скидки, товары, заказы и суммы сеанса, итог после остановки; управляет питанием
PlayStation по командам pscs. Ничего не вычисляет сам (R-TVC-1): все суммы приходят от pscs, таймер только
интерполируется от `serverTime`.
Спецификация — [`../spec/50_tvc.md`](../spec/50_tvc.md), план — [`../plans/embedded/tvc_plan.md`](../plans/embedded/tvc_plan.md).
Дизайн зафиксирован (D-12): эталонные снимки всех режимов — `docs/design-baseline/` (они же golden-тесты).

Flutter 3.47 / Dart 3.9+. Сервер: pscs v2 (LAN, device API `spec/20_pscs.md` §10, `Authorization: Bearer <deviceToken>`).

## Запуск

```bash
flutter pub get

# на ноутбуке против dev-pscs (spec/03 §3.3 — демо-токены экранов), без реле
flutter run -d linux \
  --dart-define=API_URL=http://127.0.0.1:8899 \
  --dart-define=DEVICE_TOKEN=dt_... \
  --dart-define=GPIO=stub

# без сервера: фикстуры assets/mock/state_<name>.json (idle, active_limited, active_unlimited, summary, blocked, reserved …)
flutter run -d linux --dart-define=API_MODE=mock --dart-define=MOCK_STATE=active_limited --dart-define=GPIO=stub
```

`--dart-define`:

| Ключ | Назначение |
|------|------------|
| `API_URL` | адрес pscs, переопределяет `config.json` |
| `DEVICE_TOKEN` | токен экрана, переопределяет `config.json` |
| `API_MODE=mock` | состояние из `assets/mock/` вместо сети |
| `MOCK_STATE` | имя фикстуры для `API_MODE=mock` (по умолчанию `idle`) |
| `GPIO=stub` | не трогать GPIO, только лог |
| `APP_VERSION` | версия в heartbeat `POST /device/status` |

Mock-сервер из контракта: `tool/mock-server.sh` (Prism на OpenAPI).

## config.json

На точке — `/etc/tvc/config.json` (0600), в dev — файл рядом с бинарником. Пример — `config.example.json`.

| Поле | Значение |
|------|----------|
| `apiUrl` | адрес pscs (запасной вариант до mDNS, 3.1) |
| `deviceToken` | токен экрана (выдаётся при привязке кодом, 3.1) |
| `gpioPin` | линия реле питания PS (по умолчанию 260; экран — 259) |
| `language` | необязательно: переопределить язык клуба (`az`/`ru`/`en`) |
| `productsScroll` | автопрокрутка списков: `smooth` (плавно) или `step` (сдвиг на строку без анимации); выбор — по нагрузке CPU на Orange Pi (T-24) |

## Проверки

```bash
flutter analyze
flutter test                                          # модели, автопрокрутка, экран по фикстурам, golden 1920×1080
flutter test --update-goldens test/pages/home_page_golden_test.dart   # пересоздать эталоны (только осознанно: дизайн зафиксирован)
dart run tool/validate_mocks.dart                     # фикстуры соответствуют OpenAPI
```

Golden-тесты грузят реальные шрифты приложения (`test/support/fonts.dart`), иначе раскладка не совпадает с экраном.

## Сборка

`flutter build linux`. Секреты и `config.json` с токенами в git не коммитятся (`.gitignore`).
