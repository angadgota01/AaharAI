class FoodItem {
  final String name;
  final double calories;
  final double protein;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
  });
}

class FoodDataset {
  static const List<FoodItem> items = [
    FoodItem(name: "Dosa", calories: 120, protein: 4.5),
    FoodItem(name: "Idli", calories: 39, protein: 2.0),
    FoodItem(name: "Vada", calories: 97, protein: 2.5),
    FoodItem(name: "Sambar (1 bowl)", calories: 150, protein: 4.0),
    FoodItem(name: "Coconut Chutney", calories: 50, protein: 1.0),
    FoodItem(name: "Chapati", calories: 120, protein: 3.5),
    FoodItem(name: "Paneer Butter Masala", calories: 350, protein: 12.0),
    FoodItem(name: "Dal Tadka", calories: 180, protein: 8.0),
    FoodItem(name: "Rice (1 cup)", calories: 200, protein: 4.0),
    FoodItem(name: "Chicken Curry", calories: 250, protein: 25.0),
    FoodItem(name: "Egg Bhurji", calories: 180, protein: 12.0),
    FoodItem(name: "Oatmeal", calories: 150, protein: 6.0),
    FoodItem(name: "Banana", calories: 105, protein: 1.3),
    FoodItem(name: "Apple", calories: 95, protein: 0.5),
  ];

  static List<String> getMatchingNames(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .map((item) => item.name)
        .toList();
  }

  static FoodItem? getByName(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  // Simulates recognition
  static FoodItem recognizeFromImage() {
    // For now, return a random item or a fixed one for testing
    // In a real app, this would use an ML model
    return items[0]; // Returns Dosa by default
  }
}
