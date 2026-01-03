import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NutritionistListScreen extends StatelessWidget {
  const NutritionistListScreen({super.key});

  final nutritionists = const [
    {
      "name": "Dr. Ananya Rao",
      "specialty": "Weight Loss Specialist",
      "rating": "4.8",
      "experience": "8 yrs"
    },
    {
      "name": "Dr. Rahul Mehta",
      "specialty": "Sports Nutritionist",
      "rating": "4.6",
      "experience": "10 yrs"
    },
    {
      "name": "Dr. Priya Sharma",
      "specialty": "Diabetes & Diet",
      "rating": "4.9",
      "experience": "7 yrs"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Consult a Nutritionist"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nutritionists.length,
        itemBuilder: (context, index) {
          final n = nutritionists[index];
          return Card(
            color: const Color(0xFF2A2A2A),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n["name"]!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(n["specialty"]!, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("⭐ ${n["rating"]}   •   ${n["experience"]}", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      context.push('/chat', extra: n["name"]);
                    },
                    child: const Text("Consult"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
