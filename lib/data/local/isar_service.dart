import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'entities/food_log.dart';
import 'entities/user_profile.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      // ISAR v3 SYNTAX
      return await Isar.open(
        [FoodLogSchema, UserProfileSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> addFoodLog(FoodLog newLog) async {
    final isar = await db;
    // ISAR v3 SYNTAX (Synchronous transaction)
    await isar.writeTxn(() async {
      await isar.foodLogs.put(newLog);
    });
  }

  Future<List<FoodLog>> getTodayLogs() async {
    final isar = await db;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await isar.foodLogs
        .filter()
        .timestampBetween(start, end)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<FoodLog>> getAllLogs() async {
    final isar = await db;
    return await isar.foodLogs.where().sortByTimestampDesc().findAll();
  }

  Future<void> deleteLog(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.foodLogs.delete(id);
    });
  }

  // --- USER PROFILE METHODS ---
  Future<void> saveUserProfile(UserProfile profile) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
    });
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final isar = await db;
    return await isar.userProfiles
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final isar = await db;
    // Get the first (and should be only) user profile
    return await isar.userProfiles.where().findFirst();
  }

  Future<void> deleteUserProfile(String userId) async {
    final isar = await db;
    final profile = await getUserProfile(userId);
    if (profile != null) {
      await isar.writeTxn(() async {
        await isar.userProfiles.delete(profile.id);
      });
    }
  }
}