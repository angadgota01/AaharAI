import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';
import 'history_screen.dart';
import 'ai_insights_screen.dart';

// --- PROVIDERS ---
final isarProvider = Provider((ref) => IsarService());

final todaysLogsProvider = FutureProvider<List<FoodLog>>((ref) async {
  final service = ref.watch(isarProvider);
  return service.getTodayLogs();
});

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aahar AI 🍛"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/consultation'),
          )
        ],
      ),
      body: _currentIndex == 0 
          ? const _HomeContent() 
          : _currentIndex == 1 
              ? const HistoryScreen() 
              : const AiInsightsScreen(),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Meal"),
        onPressed: () {
          // Navigate to AddMealScreen
           context.push('/add_meal').then((_) {
             // Refresh data on return
             ref.refresh(todaysLogsProvider);
           });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "Insights"),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(todaysLogsProvider);
    return _buildSummaryCard(asyncLogs);
  }

  Widget _buildSummaryCard(AsyncValue<List<FoodLog>> asyncLogs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your nutrition mindfully",
            style: TextStyle(color: Colors.white.withOpacity(0.65)),
          ),
          const SizedBox(height: 20),
          _buildSummaryCards(asyncLogs),
          const SizedBox(height: 28),
          const Text(
            "Today's Meals",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: asyncLogs.when(
              data: (logs) {
                if (logs.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return _MealTile(meal: logs[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text("Error loading meals")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AsyncValue<List<FoodLog>> asyncLogs) {
    double calories = 0;
    double protein = 0;

    if (asyncLogs.hasValue) {
      for (final log in asyncLogs.value!) {
        calories += log.calories;
        protein += log.protein;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            value: calories.toInt().toString(),
            label: "kcal Calories",
            color: const Color(0xFFFFB86C),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GlassStatCard(
            value: protein.toStringAsFixed(1),
            label: "g Protein",
            color: const Color(0xFF6EE7B7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text("No meals yet.", style: TextStyle(color: Colors.grey[600])),
          Text("Tap 'Add Meal' to start.",
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

class _MealTile extends ConsumerWidget {
  final FoodLog meal;
  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Text("🥘")),
        title: Text(meal.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('hh:mm a').format(meal.timestamp)),
        trailing: Text("${meal.calories.toInt()} kcal",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onLongPress: () {
          ref.read(isarProvider).deleteLog(meal.id);
          ref.refresh(todaysLogsProvider);
        },
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _GlassStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

