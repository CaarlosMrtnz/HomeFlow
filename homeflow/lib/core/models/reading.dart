import 'package:equatable/equatable.dart';

// Equatable es necesario para que el BLoC compare los estados por el valor real de sus datos y no por la referencia en memoria, evitando que la UI se repinte sin motivo.
class Reading extends Equatable {
  final int id;
  final String userId;
  final int supplyTypeId;
  final int deviceId;
  final double value;
  final DateTime createdAt;
  final String deviceName;
  final String deviceIconName;

  /// Constructor constante para garantizar la inmutabilidad de la lectura.
  const Reading ({
    required this.id,
    required this.userId,
    required this.supplyTypeId,
    required this.deviceId,
    required this.value,
    required this.createdAt,
    required this.deviceName,
    required this.deviceIconName,
  });

  // Factory para convertir el JSON que nos proporciona Supabase a nuestro objeto Dart
  factory Reading.fromJson(Map<String, dynamic> json) {
    final deviceData = json['devices'] ?? {};
    return Reading(
      id: json['id'] as int,
      userId: json['user_id']?.toString() ?? '',
      supplyTypeId: json['supply_type_id'] as int,
      deviceId: json['device_id'] as int,
      // Supabase a veces devuelve un 'int' si el número no tiene decimales (ej. 20 en vez de 20.0). Usar (json['value'] ?? 0).toDouble() evita crasheos en tiempo de ejecución.
      value: (json['value'] ?? 0).toDouble(),
      // Supabase devuelve las fechas en formato ISO-8601 (String)
      createdAt: DateTime.parse(json['created_at'] as String),
      deviceName: deviceData['name']?.toString() ?? 'Unknown Device',
      deviceIconName: deviceData['icon_name']?.toString() ?? 'device_unknown',
    );
  }
  
  // Para enviar datos a Supabase.
  /// Prepara el mapa de clave-valor excluyendo campos autogenerados por PostgreSQL.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'supply_type_id': supplyTypeId,
      'value': value,
      'device_id': deviceId
    };
    // No mandamos el 'id' ni el 'created_at' porque la BD los genera solos
  }

  @override
  List<Object?> get props => [
    id, 
    userId, 
    supplyTypeId, 
    deviceId,
    value, 
    createdAt, 
    deviceName,
    deviceIconName];
}