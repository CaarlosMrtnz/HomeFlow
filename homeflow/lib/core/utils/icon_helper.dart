import 'package:flutter/material.dart';

class IconHelper {
  // Al ser 'static', puedes llamarla desde cualquier parte de la app sin instanciar la clase
  static IconData getIcon(String? iconName) {
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
}