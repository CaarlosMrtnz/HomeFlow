// Tipar los strings que vienen de Supabase nos quita de en medio los magic strings y previene fallos tontos al comparar valores en la UI.

/// Mapea los tipos de suministros de la base de datos a tipos fuertemente tipados en Dart.
enum SupplyName {
  electricity('Electricity'),
  water('Water'),
  gas('Gas'),
  unknown('unknown');

  /// Representación en string proveniente de Supabase.
  final String value;
  const SupplyName(this.value);

  /// Representación en string proveniente de Supabase.
  factory SupplyName.fromString(String? dbValue) {

    // Interceptamos nulos provenientes de JSONs incompletos o errores de JOIN en consultas.
    if (dbValue == null) return SupplyName.unknown;

    return values.firstWhere(
      (e) => e.value == dbValue,
      // El fallback a 'unknown' evita que la app crashee en producción al recibir tipos de suministro no mapeados.
      orElse: () => SupplyName.unknown,
    );
  }
}

/// Define las unidades de medida asociadas a cada suministro para estandarizar la UI y los cálculos.
enum SupplyUnit {
  kwh('kWh'),
  l('L'), 
  m3('m3'),
  unknown('unknown');

  /// Cadena de texto correspondiente a la unidad en la base de datos.
  final String value;
  const SupplyUnit(this.value);

  /// Convierte el valor recuperado de la base de datos en su correspondiente unidad.
  factory SupplyUnit.fromString(String dbValue) {
    return values.firstWhere(
      (e) => e.value == dbValue,
      // Fallback por defecto para mantener la estabilidad si cambian los tipos en el backend.
      orElse: () => SupplyUnit.unknown,
    );
  }
}

/// Categoriza las anomalías detectadas por el simulador de Python para su representación visual.
enum AlertDescription {
  leak('Possible leak detected'),
  leftOn('Device left On'),
  leftOff('Device left Off'),
  unknown('unknown');

  final String value;
  const AlertDescription(this.value);

  /// Mapea el texto de la alerta a un estado manejable por la lógica de la aplicación.
  factory AlertDescription.fromString(String dbValue) {
    return values.firstWhere(
      (e) => e.value == dbValue,
      // Protege contra errores de serialización frente a nuevas alertas no implementadas.
      orElse: () => AlertDescription.unknown,
    );
  }
}