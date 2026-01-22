import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';
final isarProvider = Provider<IsarService>((ref) {
  return IsarService();
});

// PROVIDER
final historyLogsProvider = FutureProvider<List<FoodLog>>((ref) async {
  final service = ref.read(isarProvider);
  return service.getAllLogs();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(historyLogsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "History",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Review your nutrition journey",
            style: TextStyle(color: Colors.white.withOpacity(0.65)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: asyncLogs.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return _EmptyHistoryState();
                }

                final grouped = _groupByDate(logs);

                return ListView(
                  children: grouped.entries.map((entry) {
                    return _HistoryDayCard(
                      date: entry.key,
                      meals: entry.value,
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text("Failed to load history")),
            ),
          ),
        ],
      ),
    );
  }

  // ---- HELPERS ----
  Map<DateTime, List<FoodLog>> _groupByDate(List<FoodLog> logs) {
    final Map<DateTime, List<FoodLog>> map = {};

    for (final log in logs) {
      final date = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );

      map.putIfAbsent(date, () => []).add(log);
    }

    return Map.fromEntries(
      map.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}

// ================= COMPONENTS =================

class _HistoryDayCard extends StatelessWidget {
  final DateTime date;
  final List<FoodLog> meals;

  const _HistoryDayCard({
    required this.date,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        meals.fold<double>(0, (sum, m) => sum + m.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${totalCalories.toInt()} kcal",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB86C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // MEALS
                ...meals.map((meal) => _HistoryMealTile(meal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryMealTile extends StatelessWidget {
  final FoodLog meal;

  const _HistoryMealTile(this.meal);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black45,
            child: Text("🥗"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.foodName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('hh:mm a').format(meal.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${meal.calories.toInt()} kcal",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 56,
            color: Colors.white.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          const Text(
            "No history yet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Your logged meals will appear here",
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

