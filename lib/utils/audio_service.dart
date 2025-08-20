import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = true;
      // Устанавливаем начальную громкость
      await _player.setVolume(0.7);
    }
  }

  static Future<void> play(String url) async {
    try {
      await init();

      // Полностью останавливаем и очищаем предыдущий источник
      await _player.stop();

      // Небольшая задержка для полной остановки
      await Future.delayed(Duration(milliseconds: 100));

      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('Ошибка воспроизведения: $e');
      rethrow;
    }
  }

  static Future<void> pause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      }
    } catch (e) {
      print('Ошибка при паузе: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Ошибка при остановке: $e');
    }
  }

  static Future<void> setVolume(double volume) async {
    try {
      await init();
      await _player.setVolume(volume);
    } catch (e) {
      print('Ошибка при изменении громкости: $e');
    }
  }

  static double get volume => _player.volume;

  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  static bool get isPlaying => _player.playing;

  static PlayerState get playerState => _player.playerState;

  static void dispose() {
    try {
      _player.dispose();
      _isInitialized = false;
    } catch (e) {
      print('Ошибка при освобождении ресурсов: $e');
    }
  }
}
