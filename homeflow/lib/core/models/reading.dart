import 'package:equatable/equatable.dart';

class Reading extends Equatable {
  final int id;
  final String user_id;
  final int supply_type_id;
  final int value;
  final DateTime created_at;

  const Reading ({
    required this.id,
    required this.user_id,
    required this.supply_type_id,
    required this.value,
    required this.created_at,
  });

  // Factory para convertir el JSON que nos escupe Supabase a nuestro objeto Dart
  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as int,
      user_id: json['user_id'] as String,
      supply_type_id: json['supply_type_id'] as int,
      // Supabase a veces devuelve un 'int' si el número no tiene decimales (ej. 20 en vez de 20.0).
      // Usar (json['value'] ?? 0).toDouble() evita crasheos en tiempo de ejecución.
      value: (json['value'] ?? 0).toDouble(),
      // Supabase devuelve las fechas en formato ISO-8601 (String)
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }
  
  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'supply_type_id': supply_type_id,
      'value': value,
    };
    // No mandamos el 'id' ni el 'created_at' porque la BD los genera solos
  }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
  
}