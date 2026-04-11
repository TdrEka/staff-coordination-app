import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 4)
class Client {
  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.notes,
    required this.eventIds,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  List<String> eventIds;
}

// Run: flutter pub run build_runner build
