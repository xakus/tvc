import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvc/localization/tvc_localization.dart';
import 'package:tvc/models/app_config.dart';
import 'package:tvc/models/device_state.dart';
import 'package:tvc/services/config_service.dart';
import 'package:tvc/services/device_api.dart';
import 'package:tvc/theme/app_colors.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/blocked_card.dart';
import 'package:tvc/widgets/clock_widget.dart';
import 'package:tvc/widgets/game_price_card.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import 'package:tvc/widgets/sales_card.dart';
import 'package:tvc/widgets/session_sales_card.dart';

import '../models/utils.dart';
import '../services/gpio_service.dart';
import '../widgets/discount_card.dart';

/// Версия экрана для heartbeat (`--dart-define=APP_VERSION`).
const String appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
);

/// Экран стола: состояние берётся из pscs (`GET /api/v1/device/state`) каждые 5 с (R-TVC-21; WebSocket — 3.3),
/// таймер тикает локально от `serverTime` (R-TVC-1), heartbeat раз в 60 с (R-TVC-20). Раскладка и стиль прежние
/// (D-12): шапка клуб/стол, цена за час, слева скидки, в центре время и цена игры + блок сумм (D-37), справа
/// прайс-лист с автопрокруткой (D-37). PS включается, пока стол в ACTIVE_*.
class HomePage extends StatefulWidget {
  /// Источник состояния (для тестов); по умолчанию — из конфига и `--dart-define`.
  final DeviceApi? api;

  /// Конфигурация (для тестов); по умолчанию — `config.json`.
  final AppConfig? config;

  const HomePage({super.key, this.api, this.config});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Duration _pollInterval = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 60);

  DeviceState? _state;
  AppConfig? _config;
  DeviceApi? _api;
  bool _unauthorized = false;
  DateTime? _lastOkAt;
  Timer? _poll;
  Timer? _tick;
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    GpioService.setScreen(true);
    _start();
  }

  Future<void> _start() async {
    _config = widget.config ?? await ConfigService.loadConfig();
    GpioService.psPin = _config!.gpioPin;
    _api =
        widget.api ??
        DeviceApi.create(
          apiUrl: _config!.apiUrl,
          deviceToken: _config!.deviceToken,
        );
    await _load();
    _poll = Timer.periodic(_pollInterval, (_) => _load());
    // локальный тик секундомера — только пока идёт игра
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_state?.isActive ?? false)) {
        setState(() {});
      }
    });
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeat());
    _sendHeartbeat();
  }

  Future<void> _load() async {
    final api = _api;
    if (api == null) {
      return;
    }
    try {
      final state = await api.getState();
      if (!mounted) {
        return;
      }
      setState(() {
        _state = state;
        _unauthorized = false;
        _lastOkAt = DateTime.now();
      });
      // PS включён только во время игры (команды по WebSocket — 3.3)
      await GpioService.setPs(state.isActive);
    } on DeviceUnauthorized catch (e) {
      debugPrint('Токен устройства не принят: $e');
      if (mounted) {
        setState(() => _unauthorized = true);
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке состояния: $e');
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _sendHeartbeat() async {
    try {
      await _api?.postStatus(
        version: appVersion,
        online: true,
        error: GpioService.lastError,
      );
    } catch (e) {
      debugPrint('Heartbeat не отправлен: $e');
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _tick?.cancel();
    _heartbeat?.cancel();
    GpioService.setScreen(false);
    GpioService.setPs(false);
    super.dispose();
  }

  /// Нет ответа pscs дольше 15 с (R-TVC-14).
  bool get _offline =>
      _lastOkAt != null &&
      DateTime.now().difference(_lastOkAt!) > const Duration(seconds: 15);

  @override
  Widget build(BuildContext context) {
    final state = _state;
    // Язык экрана: из конфига, иначе язык клуба (R-TVC-10)
    final language = _config?.language ?? state?.language ?? 'az';
    return Localizations.override(
      context: context,
      locale: Locale(language),
      child: Builder(builder: (context) => _screen(context, state)),
    );
  }

  Widget _background({required Widget child}) => Scaffold(
    body: SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    ),
  );

  Widget _screen(BuildContext context, DeviceState? state) {
    if (state == null) {
      // Ещё нет состояния: загрузка или экран не привязан
      return _background(
        child: Center(
          child: _unauthorized
              ? _message(context)
              : const CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }

    final scrollMode = _config?.productsScroll ?? 'smooth';
    // Центральная колонка: во время игры и пока показывается чек — время/цена и блок сумм (D-37)
    Widget middle;
    if (state.session != null) {
      middle = Column(
        children: [
          Expanded(
            child: SessionSalesCard.ofSession(
              state.session!,
              scrollMode: scrollMode,
            ),
          ),
          SizedBox(height: Utils.getHeightSize(context, 10)),
          GamePriceCard(state: state),
        ],
      );
    } else if (state.isFinished && state.lastReceipt != null) {
      middle = Column(
        children: [
          Expanded(
            child: SessionSalesCard.ofReceipt(
              state.lastReceipt!,
              scrollMode: scrollMode,
            ),
          ),
          SizedBox(height: Utils.getHeightSize(context, 10)),
          GamePriceCard(state: state),
        ],
      );
    } else {
      middle = const SizedBox.shrink();
    }

    return _background(
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Container(
                  height: Utils.getHeightSize(context, 100),
                  width: Utils.getHeightSize(context, 350),
                  decoration: BoxDecoration(
                    color: AppColors.gradientBlueLight,
                    borderRadius: BorderRadius.all(
                      Radius.circular(Utils.getHeightSize(context, 10)),
                    ),
                    border: Border.all(width: 2, color: Colors.white12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.gradientBlueLightShadow,
                        blurRadius: 5,
                        blurStyle: BlurStyle.outer,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const ClockWidget(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: Utils.getHeightSize(context, 140),
                          child: NeoCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  state.clubName,
                                  style: AppTextStyles.clubName(context),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  state.displayText.isEmpty
                                      ? state.name
                                      : state.displayText,
                                  style: AppTextStyles.title(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: Utils.getHeightSize(context, 50),
                          child: NeoCard(
                            child: Text(
                              '1 saat ${(state.pricePerHourQepik / 100).toStringAsFixed(2)} azn',
                              style: AppTextStyles.subtitle(context),
                            ),
                          ),
                        ),
                        SizedBox(height: Utils.getHeightSize(context, 20)),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: DiscountCard(
                                  discounts: state.idle.discounts,
                                  scrollMode: scrollMode,
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(child: middle),
                              const SizedBox(width: 40),
                              Expanded(
                                child: SalesCard(
                                  idle: state.idle,
                                  scrollMode: scrollMode,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_offline)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    TvcLocalization.of(context).get('no_connection'),
                    style: AppTextStyles.blocked(context),
                  ),
                ),
              ),
            state.isBlocked ? const BlockedCard() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// Экран не привязан: pscs не принял токен (привязка кодом — 3.1).
  Widget _message(BuildContext context) {
    final l10n = TvcLocalization.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: Utils.getHeightSize(context, 220),
      child: NeoCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(l10n.get('not_paired'), style: AppTextStyles.menuTitle(context)),
            Text(
              l10n.get('not_paired_hint'),
              style: AppTextStyles.menuName(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
