import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/dashboard/dashboard_bloc.dart';

class SupplyDetailScreen extends StatelessWidget {
  final int supplyId;
  final String title;
  final Color themeColor;
  final String unit;

  const SupplyDetailScreen({
    super.key,
    required this.supplyId,
    required this.title,
    required this.themeColor,
    required this.unit,
  });

  // Traductor del texto de la base de datos al Icono real
  IconData _getIconData(String? iconName) {
    if (iconName != null && iconName.isNotEmpty) {
      switch (iconName) {
        case 'ac_unit': return Icons.ac_unit;
        case 'tv': return Icons.tv;
        case 'lightbulb': return Icons.lightbulb_outline;
        case 'router': return Icons.router;
        case 'coffee': return Icons.coffee_maker_outlined;
        case 'desktop': return Icons.desktop_windows_outlined;
        case 'kitchen': return Icons.kitchen;
        case 'water_drop': return Icons.water_drop_outlined;
        case 'bathtub': return Icons.bathtub_outlined;
        case 'fire': return Icons.local_fire_department_outlined;
        case 'local_laundry_service': return Icons.local_laundry_service;
        case 'thermostat': return Icons.thermostat;
        default: return Icons.power_outlined;
      }
    }
    // Si es un dispositivo antiguo sin icono o falla algo, icono genérico.
    return Icons.power_outlined;
  }

  void _showAddDeviceDialog(BuildContext context) {
    final controller = TextEditingController();
    
    // Lista de iconos a elegir según la categoría
    final List<String> iconOptions = supplyId == 1 
      ? ['lightbulb', 'tv', 'ac_unit', 'desktop', 'router', 'kitchen', 'coffee'] // Luz
      : supplyId == 2 
        ? ['water_drop', 'bathtub', 'local_laundry_service'] // Agua
        : ['fire', 'thermostat', 'kitchen']; // Gas
        
    String selectedIcon = iconOptions.first; // Seleccionado por defecto

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New $title', style: const TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800)),
        content: StatefulBuilder( // Nos permite cambiar el estado solo dentro de este popup
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Device name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Choose an icon:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: iconOptions.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = iconName),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor : const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(iconName), 
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // Ahora mandamos el nombre, el tipo Y EL ICONO
                context.read<DashboardBloc>().add(
                  AddDeviceRequested(controller.text.trim(), supplyId, selectedIcon)
                );
                Navigator.pop(dialogContext);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${controller.text.trim()} added!'), backgroundColor: const Color(0xFF71B9FD), behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)), onPressed: () => Navigator.of(context).pop()),
        title: Text(title, style: const TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeviceDialog(context),
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, color: Color(0xFF71B9FD)),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final now = DateTime.now();
            final todayReadings = state.readings.where((r) => r.supplyTypeId == supplyId && r.createdAt.year == now.year && r.createdAt.month == now.month && r.createdAt.day == now.day).toList();
            final currentSupplyDevices = state.devices.where((d) => d['supply_type_id'] == supplyId).toList();

            final Map<int, double> deviceTotals = {};
            final Map<int, String> deviceNames = {};
            final Map<int, String?> deviceIcons = {}; 

            for (var dev in currentSupplyDevices) {
              int id = dev['id'];
              deviceTotals[id] = 0.0;
              deviceNames[id] = dev['name'];
              deviceIcons[id] = dev['icon_name']; 
            }

            for (var r in todayReadings) {
              if (deviceTotals.containsKey(r.deviceId)) {
                deviceTotals[r.deviceId] = deviceTotals[r.deviceId]! + r.value;
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: deviceTotals.length,
                    itemBuilder: (context, index) {
                      final deviceId = deviceTotals.keys.elementAt(index);
                      final totalValue = deviceTotals[deviceId]!;
                      final realName = deviceNames[deviceId] ?? 'Unknown Device';
                      final iconName = deviceIcons[deviceId];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: themeColor.withOpacity(0.15), shape: BoxShape.circle),
                              child: Icon(_getIconData(iconName), color: themeColor), 
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(realName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      '${totalValue.toStringAsFixed(2)} $unit',
                                      style: TextStyle(color: themeColor == const Color(0xFFFFE957) ? const Color(0xFFD4C02E) : themeColor, fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Color(0xFFE57373)), // En rojo para que parezca de borrar
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Text('Delete Device', style: TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800)),
                                      content: Text('Are you sure you want to delete "$realName"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<DashboardBloc>().add(DeleteDeviceRequested(deviceId));
                                            Navigator.pop(dialogContext);
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$realName deleted.'), backgroundColor: const Color(0xFFE57373), behavior: SnackBarBehavior.floating));
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                                          child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}