import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';

final isarProvider = Provider((ref) => IsarService());

final historyLogsProvider = FutureProvider.autoDispose<List<FoodLog>>((ref) async {
  final service = ref.watch(isarProvider);
  return service.getAllLogs();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(historyLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal History 📜"),
      ),
      body: asyncLogs.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text("No history available."));
          }

          // Group by Date
          final groupedLogs = _groupByDate(logs);
          final sortedDates = groupedLogs.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Descending order

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateLogs = groupedLogs[date]!;
              
              // Filter out today (since it's on Home) or keep it if desired
              // For "History", usually we mean PAST days, but showing all is fine too.
              // Let's show all for now.

              return _buildDaySection(date, dateLogs);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Map<DateTime, List<FoodLog>> _groupByDate(List<FoodLog> logs) {
    final Map<DateTime, List<FoodLog>> grouped = {};
    for (var log in logs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(log);
    }
    return grouped;
  }

  Widget _buildDaySection(DateTime date, List<FoodLog> logs) {
    double totalCals = logs.fold(0, (sum, item) => sum + item.calories);
    double totalPro = logs.fold(0, (sum, item) => sum + item.protein);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${totalCals.toInt()} kcal / ${totalPro.toStringAsFixed(1)}g P",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        ...logs.map((log) => ListTile(
          leading: const Icon(Icons.circle, size: 10, color: Colors.orange),
          title: Text(log.foodName),
          subtitle: Text(DateFormat('hh:mm a').format(log.timestamp)),
          trailing: Text("${log.calories.toInt()} kcal"),
        )),
        const Divider(),
      ],
    );
  }
}
