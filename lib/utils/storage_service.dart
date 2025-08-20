import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minimal_radio/utils/radio_stations.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _recentKey = 'recent';

  static Future<List<RadioStation>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map(
              (json) => RadioStation(
                name: json['name'],
                description: json['description'],
                url: json['url'],
                imagePath: json['imagePath'],
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Ошибка при загрузке избранных: $e');
      return [];
    }
  }

  static Future<void> addFavorite(RadioStation station) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.any((s) => s.url == station.url)) {
        favorites.add(station);
        await _saveFavorites(favorites);
      }
    } catch (e) {
      print('Ошибка при добавлении в избранное: $e');
    }
  }

  static Future<void> removeFavorite(RadioStation station) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((s) => s.url == station.url);
      await _saveFavorites(favorites);
    } catch (e) {
      print('Ошибка при удалении из избранного: $e');
    }
  }

  static Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Ошибка при очистке избранного: $e');
    }
  }

  static Future<List<RadioStation>> getRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map(
              (json) => RadioStation(
                name: json['name'],
                description: json['description'],
                url: json['url'],
                imagePath: json['imagePath'],
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Ошибка при загрузке недавних: $e');
      return [];
    }
  }

  static Future<void> addRecent(RadioStation station) async {
    try {
      final recent = await getRecent();
      recent.removeWhere((s) => s.url == station.url);
      recent.insert(0, station);
      if (recent.length > 5) recent.removeLast(); // Лимит на 5 недавних
      await _saveRecent(recent);
    } catch (e) {
      print('Ошибка при добавлении в недавние: $e');
    }
  }

  static Future<void> _saveFavorites(List<RadioStation> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = favorites
          .map(
            (s) => {
              'name': s.name,
              'description': s.description,
              'url': s.url,
              'imagePath': s.imagePath,
            },
          )
          .toList();
      await prefs.setString(_favoritesKey, json.encode(jsonList));
    } catch (e) {
      print('Ошибка при сохранении избранных: $e');
    }
  }

  static Future<void> _saveRecent(List<RadioStation> recent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = recent
          .map(
            (s) => {
              'name': s.name,
              'description': s.description,
              'url': s.url,
              'imagePath': s.imagePath,
            },
          )
          .toList();
      await prefs.setString(_recentKey, json.encode(jsonList));
    } catch (e) {
      print('Ошибка при сохранении недавних: $e');
    }
  }
}
