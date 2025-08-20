import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimal_radio/utils/audio_service.dart';
import 'package:minimal_radio/utils/storage_service.dart';
import 'package:minimal_radio/utils/radio_stations.dart';
import 'dart:async';

class PlayerScreen extends StatefulWidget {
  final RadioStation station;

  const PlayerScreen({super.key, required this.station});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  String status = 'Подключение...';
  bool isFavorite = false;
  double volume = 0.7;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _setupPlayerListener();
    _setupAnimations();
    volume = AudioService.volume;
    _play();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupPlayerListener() {
    _playerStateSubscription = AudioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
          status = state.processingState == ProcessingState.loading
              ? 'Подключение...'
              : state.processingState == ProcessingState.buffering
              ? 'Буферизация...'
              : state.processingState == ProcessingState.ready
              ? 'Воспроизведение'
              : 'Остановлено';
        });

        // Управление анимацией пульсации
        if (state.playing && state.processingState == ProcessingState.ready) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    });
  }

  Future<void> _checkFavorite() async {
    try {
      final favorites = await StorageService.getFavorites();
      if (mounted) {
        setState(() {
          isFavorite = favorites.any((s) => s.url == widget.station.url);
        });
      }
    } catch (e) {
      print('Ошибка при проверке избранного: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await StorageService.removeFavorite(widget.station);
      } else {
        await StorageService.addFavorite(widget.station);
      }
      if (mounted) {
        setState(() {
          isFavorite = !isFavorite;
        });
      }
    } catch (e) {
      print('Ошибка при изменении избранного: $e');
    }
  }

  Future<void> _play() async {
    try {
      await AudioService.play(widget.station.url);
      if (mounted) {
        setState(() => isPlaying = true);
      }
    } catch (e) {
      print('Ошибка воспроизведения: $e');
      if (mounted) {
        setState(() {
          status = 'Ошибка воспроизведения';
          isPlaying = false;
        });
      }
    }
  }

  Future<void> _pause() async {
    try {
      await AudioService.pause();
      if (mounted) {
        setState(() => isPlaying = false);
      }
    } catch (e) {
      print('Ошибка паузы: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _pulseController.dispose();
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.station.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Theme.of(context).colorScheme.onSecondary,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.station.imagePath != null
                      ? Image.asset(
                          widget.station.imagePath!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.radio,
                              size: 200,
                              color: Theme.of(context).colorScheme.surface,
                            );
                          },
                        )
                      : Icon(
                          Icons.radio,
                          size: 200,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 20),

            // Анимированная кнопка воспроизведения
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isPlaying ? _pulseAnimation.value : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: IconButton(
                      onPressed: isPlaying ? _pause : _play,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Theme.of(context).colorScheme.surface,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Слайдер громкости
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.volume_down,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      Text(
                        'Громкость: ${(volume * 100).round()}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.surface,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.3),
                      thumbColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() => volume = value);
                        AudioService.setVolume(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
