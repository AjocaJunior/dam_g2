class CapturedPhoto {
  const CapturedPhoto({
    required this.bytes,
    required this.mimeType,
    required this.name,
  });

  final List<int> bytes;
  final String mimeType;
  final String name;
}
