import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum MaUNotificationChannel {
  tasks(
    id: 'ma_u_tasks',
    name: 'Tareas',
    description: 'Recordatorios de entregas, trabajos y pendientes.',
  ),
  study(
    id: 'ma_u_study',
    name: 'Estudio',
    description: 'Recordatorios de sesiones y bloques de enfoque.',
  );

  const MaUNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

class ReminderOption {
  const ReminderOption({required this.minutesBefore, required this.label});

  final int minutesBefore;
  final String label;
}

class MaUNotifications {
  MaUNotifications._();

  static final instance = MaUNotifications._();

  static const _taskNotificationOffset = 100000;
  static const _studyNotificationOffset = 200000;
  static const defaultTaskReminderMinutes = 1440;
  static const defaultStudyReminderMinutes = 10;
  static const reminderOptions = [
    ReminderOption(minutesBefore: 5, label: '5 min antes'),
    ReminderOption(minutesBefore: 10, label: '10 min antes'),
    ReminderOption(minutesBefore: 30, label: '30 min antes'),
    ReminderOption(minutesBefore: 60, label: '1 hora antes'),
    ReminderOption(minutesBefore: 1440, label: '1 dia antes'),
  ];

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  var _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);
    await _createAndroidChannel(MaUNotificationChannel.tasks);
    await _createAndroidChannel(MaUNotificationChannel.study);
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidResult = await android?.requestNotificationsPermission();
    if (androidResult != null) {
      return androidResult;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return iosResult ?? true;
  }

  Future<bool> areNotificationsEnabled() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidResult = await android?.areNotificationsEnabled();
    if (androidResult != null) {
      return androidResult;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosResult = await ios?.checkPermissions();
    return iosResult?.isEnabled ?? true;
  }

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required String subjectName,
    required DateTime dueDate,
    required int minutesBefore,
  }) {
    return _scheduleReminder(
      id: taskNotificationId(taskId),
      channel: MaUNotificationChannel.tasks,
      title: 'Tarea: $title',
      body: '$subjectName - ${_reminderLabel(minutesBefore)}',
      eventAt: dueDate,
      minutesBefore: minutesBefore,
      payload: 'task:$taskId',
    );
  }

  Future<void> scheduleStudyReminder({
    required int sessionId,
    required String title,
    required String subjectName,
    required DateTime startsAt,
    required int minutesBefore,
  }) {
    return _scheduleReminder(
      id: studyNotificationId(sessionId),
      channel: MaUNotificationChannel.study,
      title: 'Estudio: $title',
      body: '$subjectName - ${_reminderLabel(minutesBefore)}',
      eventAt: startsAt,
      minutesBefore: minutesBefore,
      payload: 'study:$sessionId',
    );
  }

  Future<void> cancelTaskReminder(int taskId) {
    return _plugin.cancel(id: taskNotificationId(taskId));
  }

  Future<void> cancelStudyReminder(int sessionId) {
    return _plugin.cancel(id: studyNotificationId(sessionId));
  }

  bool canSchedule(DateTime eventAt, int minutesBefore) {
    return eventAt
        .subtract(Duration(minutes: minutesBefore))
        .isAfter(DateTime.now());
  }

  int taskNotificationId(int taskId) => _taskNotificationOffset + taskId;

  int studyNotificationId(int sessionId) =>
      _studyNotificationOffset + sessionId;

  Future<void> _scheduleReminder({
    required int id,
    required MaUNotificationChannel channel,
    required String title,
    required String body,
    required DateTime eventAt,
    required int minutesBefore,
    required String payload,
  }) async {
    await initialize();
    await _plugin.cancel(id: id);

    final scheduledAt = eventAt.subtract(Duration(minutes: minutesBefore));
    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: payload,
    );
  }

  Future<void> _createAndroidChannel(MaUNotificationChannel channel) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        channel.id,
        channel.name,
        description: channel.description,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (error) {
      debugPrint('Ma-U notifications timezone fallback: $error');
      tz.setLocalLocation(tz.getLocation('America/Bogota'));
    }
  }

  String _reminderLabel(int minutesBefore) {
    return switch (minutesBefore) {
      5 => 'en 5 minutos',
      10 => 'en 10 minutos',
      30 => 'en 30 minutos',
      60 => 'en 1 hora',
      1440 => 'manana',
      _ => 'en $minutesBefore minutos',
    };
  }
}
