import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber; 
  final String? fullName;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.fullName,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, email, phoneNumber, fullName, createdAt];
}