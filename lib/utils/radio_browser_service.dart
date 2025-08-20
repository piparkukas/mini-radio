import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minimal_radio/utils/radio_stations.dart';

class RadioBrowserService {
  static const String baseUrl = 'https://de1.api.radio-browser.info/json';

  // Поиск станций по названию
  static Future<List<RadioStation>> searchStations(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/byname/$query'),
        headers: {'User-Agent': 'MinimalRadio/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .take(20)
            .map(
              (json) => RadioStation(
                name: json['name'] ?? 'Неизвестная станция',
                description: _buildDescription(json),
                url: json['url_resolved'] ?? json['url'] ?? '',
                imagePath: null,
              ),
            )
            .where((station) => station.url.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('Ошибка поиска станций: $e');
      return [];
    }
  }

  // Получение популярных станций
  static Future<List<RadioStation>> getPopularStations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/topclick/15'),
        headers: {'User-Agent': 'MinimalRadio/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => RadioStation(
                name: json['name'] ?? 'Неизвестная станция',
                description: _buildDescription(json),
                url: json['url_resolved'] ?? json['url'] ?? '',
                imagePath: null,
              ),
            )
            .where((station) => station.url.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки популярных станций: $e');
      return [];
    }
  }

  // Создание описания станции из доступных данных
  static String _buildDescription(Map<String, dynamic> json) {
    List<String> parts = [];

    if (json['country'] != null && json['country'].toString().isNotEmpty) {
      parts.add(json['country']);
    }

    if (json['tags'] != null && json['tags'].toString().isNotEmpty) {
      final tags = json['tags'].toString().split(',');
      if (tags.isNotEmpty) {
        parts.add(tags.first.trim());
      }
    }

    if (json['bitrate'] != null) {
      parts.add('${json['bitrate']} kbps');
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'Интернет радио';
  }

  // Поиск по жанру
  static Future<List<RadioStation>> getStationsByTag(String tag) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/bytag/$tag'),
        headers: {'User-Agent': 'MinimalRadio/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .take(20)
            .map(
              (json) => RadioStation(
                name: json['name'] ?? 'Неизвестная станция',
                description: json['tags'] ?? json['country'] ?? '',
                url: json['url_resolved'] ?? json['url'] ?? '',
                imagePath: null,
              ),
            )
            .where((station) => station.url.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('Ошибка поиска по жанру: $e');
      return [];
    }
  }
}
