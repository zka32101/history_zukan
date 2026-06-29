import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  late String uid;

  @HiveField(1)
  late DateTime birthDate;

  @HiveField(2)
  late bool showMyTimelineMode;

  @HiveField(3)
  late List<String> recentlyViewed;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.birthDate,
    this.showMyTimelineMode = true,
    this.recentlyViewed = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile.empty()
      : uid = '',
        birthDate = DateTime.now(),
        showMyTimelineMode = true,
        recentlyViewed = [],
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  int get ageAtCurrentDate {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int getAgeAtYear(int targetYear) {
    return targetYear - birthDate.year;
  }

  UserProfile copyWith({
    String? uid,
    DateTime? birthDate,
    bool? showMyTimelineMode,
    List<String>? recentlyViewed,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      birthDate: birthDate ?? this.birthDate,
      showMyTimelineMode: showMyTimelineMode ?? this.showMyTimelineMode,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'UserProfile(uid: $uid, birthDate: $birthDate, age: $ageAtCurrentDate)';
}
