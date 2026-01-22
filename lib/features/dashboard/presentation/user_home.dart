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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(asyncLogs),
          const SizedBox(height: 24),
          const Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: asyncLogs.when(
              data: (logs) {
                if (logs.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final meal = logs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Text("🥘")),
                        title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(DateFormat('hh:mm a').format(meal.timestamp)),
                        trailing: Text("${meal.calories.toInt()} kcal", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onLongPress: () {
                           ref.read(isarProvider).deleteLog(meal.id);
                           ref.refresh(todaysLogsProvider);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AsyncValue<List<FoodLog>> asyncLogs) {
    double totalCals = 0;
    double totalPro = 0;
    
    if (asyncLogs.hasValue) {
      for (var log in asyncLogs.value!) {
        totalCals += log.calories;
        totalPro += log.protein; 
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black, // Dark card for contrast
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("Calories", "${totalCals.toInt()}", "kcal"),
          Container(height: 40, width: 1, color: Colors.grey),
          _buildStat("Protein", "${totalPro.toStringAsFixed(1)}", "g"),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
        Text("$unit $label", style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
          Text("Tap 'Add Meal' to start.", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}