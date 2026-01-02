import 'package:isar/isar.dart';

part 'food_log.g.dart';

@collection
class FoodLog {
  Id id = Isar.autoIncrement;

  late String foodName;
  late double calories;
  late double protein;
  late DateTime timestamp;
}