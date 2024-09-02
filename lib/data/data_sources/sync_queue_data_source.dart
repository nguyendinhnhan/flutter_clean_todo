import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SyncQueueDataSource {
  final SharedPreferences sharedPreferences;
  final String syncQueueKey = 'syncQueue';

  SyncQueueDataSource(this.sharedPreferences);

  Future<void> addOperationToQueue(Map<String, dynamic> operation) async {
    final queue = await getSyncQueue();
    queue.add(operation);
    await sharedPreferences.setString(syncQueueKey, json.encode(queue));
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final queueString = sharedPreferences.getString(syncQueueKey);
    if (queueString != null) {
      final List<dynamic> decodedJson = json.decode(queueString);
      return List<Map<String, dynamic>>.from(decodedJson);
    }
    return [];
  }

  Future<void> clearQueue() async {
    await sharedPreferences.remove(syncQueueKey);
  }
}
