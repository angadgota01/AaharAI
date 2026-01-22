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
    return Container(
      // ✅ GRADIENT MUST BE OUTSIDE SCAFFOLD
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Aahar AI 🍛",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/consultation'),
            ),
          ],
        ),

        body: _currentIndex == 0
            ? const _HomeContent()
            : _currentIndex == 1
                ? const HistoryScreen()
                : const AiInsightsScreen(),

        // 🔥 PREMIUM ADD MEAL BUTTON
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              "Add Meal",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              context.push('/add_meal').then((_) {
                ref.refresh(todaysLogsProvider);
              });
            },
          ),
        ),

        // 💎 PREMIUM BOTTOM BAR
        bottomNavigationBar: _PremiumBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text("Error loading meals")),
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
        _GlassStatCard(
          value: calories.toInt().toString(),
          label: "kcal Calories",
          color: const Color(0xFFFFB86C),
        ),
        const SizedBox(width: 16),
        _GlassStatCard(
          value: protein.toStringAsFixed(1),
          label: "g Protein",
          color: const Color(0xFF6EE7B7),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu,
              size: 52, color: Colors.white.withOpacity(0.35)),
          const SizedBox(height: 12),
          const Text(
            "Your nutrition journey starts today",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Log your first meal to unlock insights",
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ---------------- COMPONENTS ----------------

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
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealTile extends ConsumerWidget {
  final FoodLog meal;

  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.black45,
          child: Text("🥗"),
        ),
        title: Text(meal.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            Text(DateFormat('hh:mm a').format(meal.timestamp)),
        trailing: Text(
          "${meal.calories.toInt()} kcal",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onLongPress: () {
          ref.read(isarProvider).deleteLog(meal.id);
          ref.refresh(todaysLogsProvider);
        },
      ),
    );
  }
}

class _PremiumBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.calendar_today_rounded,
                  label: "Today",
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: "History",
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: "Insights",
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF6EE7B7) : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

