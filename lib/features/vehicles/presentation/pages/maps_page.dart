import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/map_navigation_utils.dart';
import '../../data/models/fuel_station.dart';
import '../../data/repositories/overpass_service.dart';

/// صفحة الخرائط - محطات الوقود
class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late Future<List<FuelStation>> _futureStations;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _futureStations = OverpassService.fetchStations();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      // التحقق من الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // الحصول على الموقع
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('maps')), centerTitle: true),
      body: SafeArea(
        child: FutureBuilder<List<FuelStation>>(
          future: _futureStations,
          builder: (context, snapshot) {
            // حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('loading_fuel_stations'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            // حالة الخطأ
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('error_loading_stations'),
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _futureStations = OverpassService.fetchStations();
                          });
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stations = snapshot.data ?? [];

            // لو ماكو نتائج
            if (stations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF00897B,
                          ).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_gas_station_rounded,
                          size: 48,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('no_fuel_stations'),
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // مركز الخريطة (وسط كركوك)
            const initialCenter = LatLng(35.47, 44.39);

            // حدود محافظة كركوك والمناطق المجاورة (لا يمكن الخروج منها)
            final kirkukBounds = LatLngBounds(
              const LatLng(34.85, 43.40), // جنوب غرب
              const LatLng(35.95, 44.85), // شمال شرق
            );

            return FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 10.0,
                minZoom: 9.0,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: kirkukBounds,
                ),
              ),
              children: [
                // طبقة الخريطة من OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.historea.kifuel',
                ),

                // طبقة علامات محطات الوقود
                MarkerLayer(
                  markers: [
                    // علامات محطات الوقود
                    ...stations.map(
                      (s) => Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(s.lat, s.lon),
                        child: _FuelMarker(
                          station: s,
                          onTap: () {
                            openInMapsOrWaze(
                              lat: s.lat,
                              lon: s.lon,
                              name: s.name,
                              context: context,
                            );
                          },
                        ),
                      ),
                    ),
                    // علامة موقع المستخدم
                    if (_userLocation != null)
                      Marker(
                        width: 50,
                        height: 50,
                        point: _userLocation!,
                        child: const _UserLocationMarker(),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// علامة موقع المستخدم
class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الدائرة الخارجية (نبض)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        // الدائرة الداخلية
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ويدجت صغيرة لعلامة المحطة على الخريطة
class _FuelMarker extends StatelessWidget {
  final FuelStation station;
  final VoidCallback onTap;

  const _FuelMarker({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              size: 22,
              color: Color(0xFF00897B),
            ),
          ),
        ],
      ),
    );
  }
}
