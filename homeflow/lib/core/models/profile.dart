import 'package:equatable/equatable.dart';

/// Modelo que representa la tabla de perfiles en Supabase.
/// Extiende de [Equatable] para evaluar la igualdad por valor de sus atributos en lugar de por referencia,
/// lo cual evita reconstrucciones innecesarias en la UI si usas gestores de estado como Bloc o Riverpod.
class Profile extends Equatable {

  /// Constantes para las columnas de la tabla. Eliminan los "magic strings" estáticos y previenen errores tipográficos al serializar/deserializar.
  static const String colId = 'id';
  static const String colEmail = 'email';
  static const String colPhoneNumber = 'phone_number';
  static const String colFullName = 'full_name';
  static const String colCreatedAt = 'created_at';

  final String id;
  final String email;
  final String? phoneNumber; 
  final String? fullName;
  final DateTime createdAt;

  /// Constructor para forzar la inmutabilidad de la instancia en memoria.
  const Profile({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.fullName,
    required this.createdAt,
  });

  /// Deserializa el Map que devuelve el cliente de Supabase.
  /// Aplica un enfoque de parseo defensivo (*defensive parsing*): en lugar de fallar rápido,
  /// intercepta posibles valores nulos o tipos inesperados de la base de datos.
  /// Usa conversiones seguras (`toString()`) y valores por defecto (`?? ''`) como paracaídas
  /// para garantizar que un registro corrupto no haga crashear la interfaz de usuario (UI).
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json[colId]?.toString() ?? '',
      email: json[colEmail]?.toString() ?? '',
      phoneNumber: json[colPhoneNumber] as String?,
      fullName: json[colFullName] as String?,
      // Si created_at viene nulo por algún error raro, le ponemos la fecha actual para que no explote el DateTime.parse.
      createdAt: json[colCreatedAt] != null 
          ? DateTime.parse(json[colCreatedAt].toString()) 
          : DateTime.now(),
    );
  }

  /// Serializa el modelo a un Map para inserciones o representaciones completas en Supabase.
    Map<String, dynamic> toJson() {
      return {
        colId: id,
        colEmail: email,
        // Si el valor es null, Supabase enviará un NULL a PostgreSQL, respetando que no tienen restricción NOT NULL.
        colPhoneNumber: phoneNumber,
        colFullName: fullName,
        // Se convierte a ISO-8601 para que el tipo 'timestamp with time zone' lo digiera correctamente.
        colCreatedAt: createdAt.toIso8601String(),
      };
    }

  /// Genera un Map exclusivo para actualizaciones (PATCH). 
  /// Excluye 'id', 'email' y 'created_at' porque por arquitectura de BD no deben mutar tras el registro.
  Map<String, dynamic> toUpdateMap() {
    return {
      colPhoneNumber: phoneNumber,
      colFullName: fullName,
    };
  }

  /// Define qué propiedades determinan que dos instancias de Profile sean idénticas.
  @override
  List<Object?> get props => [id, email, phoneNumber, fullName, createdAt];
}