// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:minimal_radio/screens/player.dart';
import 'package:minimal_radio/utils/radio_browser_service.dart';
import 'package:minimal_radio/utils/radio_stations.dart';
import 'package:minimal_radio/utils/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<RadioStation> searchResults = [];
  List<RadioStation> popularStations = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPopularStations();
  }

  Future<void> _loadPopularStations() async {
    setState(() => isLoading = true);
    final stations = await RadioBrowserService.getPopularStations();
    setState(() {
      popularStations = stations;
      isLoading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    setState(() => isLoading = true);
    final results = await RadioBrowserService.searchStations(query);
    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void _navigateToPlayer(RadioStation station) async {
    try {
      await StorageService.addRecent(station);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlayerScreen(station: station)),
      );
    } catch (e) {
      print('Ошибка при навигации: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text(
          'Поиск станций',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Введите название станции...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchResults = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSecondary,
              ),
              onChanged: _search,
              onSubmitted: _search,
            ),
          ),

          // Результаты
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  )
                : searchResults.isNotEmpty
                ? _buildSearchResults()
                : _buildPopularStations(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Результаты поиска (${searchResults.length})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) =>
                _buildStationTile(searchResults[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularStations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Популярные станции',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: popularStations.length,
            itemBuilder: (context, index) =>
                _buildStationTile(popularStations[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStationTile(RadioStation station) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                color: Theme.of(context).colorScheme.onSecondary,
                elevation: 1,
                child: ListTile(
                  leading: Icon(
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
                  trailing: Icon(
                    Icons.play_circle_outline,
                    color: Theme.of(context).colorScheme.surface,
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
