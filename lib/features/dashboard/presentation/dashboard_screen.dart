import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';

// --- PROVIDERS (Connecting Logic to UI) ---

// 1. Provider for the Database Service
final isarServiceProvider = Provider((ref) => IsarService());

// 2. Provider for Today's Logs (Auto-refreshes when data changes)
final todaysLogsProvider = FutureProvider<List<FoodLog>>((ref) async {
  final service = ref.watch(isarServiceProvider);
  return service.getFoodLogsForDate(DateTime.now());
});


// --- THE UI WIDGET ---

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the database query
    final asyncLogs = ref.watch(todaysLogsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Aahar AI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      
      // THE FLOATING BUTTON (To Test Adding Data)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // --- TEST DATA INSERTION ---
          final newMeal = FoodLog()
            ..foodName = "Ragi Mudde"
            ..calories = 350
            ..protein = 8.5
            ..carbs = 60
            ..fats = 4
            ..timestamp = DateTime.now();

          // Call the service
          await ref.read(isarServiceProvider).addFoodLog(newMeal);
          
          // Refresh the UI
          ref.invalidate(todaysLogsProvider);
        },
        label: const Text("Log Test Meal"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MACRO SUMMARY CARD
            _buildSummaryCard(asyncLogs),

            const SizedBox(height: 20),
            const Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 2. MEAL LIST (Connected to DB)
            Expanded(
              child: asyncLogs.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(child: Text("No meals logged today. Tap + to add."));
                  }
                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final meal = logs[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Text("🍛"), // Placeholder for image
                          ),
                          title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(DateFormat('hh:mm a').format(meal.timestamp)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${meal.calories.toInt()} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                              Text("${meal.protein}g Pro", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          onLongPress: () async {
                            // Delete on long press
                             await ref.read(isarServiceProvider).deleteLog(meal.id);
                             ref.invalidate(todaysLogsProvider);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Summary
  Widget _buildSummaryCard(AsyncValue<List<FoodLog>> asyncLogs) {
    double totalCal = 0;
    double totalPro = 0;

    // Calculate totals if data exists
    if (asyncLogs.hasValue) {
      for (var log in asyncLogs.value!) {
        totalCal += log.calories;
        totalPro += log.protein;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroItem("Calories", "${totalCal.toInt()}", "kcal"),
          Container(width: 1, height: 40, color: Colors.grey),
          _buildMacroItem("Protein", "${totalPro.toStringAsFixed(1)}", "g"),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text("$unit $label", style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}