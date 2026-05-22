import 'app_database.dart';

class AppDatabaseProvider {
  const AppDatabaseProvider._();

  static AppDatabase? _instance;

  static AppDatabase get instance {
    return _instance ??= AppDatabase();
  }

  static void overrideForTesting(AppDatabase database) {
    _instance = database;
  }

  static Future<void> resetForTesting() async {
    await _instance?.close();
    _instance = null;
  }
}
