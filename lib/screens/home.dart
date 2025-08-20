// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:minimal_radio/screens/player.dart';
import 'package:minimal_radio/screens/search.dart';
import 'package:minimal_radio/utils/radio_browser_service.dart';
import 'package:minimal_radio/utils/radio_stations.dart';
import 'package:minimal_radio/utils/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<RadioStation> recent = [];
  List<RadioStation> favorites = [];
  List<RadioStation> popularStations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) {
      return; // Предотвращаем множественные одновременные загрузки
    }

    setState(() => _isLoading = true);

    try {
      final rec = await StorageService.getRecent();
      final fav = await StorageService.getFavorites();
      final popular = await RadioBrowserService.getPopularStations();

      if (mounted) {
        setState(() {
          recent = rec;
          favorites = fav;
          popularStations = popular; // Убираем fallback к локальным станциям
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          popularStations = []; // Пустой список при ошибке
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text(
          'Minimal Radio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Недавно прослушанные
              Text(
                'Недавно прослушанные',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: recent.isEmpty
                    ? Center(
                        child: Text(
                          'Пока ничего не прослушано',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recent.length,
                        itemBuilder: (context, index) =>
                            _buildStationCard(recent[index]),
                      ),
              ),
              const SizedBox(height: 30),

              // Избранные радиостанции
              Text(
                'Избранные радиостанции',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: favorites.isEmpty
                    ? Center(
                        child: Text(
                          'Нет избранных станций',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            favorites.length + 1, // +1 для кнопки очистки
                        itemBuilder: (context, index) {
                          if (index == favorites.length) {
                            // Кнопка очистки в конце списка
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 8),
                              child: Card(
                                color: Colors.red.withOpacity(0.1),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () async {
                                    await StorageService.clearFavorites();
                                    _loadData();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.clear_all,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Очистить все',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return _buildStationCard(favorites[index]);
                        },
                      ),
              ),
              const SizedBox(height: 30),

              // Предлагаем послушать
              Text(
                'Предлагаем послушать',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: popularStations.length,
                itemBuilder: (context, index) =>
                    _buildStationTile(popularStations[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(RadioStation station) {
    return GestureDetector(
      onTap: () => _navigateToPlayer(station),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            color: Theme.of(context).colorScheme.onSecondary,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: station.imagePath != null
                            ? Image.asset(
                                station.imagePath!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.radio,
                                    size: 80,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  );
                                },
                              )
                            : Icon(
                                Icons.radio,
                                size: 80,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationTile(RadioStation station) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                color: Theme.of(context).colorScheme.onSecondary,
                elevation: 1,
                child: ListTile(
                  leading: station.imagePath != null
                      ? Image.asset(
                          station.imagePath!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.radio,
                              size: 48,
                              color: Theme.of(context).colorScheme.surface,
                            );
                          },
                        )
                      : Icon(
                          Icons.radio,
                          size: 48,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                  title: Text(
                    station.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    station.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => _navigateToPlayer(station),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToPlayer(RadioStation station) async {
    if (_isLoading) return; // Предотвращаем навигацию во время загрузки

    try {
      // Добавляем станцию в недавние перед переходом
      await StorageService.addRecent(station);

      if (mounted) {
        final _ = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(station: station),
          ),
        );

        // Обновляем данные при возврате, независимо от результата
        _loadData();
      }
    } catch (e) {
      // Все равно обновляем данные в случае ошибки
      _loadData();
    }
  }
}
