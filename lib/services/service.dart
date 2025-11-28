import 'package:dio/dio.dart';
import 'package:tvc/models/discount.dart';
import 'package:tvc/models/info_schedule.dart';
import 'package:tvc/models/sales.dart';
import 'package:tvc/services/config_service.dart';

class Service {
  late final Dio _dio;

  Service._(this._dio);

  /// Фабричный конструктор, чтобы корректно дождаться загрузки конфига
  static Future<Service> create() async {
    final config = await ConfigService.loadConfig();

    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiUrl, // если loadConfig() возвращает объект с baseUrl
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    return Service._(dio);
  }

  /// Получение списка продаж
  Future<List<Sales>> getSales() async {
    try {
      final response = await _dio.get('/sales/get');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => Sales.fromJson(item))
            .toList();
      } else {
        throw Exception('Некорректный ответ сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка обработки данных: $e');
    }
  }

  /// Получение списка скидок
  Future<List<Discount>> getDiscounts() async {
    try {
      final response = await _dio.get('/pricing/get_discounts');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => Discount.fromJson(item))
            .toList();
      } else {
        throw Exception('Некорректный ответ сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка обработки данных: $e');
    }
  }

  Future<InfoSchedule> getInfoSchedule() async {
    try {
      final config = await ConfigService.loadConfig();
      final response = await _dio.get('/sch/get-time/${config.deviceId}');

      if (response.statusCode == 200) {
        return InfoSchedule.fromJson(response.data);
      } else {
        throw Exception('Некорректный ответ сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка обработки данных: $e');
    }
  }
}
