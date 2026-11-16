import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/agenda_item.dart';

/// Programme les notifications locales des rappels d'agenda (Android uniquement).
class AgendaNotifications {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Interrupteur « Synchronisation Calendrier » : si faux, aucune notification.
  bool enabled = true;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'agenda_reminders',
      'Rappels de soins',
      channelDescription: "Rappels de l'agenda Pet-Care",
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Les notifications locales ne sont gérées que sur Android dans ce projet.
  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Initialise le plugin une seule fois et demande la permission (Android 13+).
  Future<void> _init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  /// Reprogramme toutes les notifications à partir de la liste des rappels.
  Future<void> sync(List<AgendaItem> items) async {
    if (!_supported) return;
    try {
      await _init();
      await _plugin.cancelAll();
      if (!enabled) return;
      final now = DateTime.now();
      for (final it in items) {
        final at = it.reminderAt;
        if (it.status != 'SCHEDULED' || at == null || !at.isAfter(now)) {
          continue;
        }
        final heure = DateFormat('HH:mm').format(it.scheduledAt.toLocal());
        await _plugin.zonedSchedule(
          id: it.id.hashCode & 0x7fffffff,
          title: it.title,
          body: 'Soin prévu à $heure',
          scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Notifications agenda : $e');
    }
  }
}