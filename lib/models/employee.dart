import 'package:hive/hive.dart';

import 'enums.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee {
  Employee({
    required this.id,
    required this.name,
    this.age,
    required this.phone,
    this.email,
    required this.location,
    required this.preferredContact,
    required this.languages,
    required this.availability,
    this.reliabilityScore = 5.0,
    required this.roles,
    required this.contractType,
    this.hourlyRate,
    required this.status,
    required this.notes,
    this.emergencyContact,
    required this.createdAt,
    this.documents,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? age;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String? email;

  @HiveField(5)
  String location;

  @HiveField(6)
  PreferredContact preferredContact;

  @HiveField(7)
  List<String> languages;

  // Stores availability as JSON string representing Map<String, List<Map>>.
  @HiveField(8)
  String availability;

  @HiveField(9)
  double reliabilityScore;

  @HiveField(10)
  List<String> roles;

  @HiveField(11)
  ContractType contractType;

  @HiveField(12)
  double? hourlyRate;

  @HiveField(13)
  EmployeeStatus status;

  @HiveField(14)
  String notes;

  @HiveField(15)
  String? emergencyContact;

  // ISO-8601 DateTime string.
  @HiveField(16)
  String createdAt;

  @HiveField(17)
  List<String>? documents;
}

// Run: flutter pub run build_runner build
