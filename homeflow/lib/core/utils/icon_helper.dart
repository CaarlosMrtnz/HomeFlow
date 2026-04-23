import 'package:flutter/material.dart';

/// Utilidad estática para transformar los strings almacenados en la base de datos (Supabase) 
/// en objetos [IconData] nativos de Material Design utilizables por la UI.
class IconHelper {
  /// Mapea un identificador de texto a su icono correspondiente.
  /// Maneja de forma defensiva valores nulos o desconocidos para evitar excepciones de renderizado.
  // Al ser 'static', puedes llamarla desde cualquier parte de la app sin instanciar la clase
  static IconData getIcon(String? iconName) {
    // Intercepta cadenas inválidas antes de evaluar el bloque condicional.
    if (iconName == null || iconName.isEmpty) return Icons.power_outlined;

    switch (iconName) {
      case 'lightbulb': return Icons.lightbulb_outline;
      case 'water_drop': return Icons.water_drop_outlined;
      case 'thermostat': return Icons.thermostat;
      case 'bathtub': return Icons.bathtub_outlined;
      case 'kitchen': return Icons.kitchen;
      case 'local_laundry_service': return Icons.local_laundry_service;
      case 'microwave': return Icons.microwave;
      case 'hvac': return Icons.hvac;
      case 'ac_unit': return Icons.ac_unit;
      case 'tv': return Icons.tv;
      case 'router': return Icons.router;
      case 'coffee': return Icons.coffee_maker_outlined;
      case 'desktop': return Icons.desktop_windows_outlined;
      case 'fire': return Icons.local_fire_department_outlined;
      case 'bolt': return Icons.bolt;
      case 'notifications': return Icons.notifications_none_outlined;
      default: return Icons.device_unknown;
    }
  }

  /// Constructor privado. Impide instanciar la clase, reforzando su diseño como un contenedor de funciones puras.
  IconHelper._();

}