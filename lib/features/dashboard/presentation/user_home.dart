import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Import Data Layer
import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';

// --- PROVIDERS ---
final isarProvider = Provider((ref) => IsarService());

final todaysLogsProvider = FutureProvider<List<FoodLog>>((ref) async {
  final service = ref.watch(isarProvider);
  return service.getTodayLogs();
});

// --- UI WIDGET ---
class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(todaysLogsProvider);

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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan Food"),
        onPressed: () {
          // Placeholder: Simulate adding data to test DB connection
          _simulateAddData(ref);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MACRO SUMMARY CARD
            _buildSummaryCard(asyncLogs),
            
            const SizedBox(height: 24),
            const Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 2. MEAL LIST
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
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSummaryCard(AsyncValue<List<FoodLog>> asyncLogs) {
    double totalCals = 0;
    double totalPro = 0;
    
    if (asyncLogs.hasValue) {
      for (var log in asyncLogs.value!) {
        totalCals += log.calories;
        // Check if protein exists (handling null safety just in case)
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
          // FIXED: Removed 'const' because Colors.grey[600] is not a constant
          Text("No meals yet.", style: TextStyle(color: Colors.grey[600])),
          // FIXED: Removed 'const' here too
          Text("Tap 'Scan Food' to start.", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  // --- SIMULATION LOGIC (For Testing) ---
  void _simulateAddData(WidgetRef ref) async {
    final newLog = FoodLog()
      ..foodName = "Test Dosa"
      ..calories = 120
      ..protein = 4.5
      ..timestamp = DateTime.now();
      
    // FIXED: Changed 'logFood' to 'addFoodLog' to match IsarService
    await ref.read(isarProvider).addFoodLog(newLog);
    ref.invalidate(todaysLogsProvider); // Triggers UI refresh
  }
}