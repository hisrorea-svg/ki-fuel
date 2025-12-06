import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// خدمة التحقق من الاتصال بالإنترنت
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// تهيئة الخدمة ومراقبة الاتصال
  Future<void> initialize() async {
    // التحقق من الحالة الأولية
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    _connectionController.add(_isConnected);

    // الاستماع للتغييرات
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _isConnected = !results.contains(ConnectivityResult.none);
      _connectionController.add(_isConnected);
    });
  }

  /// التحقق من الاتصال بالإنترنت
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = !result.contains(ConnectivityResult.none);
      return _isConnected;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      // في حالة الخطأ نفترض أنه متصل ونترك التطبيق يعمل
      return true;
    }
  }

  /// التخلص من الموارد
  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}

/// Widget للاستماع لحالة الاتصال
class ConnectivityListener extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showOfflineBanner;

  const ConnectivityListener({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showOfflineBanner = true,
  });

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  final _connectivity = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = _connectivity.isConnected;
    _connectivity.connectionStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected && widget.offlineWidget != null) {
      return widget.offlineWidget!;
    }

    return Column(
      children: [
        if (!_isConnected && widget.showOfflineBanner) const _OfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// شريط تنبيه عدم الاتصال
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            Directionality.of(context) == TextDirection.rtl
                ? 'لا يوجد اتصال بالإنترنت'
                : 'No internet connection',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// دالة مساعدة للتحقق من الاتصال قبل تنفيذ عملية
Future<bool> requireConnectivity(BuildContext context) async {
  final isConnected = await ConnectivityService().checkConnectivity();
  if (!isConnected && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Directionality.of(context) == TextDirection.rtl
              ? 'لا يوجد اتصال بالإنترنت'
              : 'No internet connection',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
  return isConnected;
}
