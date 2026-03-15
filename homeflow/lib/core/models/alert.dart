import 'package:equatable/equatable.dart';
import '../../../core/models/enums.dart';

class Alert extends Equatable {
  final int id;
  final String user_id;
  final String title;
  final AlertDescription description;
  final bool isRead;
  final DateTime createdAt;

  const Alert({
     required this.id,
     required this.user_id,
     required this.title,
     required this.description,
     required this.isRead,
     required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      user_id: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as AlertDescription,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as DateTime,
    );
  }
  
  @override
  // TODO: implement props
  List<Object?> get props => [id, user_id, title, description, isRead, createdAt];

}