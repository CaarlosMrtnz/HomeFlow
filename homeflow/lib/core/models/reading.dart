import 'package:equatable/equatable.dart';

// Equatable es necesario para que el BLoC compare los estados por el valor real de sus datos y no por la referencia en memoria, evitando que la UI se repinte sin motivo.
class Reading extends Equatable {
  final int id;
  final String userId;
  final int supplyTypeId;
  final int deviceId;
  final double value;
  final DateTime createdAt;

  const Reading ({
    required this.id,
    required this.userId,
    required this.supplyTypeId,
    required this.deviceId,
    required this.value,
    required this.createdAt,
  });

  // Factory para convertir el JSON que nos proporciona Supabase a nuestro objeto Dart
  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      supplyTypeId: json['supply_type_id'] as int,
      deviceId: json['device_id'] as int,
      // Supabase a veces devuelve un 'int' si el número no tiene decimales (ej. 20 en vez de 20.0). Usar (json['value'] ?? 0).toDouble() evita crasheos en tiempo de ejecución.
      value: (json['value'] ?? 0).toDouble(),
      // Supabase devuelve las fechas en formato ISO-8601 (String)
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'supply_type_id': supplyTypeId,
      'value': value,
    };
    // No mandamos el 'id' ni el 'created_at' porque la BD los genera solos
  }

  @override
  // Hay que pasarle la lista de propiedades [id, user_id, ...]. Si se queda lanzando este UnimplementedError, la app crasheará en cuanto el BLoC intente comparar dos lecturas.
  List<Object?> get props => [id, userId, supplyTypeId, value, createdAt];
  
}