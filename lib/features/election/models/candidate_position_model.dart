class PositionModel {
  final String title;
  final List<String> candidates;

  PositionModel({required this.title, required this.candidates});

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      title: map['name'] ?? 'Untitled',
      candidates: List<String>.from(map['candidates'] ?? []),
    );
  }
}