import 'package:hive/hive.dart';

/// Local data source using Hive database
class HiveDataSource {
  /// Initialize Hive boxes
  Future<void> initialize() async {
    // Boxes are opened in main.dart
    // This class can be extended for additional Hive operations
  }

  /// Get conversations box
  Box getConversationsBox() => Hive.box('conversations');

  /// Get tasks box
  Box getTasksBox() => Hive.box('tasks');

  /// Get settings box
  Box getSettingsBox() => Hive.box('settings');

  /// Clear all data
  Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk('conversations');
    await Hive.deleteBoxFromDisk('tasks');
    await Hive.deleteBoxFromDisk('settings');
  }
}
