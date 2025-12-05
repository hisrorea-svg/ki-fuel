import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  static const String boxName = 'notifications_box';

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    await Hive.openBox<NotificationModel>(boxName);
  }

  Box<NotificationModel> get _box => Hive.box<NotificationModel>(boxName);

  List<NotificationModel> getAll() {
    final list = _box.values.toList();
    // Sort by timestamp descending (newest first)
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<NotificationModel> getUnread() {
    return _box.values.where((n) => !n.isRead).toList();
  }

  Future<void> add(NotificationModel notification) async {
    await _box.put(notification.id, notification);
  }

  Future<void> markAsRead(String id) async {
    final notification = _box.get(id);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _box.values.where((n) => !n.isRead);
    for (var notification in unread) {
      notification.isRead = true;
      await notification.save();
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
