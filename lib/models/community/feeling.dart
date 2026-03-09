class Feeling {
  final String _imagePath;
  final String _label;

  Feeling({required String imagePath, required String label})
    : _imagePath = imagePath,
      _label = label;

  String get imagePath => _imagePath;
  String get label => _label;
}
