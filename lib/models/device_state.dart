/// Модели device API pscs v2 (`GET /api/v1/device/state`, контракт `pscs-v2.yaml`, spec/20 §5.1 и §10).
///
/// Написаны руками по контракту: генератор (tool/gen-api.sh, built_value) тянет лишние зависимости на Orange Pi,
/// а полей немного. Деньги — гяпики (целые), время — ISO-8601 со смещением клуба. tvc ничего не считает (R-TVC-1):
/// все суммы приходят от pscs.
library;

/// Позиция продажи в текущем сеансе (`session.sales[]`).
class SaleItem {
  final String productName;
  final int quantity;
  final int priceQepik;
  final int totalQepik;

  const SaleItem({
    required this.productName,
    required this.quantity,
    required this.priceQepik,
    required this.totalQepik,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    productName: json['productName'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    priceQepik: (json['priceQepik'] as num?)?.toInt() ?? 0,
    totalQepik: (json['totalQepik'] as num?)?.toInt() ?? 0,
  );
}

/// Текущий сеанс стола (`TableSession` контракта, D-37).
class TableSession {
  final String mode; // TIME | MONEY | UNLIMITED
  final DateTime startedAt;
  final DateTime? plannedEndAt;
  final int? timeSetMinutes;
  final int playedMinutes;
  final int? remainingMinutes;
  final int basePriceQepik;
  final int discountPercent;
  final int currentPriceQepik;
  final int salesTotalQepik;
  final int grandTotalQepik;
  final int? paidQepik;
  final List<SaleItem> sales;

  const TableSession({
    required this.mode,
    required this.startedAt,
    required this.plannedEndAt,
    required this.timeSetMinutes,
    required this.playedMinutes,
    required this.remainingMinutes,
    required this.basePriceQepik,
    required this.discountPercent,
    required this.currentPriceQepik,
    required this.salesTotalQepik,
    required this.grandTotalQepik,
    required this.paidQepik,
    required this.sales,
  });

  bool get unlimited => mode == 'UNLIMITED';

  factory TableSession.fromJson(Map<String, dynamic> json) => TableSession(
    mode: json['mode'] as String? ?? 'TIME',
    startedAt: DateTime.parse(json['startedAt'] as String),
    plannedEndAt: json['plannedEndAt'] == null
        ? null
        : DateTime.parse(json['plannedEndAt'] as String),
    timeSetMinutes: (json['timeSetMinutes'] as num?)?.toInt(),
    playedMinutes: (json['playedMinutes'] as num?)?.toInt() ?? 0,
    remainingMinutes: (json['remainingMinutes'] as num?)?.toInt(),
    basePriceQepik: (json['basePriceQepik'] as num?)?.toInt() ?? 0,
    discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
    currentPriceQepik: (json['currentPriceQepik'] as num?)?.toInt() ?? 0,
    salesTotalQepik: (json['salesTotalQepik'] as num?)?.toInt() ?? 0,
    grandTotalQepik: (json['grandTotalQepik'] as num?)?.toInt() ?? 0,
    paidQepik: (json['paidQepik'] as num?)?.toInt(),
    sales: ((json['sales'] as List<dynamic>?) ?? const [])
        .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// Строка чека (`ReceiptSale`).
class ReceiptSale {
  final String productName;
  final int quantity;
  final int totalQepik;

  const ReceiptSale({
    required this.productName,
    required this.quantity,
    required this.totalQepik,
  });

  factory ReceiptSale.fromJson(Map<String, dynamic> json) => ReceiptSale(
    productName: json['productName'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    totalQepik: (json['totalQepik'] as num?)?.toInt() ?? 0,
  );
}

/// Скидка в чеке (`ReceiptDiscount`).
class ReceiptDiscount {
  final String type;
  final String name;
  final int percent;

  const ReceiptDiscount({
    required this.type,
    required this.name,
    required this.percent,
  });

  factory ReceiptDiscount.fromJson(Map<String, dynamic> json) =>
      ReceiptDiscount(
        type: json['type'] as String? ?? '',
        name: json['name'] as String? ?? '',
        percent: (json['percent'] as num?)?.toInt() ?? 0,
      );
}

/// Чек завершённого сеанса, пока стол в статусе FINISHED (`lastReceipt`, R-TVC-12).
class LastReceipt {
  final String mode;
  final DateTime startedAt;
  final DateTime stoppedAt;
  final int playedMinutes;
  final int basePriceQepik;
  final List<ReceiptDiscount> discounts;
  final int totalPercent;
  final int finalPriceQepik;
  final List<ReceiptSale> sales;
  final int salesTotalQepik;
  final int grandTotalQepik;
  final int? paidQepik;
  final int? changeQepik;
  final DateTime showUntil;

  const LastReceipt({
    required this.mode,
    required this.startedAt,
    required this.stoppedAt,
    required this.playedMinutes,
    required this.basePriceQepik,
    required this.discounts,
    required this.totalPercent,
    required this.finalPriceQepik,
    required this.sales,
    required this.salesTotalQepik,
    required this.grandTotalQepik,
    required this.paidQepik,
    required this.changeQepik,
    required this.showUntil,
  });

  factory LastReceipt.fromJson(Map<String, dynamic> json) => LastReceipt(
    mode: json['mode'] as String? ?? 'TIME',
    startedAt: DateTime.parse(json['startedAt'] as String),
    stoppedAt: DateTime.parse(json['stoppedAt'] as String),
    playedMinutes: (json['playedMinutes'] as num?)?.toInt() ?? 0,
    basePriceQepik: (json['basePriceQepik'] as num?)?.toInt() ?? 0,
    discounts: ((json['discounts'] as List<dynamic>?) ?? const [])
        .map((e) => ReceiptDiscount.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalPercent: (json['totalPercent'] as num?)?.toInt() ?? 0,
    finalPriceQepik: (json['finalPriceQepik'] as num?)?.toInt() ?? 0,
    sales: ((json['sales'] as List<dynamic>?) ?? const [])
        .map((e) => ReceiptSale.fromJson(e as Map<String, dynamic>))
        .toList(),
    salesTotalQepik: (json['salesTotalQepik'] as num?)?.toInt() ?? 0,
    grandTotalQepik: (json['grandTotalQepik'] as num?)?.toInt() ?? 0,
    paidQepik: (json['paidQepik'] as num?)?.toInt(),
    changeQepik: (json['changeQepik'] as num?)?.toInt(),
    showUntil: DateTime.parse(json['showUntil'] as String),
  );
}

/// Ближайшая бронь стола (`TableReservation`, R-TVC-15).
class TableReservation {
  final DateTime reservedFrom;
  final DateTime holdUntil;
  final String customerName;

  const TableReservation({
    required this.reservedFrom,
    required this.holdUntil,
    required this.customerName,
  });

  factory TableReservation.fromJson(Map<String, dynamic> json) =>
      TableReservation(
        reservedFrom: DateTime.parse(json['reservedFrom'] as String),
        holdUntil: DateTime.parse(json['holdUntil'] as String),
        customerName: json['customerName'] as String? ?? '',
      );
}

/// Скидка на экране ожидания (`IdleDiscount`): либо день недели с интервалом, либо порог времени игры.
class IdleDiscount {
  final String name;
  final int percent;
  final String? weekDay;
  final String? timeFrom;
  final String? timeTo;
  final int? playTimeMinutes;

  const IdleDiscount({
    required this.name,
    required this.percent,
    this.weekDay,
    this.timeFrom,
    this.timeTo,
    this.playTimeMinutes,
  });

  factory IdleDiscount.fromJson(Map<String, dynamic> json) => IdleDiscount(
    name: json['name'] as String? ?? '',
    percent: (json['percent'] as num?)?.toInt() ?? 0,
    weekDay: json['weekDay'] as String?,
    timeFrom: json['timeFrom'] as String?,
    timeTo: json['timeTo'] as String?,
    playTimeMinutes: (json['playTimeMinutes'] as num?)?.toInt(),
  );
}

/// Позиция прайс-листа (`IdleProduct`).
class IdleProduct {
  final String name;
  final int priceQepik;

  const IdleProduct({required this.name, required this.priceQepik});

  factory IdleProduct.fromJson(Map<String, dynamic> json) => IdleProduct(
    name: json['name'] as String? ?? '',
    priceQepik: (json['priceQepik'] as num?)?.toInt() ?? 0,
  );
}

/// Блок экрана ожидания (`IdleBlock`, D-17/D-37).
class IdleBlock {
  final List<IdleDiscount> discounts;
  final List<IdleProduct> products;
  final String productsDisplayMode; // TOP_N | ALL_PAGED
  final int productsPerPage;
  final int pageIntervalSec;
  final bool priceHidden;

  const IdleBlock({
    required this.discounts,
    required this.products,
    required this.productsDisplayMode,
    required this.productsPerPage,
    required this.pageIntervalSec,
    required this.priceHidden,
  });

  /// В режиме ALL_PAGED прайс-лист прокручивается сам (D-37).
  bool get autoScroll => productsDisplayMode == 'ALL_PAGED';

  factory IdleBlock.fromJson(Map<String, dynamic> json) => IdleBlock(
    discounts: ((json['discounts'] as List<dynamic>?) ?? const [])
        .map((e) => IdleDiscount.fromJson(e as Map<String, dynamic>))
        .toList(),
    products: ((json['products'] as List<dynamic>?) ?? const [])
        .map((e) => IdleProduct.fromJson(e as Map<String, dynamic>))
        .toList(),
    productsDisplayMode: json['productsDisplayMode'] as String? ?? 'TOP_N',
    productsPerPage: (json['productsPerPage'] as num?)?.toInt() ?? 12,
    pageIntervalSec: (json['pageIntervalSec'] as num?)?.toInt() ?? 8,
    priceHidden: json['priceHidden'] as bool? ?? false,
  );

  static const empty = IdleBlock(
    discounts: [],
    products: [],
    productsDisplayMode: 'TOP_N',
    productsPerPage: 12,
    pageIntervalSec: 8,
    priceHidden: false,
  );
}

/// Статусы стола (`TableState.status`).
abstract final class TableStatus {
  static const free = 'FREE';
  static const reserved = 'RESERVED';
  static const activeLimited = 'ACTIVE_LIMITED';
  static const activeUnlimited = 'ACTIVE_UNLIMITED';
  static const finished = 'FINISHED';
  static const blocked = 'BLOCKED';
}

/// Полное состояние экрана (`DeviceState` = `TableState` + `idle` + язык и название клуба).
class DeviceState {
  final int tableId;
  final String name;
  final String displayText;
  final int pricePerHourQepik;
  final bool blockPs;
  final String? blockText;
  final bool blockPending;
  final String status;
  final TableSession? session;
  final TableReservation? reservation;
  final LastReceipt? lastReceipt;
  final DateTime serverTime;
  final IdleBlock idle;
  final String language;
  final String clubName;

  /// Локальный момент получения состояния — для интерполяции таймера от `serverTime` (R-TVC-1).
  final DateTime receivedAt;

  DeviceState({
    required this.tableId,
    required this.name,
    required this.displayText,
    required this.pricePerHourQepik,
    required this.blockPs,
    required this.blockText,
    required this.blockPending,
    required this.status,
    required this.session,
    required this.reservation,
    required this.lastReceipt,
    required this.serverTime,
    required this.idle,
    required this.language,
    required this.clubName,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  bool get isActive =>
      status == TableStatus.activeLimited ||
      status == TableStatus.activeUnlimited;
  bool get isBlocked => status == TableStatus.blocked;
  bool get isFinished => status == TableStatus.finished;

  /// Сколько прошло с момента расчёта состояния на сервере (по локальным часам).
  Duration get age => DateTime.now().difference(receivedAt);

  /// Текущее время сервера по интерполяции.
  DateTime get serverNow => serverTime.add(age);

  factory DeviceState.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) => DeviceState(
    tableId: (json['tableId'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    displayText: json['displayText'] as String? ?? '',
    pricePerHourQepik: (json['pricePerHourQepik'] as num?)?.toInt() ?? 0,
    blockPs: json['blockPs'] as bool? ?? false,
    blockText: json['blockText'] as String?,
    blockPending: json['blockPending'] as bool? ?? false,
    status: json['status'] as String? ?? TableStatus.free,
    session: json['session'] == null
        ? null
        : TableSession.fromJson(json['session'] as Map<String, dynamic>),
    reservation: json['reservation'] == null
        ? null
        : TableReservation.fromJson(
            json['reservation'] as Map<String, dynamic>,
          ),
    lastReceipt: json['lastReceipt'] == null
        ? null
        : LastReceipt.fromJson(json['lastReceipt'] as Map<String, dynamic>),
    serverTime: DateTime.parse(json['serverTime'] as String),
    idle: json['idle'] == null
        ? IdleBlock.empty
        : IdleBlock.fromJson(json['idle'] as Map<String, dynamic>),
    language: json['language'] as String? ?? 'az',
    clubName: json['clubName'] as String? ?? '',
    receivedAt: receivedAt,
  );
}

/// Форматирование денег на экране: гяпики → `12.50 azn` (как в прайс-листе).
String formatAzn(int qepik) {
  final sign = qepik < 0 ? '-' : '';
  final abs = qepik.abs();
  return '$sign${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')} azn';
}
