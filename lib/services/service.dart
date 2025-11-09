import 'package:dio/dio.dart';
import 'package:tvc/models/discount.dart';

import '../models/sales.dart';

class Service {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.123:8899',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

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

  Future<List<Discount>> getDiscount() async {
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
}
