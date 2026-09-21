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

## Запуск на Orange Pi Zero 2W (тестовый стенд, до образа SD-карты из 3.4)

Flutter не собирает Linux-бинарник под ARM64 с ноутбука — сборка **на самой плате** (Armbian/Ubuntu 24.04 arm64, 2 ГБ ОЗУ
хватает, ~10 мин; на 1 ГБ — добавить swap):

```bash
sudo apt install -y git curl unzip clang cmake ninja-build pkg-config libgtk-3-dev libgpiod-dev
git clone https://github.com/flutter/flutter.git -b stable ~/flutter && export PATH=$PATH:~/flutter/bin
git clone git@github.com:xakus/tvc.git && cd tvc && flutter pub get && flutter build linux --release \
    --dart-define=APP_VERSION=2.0.0
sudo mkdir -p /opt/tvc /etc/tvc && sudo cp -r build/linux/arm64/release/bundle/* /opt/tvc/
```

`/etc/tvc/config.json` (0600): `apiUrl` — адрес pscs в сети клуба (по умолчанию `http://192.168.1.107:8899`, т.е.
точка pscs на Orange Pi 5 с этим статическим IP), `deviceToken` — из привязки ниже, `gpioPin` — линия реле.
Запуск: `/opt/tvc/tvc` (в X/Wayland-сессии; kiosk через `cage` и `tvc.service` — план 3.4).

**Привязка экрана без club_control_app** (экран привязки в tvc — план 3.1; приложение сотрудника ещё на API v1) —
тот же протокол, что делают tvc и club_control_app, руками через `curl` с любой машины в сети клуба:

```bash
P=http://192.168.1.107:8899/api/v1
# 1. tvc-сторона: код привязки (TTL 10 мин)
curl -s -X POST $P/device/pairing -H 'Content-Type: application/json' \
     -d '{"fingerprint":"orangepi-zero2w-01","tvcVersion":"2.0.0"}'          # → {"code":"123456",...}
# 2. Сотрудник (зарегистрирован в pscs и подтверждён владельцем в club_owner_app): токен
T=$(curl -s -X POST $P/auth/sign-in -H 'Content-Type: application/json' \
     -d '{"username":"<сотрудник>","password":"<пароль>","language":"ru"}' | grep -oE '"accessToken":"[^"]+"' | cut -d'"' -f4)
# 3. Привязать код к столу (id стола — GET $P/tables с тем же токеном)
curl -s -X POST $P/device/pairing/123456/bind -H "Authorization: Bearer $T" -H 'Content-Type: application/json' \
     -d '{"tableId":1}'
# 4. tvc-сторона: забрать токен экрана (отдаётся один раз) → в /etc/tvc/config.json "deviceToken"
curl -s $P/device/pairing/123456
```

Сотрудника без club_control_app регистрируют так же: `POST $P/auth/sign-up` (поля — `SignUpRequest` в
`pscs-v2.yaml`: логин, пароль, ФИО, телефон, ФИН, серия/номер паспорта, дата рождения, `clubCode`, язык), затем владелец
подтверждает его в club_owner_app (Клуб → Сотрудники).
