# Эталон дизайна tvc (D-12)

Снимки всех режимов экрана 1920×1080 — ссылки на golden-файлы тестов (`test/goldens/`), чтобы не хранить
картинки дважды. Источник: фикстуры `assets/mock/state_<name>.json`, тест `test/pages/home_page_golden_test.dart`.

| Файл | Режим |
|------|-------|
| `state_idle.png` | IDLE — стол свободен: цена/час, скидки, прайс-лист |
| `state_active_limited.png` | ACTIVE, лимит по времени: заказы и суммы (D-37), таймер, цена |
| `state_active_unlimited.png` | ACTIVE, безлимит |
| `state_summary.png` | SUMMARY — чек после остановки |
| `state_blocked.png` | BLOCKED — `BlockedCard` |
| `state_reserved.png` | RESERVED — сейчас как IDLE (окно брони — R-TVC-15, после возврата дизайна) |

Любое расхождение с эталоном — осознанное решение заказчика. Пересоздать после такого решения:
`flutter test --update-goldens test/pages/home_page_golden_test.dart`.
