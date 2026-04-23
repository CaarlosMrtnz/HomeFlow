import 'package:equatable/equatable.dart';

import '../../../core/models/enums.dart';

/// Modelo de Dominio: Representa una alerta del simulador/sistema.
/// 
/// Usamos [Equatable] para garantizar la igualdad por valor (value equality). 
/// En BLoC, si emitimos un estado con la misma referencia de memoria o los mismos 
/// valores exactos, el gestor corta el flujo y evita reconstrucciones innecesarias en el árbol de widgets. Esto es vital 
/// para el rendimiento cuando manejamos listas de alertas.
class Alert extends Equatable {
  final int id;
  final String userId; 
  final String title;
  final AlertDescription description;
  final bool isRead; 
  final DateTime createdAt; 
  final String deviceIconName;

  // Único campo opcional. Ideal, pues la alerta es genérica y no está atada a un suministro físico del simulador.
  final int? supplyTypeId;

  const Alert({
     required this.id,
     required this.userId,
     required this.title,
     required this.description,
     required this.isRead,
     required this.createdAt,
     required this.supplyTypeId,
     required this.deviceIconName,
  });

  /// Capa de infraestructura (Data Transfer Object)
  /// 
  /// Actúa como un escudo (Anti-Corruption Layer). Traduce el snake_case de la DB 
  /// (Supabase) a nuestro modelo de Dart. El resto de la App no necesita saber 
  /// si los datos vienen de Supabase, Firebase o un JSON local.
  factory Alert.fromJson(Map<String, dynamic> json) {
    // Si la query a Supabase no cruza los datos con la tabla de dispositivos, 
     // inicializamos con un mapa vacío para evitar un NullPointerException más abajo.
    final deviceData = json['devices'] ?? {};

    return Alert(
      id: json['id'] as int,
      userId: json['user_id'] as String, 
      title: json['title'] as String,
      // Con el enum parseado, la UI trabaja solo con el dominio y queda aislada de los strings de Supabase.
      description: AlertDescription.fromString(json['description'] as String),
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      supplyTypeId: json['supply_type_id'],
      deviceIconName: deviceData['icon_name']?.toString() ?? 'notifications',
    );
  }

  /// Prepara el modelo para ser enviado a la DB por si necesito hacer un UPDATE (por ejemplo, marcar la alerta como leída).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      // Extraemos el valor del enum en String para que coincida con el user-defined de Postgres.
      'description': description.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'supply_type_id': supplyTypeId,
    };
  }
  
  @override
  // Mapear las propiedades asegura que si solo cambia el booleano 'isRead', el BLoC emita un nuevo estado correctamente.
  List<Object?> get props => [
    id, 
    userId, 
    title, 
    description, 
    isRead, 
    createdAt, 
    supplyTypeId,
    deviceIconName];
}