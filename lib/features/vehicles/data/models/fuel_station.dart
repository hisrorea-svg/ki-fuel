/// نموذج محطة الوقود
class FuelStation {
  final String id;
  final String name;
  final double lat;
  final double lon;

  const FuelStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  @override
  String toString() =>
      'FuelStation(id: $id, name: $name, lat: $lat, lon: $lon)';
}
