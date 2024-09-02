import 'dart:async';

class SyncQueue {
  final List<Future<void> Function()> _queue = [];

  void addToQueue(Future<void> Function() task) {
    _queue.add(task);
  }

  Future<void> processQueue() async {
    // Create a temporary list to hold tasks that are successfully processed
    final List<Future<void> Function()> successfullyProcessedTasks = [];

    for (var task in _queue) {
      try {
        await task();
        successfullyProcessedTasks
            .add(task); // Mark task as successfully processed
      } catch (e) {
        // Stop processing if a sync fails
        print("processQueue error: $e");
        break;
      }
    }

    // Remove all successfully processed tasks from the queue
    _queue.removeWhere((task) => successfullyProcessedTasks.contains(task));
  }
}
