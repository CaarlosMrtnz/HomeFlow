// Tipar fuertemente los strings que vienen de Supabase nos quita de en medio los magic strings y previene fallos tontos al comparar valores en la UI.

enum SupplyName {
  electricity('Electricity'),
  water('Water'),
  gas('Gas'),
  unknown('unknown');

  final String value;
  const SupplyName(this.value);

  factory SupplyName.fromString(String dbValue) {
    return values.firstWhere(
      (e) => e.value == dbValue,
      // El fallback a 'unknown' evita que la app en producción no crasheará al intentar pasarle un nuevo tipo en la BD.
      orElse: () => SupplyName.unknown,
    );
  }
}

enum SupplyUnit {
  kwh('kWh'),
  l('L'), 
  m3('m3'),
  unknown('unknown');

  final String value;
  const SupplyUnit(this.value);

  factory SupplyUnit.fromString(String dbValue) {
    return values.firstWhere(
      (e) => e.value == dbValue,
      orElse: () => SupplyUnit.unknown,
    );
  }
}

enum AlertDescription {
  leak('Possible leak detected'),
  leftOn('Device left On'),
  leftOff('Device left Off'),
  unknown('unknown');

  final String value;
  const AlertDescription(this.value);

  factory AlertDescription.fromString(String dbValue) {
    return values.firstWhere(
      (e) => e.value == dbValue,
      orElse: () => AlertDescription.unknown,
    );
  }
}