import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/fuel_station.dart';

class OverpassService {
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';
  static const String _cacheBoxName = 'fuel_stations_cache';
  static const String _cacheKey = 'stations';
  static const String _cacheTimeKey = 'cache_time';

  // مدة صلاحية الكاش: 24 ساعة
  static const Duration _cacheDuration = Duration(hours: 24);

  // الاستعلام اللي يغطي: كركوك، الحويجة، الدبس، داقوق، الرياض، تازة
  static const String _query = r'''
  [out:json][timeout:60];

  (
    node["amenity"="fuel"](35.05, 43.70, 35.75, 44.55);
    way["amenity"="fuel"](35.05, 43.70, 35.75, 44.55);
    relation["amenity"="fuel"](35.05, 43.70, 35.75, 44.55);
  );

  out center;
  ''';

  /// جلب المحطات مع التخزين المؤقت
  static Future<List<FuelStation>> fetchStations({
    bool forceRefresh = false,
  }) async {
    final box = await Hive.openBox(_cacheBoxName);

    // التحقق من الكاش
    if (!forceRefresh) {
      final cachedStations = await _getCachedStations(box);
      if (cachedStations != null) {
        return cachedStations;
      }
    }

    // جلب من الإنترنت
    try {
      final stations = await _fetchFromNetwork();
      await _cacheStations(box, stations);
      return stations;
    } catch (e) {
      // إذا فشل الإنترنت، حاول استخدام الكاش القديم
      final oldCache = box.get(_cacheKey);
      if (oldCache != null) {
        return _parseStationsFromJson(oldCache as String);
      }
      rethrow;
    }
  }

  /// التحقق من الكاش وإرجاعه إذا كان صالحاً
  static Future<List<FuelStation>?> _getCachedStations(Box box) async {
    final cacheTime = box.get(_cacheTimeKey) as int?;
    final cachedData = box.get(_cacheKey) as String?;

    if (cacheTime == null || cachedData == null) return null;

    final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    final now = DateTime.now();

    // إذا الكاش منتهي الصلاحية
    if (now.difference(cacheDateTime) > _cacheDuration) return null;

    return _parseStationsFromJson(cachedData);
  }

  /// حفظ المحطات في الكاش
  static Future<void> _cacheStations(
    Box box,
    List<FuelStation> stations,
  ) async {
    final jsonList = stations
        .map((s) => {'id': s.id, 'name': s.name, 'lat': s.lat, 'lon': s.lon})
        .toList();

    await box.put(_cacheKey, jsonEncode(jsonList));
    await box.put(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// تحويل JSON إلى قائمة محطات
  static List<FuelStation> _parseStationsFromJson(String jsonData) {
    final list = jsonDecode(jsonData) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return FuelStation(
        id: map['id'] as String,
        name: map['name'] as String,
        lat: (map['lat'] as num).toDouble(),
        lon: (map['lon'] as num).toDouble(),
      );
    }).toList();
  }

  /// جلب المحطات من الإنترنت
  static Future<List<FuelStation>> _fetchFromNetwork() async {
    final response = await http
        .post(Uri.parse(_endpoint), body: {'data': _query})
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
        );

    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل المحطات (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List<dynamic>?) ?? [];

    final stations = <FuelStation>[];

    for (final e in elements) {
      final map = e as Map<String, dynamic>;
      final tags = (map['tags'] as Map<String, dynamic>?) ?? {};
      final name = tags['name'] as String? ?? 'محطة وقود';

      // node: lat/lon | way/relation: center.lat/center.lon
      final lat = (map['lat'] ?? map['center']?['lat']) as num?;
      final lon = (map['lon'] ?? map['center']?['lon']) as num?;

      if (lat == null || lon == null) continue;

      stations.add(
        FuelStation(
          id: '${map['id']}',
          name: name,
          lat: lat.toDouble(),
          lon: lon.toDouble(),
        ),
      );
    }

    return stations;
  }
}
