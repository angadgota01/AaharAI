import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId; // Supabase user ID

  late String email;
  String? displayName;
  late DateTime createdAt;
  DateTime? lastLoginAt;
}
