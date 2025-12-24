import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvc/models/app_config.dart';
import 'package:tvc/models/settings_dto.dart';
import 'package:tvc/services/config_service.dart';
import 'package:tvc/services/service.dart';
import 'package:tvc/theme/app_colors.dart';
import 'package:tvc/theme/app_text_styles.dart';
import 'package:tvc/widgets/blocked_card.dart';
import 'package:tvc/widgets/clock_widget.dart';
import 'package:tvc/widgets/game_price_card.dart';
import 'package:tvc/widgets/neumorphic_card.dart';
import 'package:tvc/widgets/sales_card.dart';

import '../models/info_schedule.dart';
import '../models/utils.dart';
import '../widgets/discount_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InfoSchedule? _info; // ← убрал late, добавил ?
  Service? _service; // ← тоже nullable
  Timer? _timer;
  AppConfig? _appConfig;

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _loadInfo());
  }

  Future<void> _loadInfo() async {
    try {
      _appConfig = await ConfigService.loadConfig();
      _service = await Service.create();
      final info = await _service!.getInfoSchedule(); // ← await вместо then
      setState(() {
        _info = info;
      });
      _saveSettings(_appConfig, info);
    } catch (e) {
      debugPrint("Ошибка при загрузке info: $e");
    }
  }

  Future<void> _saveSettings(AppConfig? conf, InfoSchedule info) async {
    try {
      SettingsDto c = info.settings;
      bool save = false;
      if (c.priceHiddenTime != conf!.priceHiddenTime) save = true;
      if (c.version != conf.newVersion) save = true;
      if (c.updateUrl != conf.updateUrl) save = true;
      if (save) {
        AppConfig config = AppConfig(
          apiUrl: conf.apiUrl,
          updateUrl: c.updateUrl,
          deviceId: conf.deviceId,
          version: conf.version,
          newVersion: c.version,
          priceHiddenTime: c.priceHiddenTime,
        );
        await ConfigService.saveConfig(config);
      }
    } catch (e) {
      debugPrint("Ошибка при записи настроек info: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // ← не забудь отменить таймер
    super.dispose();
  }

  bool isHiddenTimePanel() {
    if (!_info!.done) return false;
    Duration duration = Duration(minutes: _appConfig!.priceHiddenTime);
    if (_info!.endTime.add(duration).isBefore(DateTime.now())) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Показываем загрузку пока данные не загружены
    if (_info == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),
        ),
      );
    }

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(40), // ← исправил
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      _info!.clubName,
                                      // ← теперь безопасно использовать
                                      style: AppTextStyles.clubName(context),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _info!.displayText,
                                      // ← теперь безопасно использовать
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
                                  '1 saat ${_info!.tablePricePerHour.toStringAsFixed(2)} azn',
                                  style: AppTextStyles.subtitle(context),
                                ),
                              ),
                            ),
                            SizedBox(height: Utils.getHeightSize(context, 20)),
                            Expanded(
                              child: Row(
                                children: [
                                  const Expanded(child: DiscountCard()),
                                  const SizedBox(width: 40),
                                  !isHiddenTimePanel()
                                      ? Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                flex: 0,
                                                child: GamePriceCard(
                                                  info: _info!,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Spacer(),
                                  const SizedBox(width: 40),
                                  const Expanded(child: SalesCard()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _info!.blocked ? BlockedCard() : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
