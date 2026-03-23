import 'package:equatable/equatable.dart';

import '../../../core/models/enums.dart';

// Equatable es necesario para que el BLoC compare los estados por el valor real de sus datos y no por la referencia en memoria, evitando que la UI se repinte sin motivo.
class Alert extends Equatable {
  final int id;
  final String userId; 
  final String title;
  final AlertDescription description;
  final bool isRead; 
  final DateTime createdAt; 

  const Alert({
     required this.id,
     required this.userId,
     required this.title,
     required this.description,
     required this.isRead,
     required this.createdAt,
  });

  // Factory para convertir el JSON que nos proporciona Supabase a nuestro objeto Dart
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      userId: json['user_id'] as String, 
      title: json['title'] as String,
      // Con el enum parseado, la UI trabaja solo con el dominio y queda aislada de los strings de Supabase.
      description: AlertDescription.fromString(json['description'] as String),
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  @override
  // Mapear las propiedades asegura que si solo cambia el booleano 'isRead', el BLoC emita un nuevo estado correctamente.
  List<Object?> get props => [id, userId, title, description, isRead, createdAt];
}