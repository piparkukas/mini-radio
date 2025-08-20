class RadioStation {
  final String name;
  final String description;
  final String url;
  final String? imagePath;

  RadioStation({
    required this.name,
    required this.description,
    required this.url,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'url': url,
      'imagePath': imagePath,
    };
  }

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imagePath: json['imagePath'],
    );
  }
}