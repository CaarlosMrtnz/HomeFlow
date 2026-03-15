enum SupplyName {
  electricity('Electricity'),
  water('Water'),
  gas('Gas');

  final String value;
  const SupplyName(this.value);

  factory SupplyName.fromString(String dbValue) {
    return values.firstWhere((e) => e.value == dbValue);
  }
}

enum SupplyUnit {
  kwh('kWh'),
  l('l'),
  m3('m3');

  final String value;
  const SupplyUnit(this.value);

  factory SupplyUnit.fromString(String dbValue) {
    return values.firstWhere((e) => e.value == dbValue);
  }
}

enum AlertDescription {
  leak('Possible leak detected'),
  leftOn('Device left On'),
  leftOff('Device left Off');

  final String value;
  const AlertDescription(this.value);

  factory AlertDescription.fromString(String dbValue) {
    return values.firstWhere((e) => e.value == dbValue);
  }
}

