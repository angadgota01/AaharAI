import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';

final isarProvider = Provider((ref) => IsarService());

final recentLogsProvider = FutureProvider.autoDispose<List<FoodLog>>((ref) async {
  final service = ref.watch(isarProvider);
  // Get all logs for now, or filter last 7 days if getAllLogs returns everything
  return service.getAllLogs();
});

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  String _response = "";
  bool _isLoading = false;
  bool _hasGenerated = false;

  Future<void> _generateInsights(List<FoodLog> logs) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey == 'YOUR_API_KEY_HERE') {
      setState(() {
        _response = "Error: GEMINI_API_KEY not found in .env file. Please add your API key.";
        _isLoading = false;
        _hasGenerated = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey);

      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final sb = StringBuffer();
      sb.writeln("Here are my meal logs for the recent days:");
      for (var log in logs) {
        sb.writeln("- ${dateFormat.format(log.timestamp)}: ${log.foodName} (${log.calories} kcal, ${log.protein}g protein)");
      }
      sb.writeln("\nPlease analyze my nutrition habits based on this data. Give me 3 key insights and 1 actionable recommendation. Keep it concise.");

      final content = [Content.text(sb.toString())];
      final response = await model.generateContent(content);

      if (mounted) {
        setState(() {
          _response = response.text ?? "No response generated.";
          _isLoading = false;
          _hasGenerated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _response = "Failed to generate insights: $e";
          _isLoading = false;
          _hasGenerated = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLogs = ref.watch(recentLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Insights 🤖"),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               setState(() {
                 _hasGenerated = false;
                 _response = "";
               });
               // Refetch logs if needed
               ref.refresh(recentLogsProvider);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Get personalized nutrition insights based on your food history.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: asyncLogs.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Center(child: Text("No meals logged yet. Log some meals to get insights!"));
                  }

                  if (!_hasGenerated && !_isLoading) {
                    return Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("Generate Insights"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () => _generateInsights(logs),
                      ),
                    );
                  }

                  if (_isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Consulting AI Nutritionist..."),
                        ],
                      ),
                    );
                  }

                  // Show Response
                  return SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: Text(
                        _response,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error loading data: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
