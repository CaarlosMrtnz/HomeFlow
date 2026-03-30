import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../core/models/reading.dart';

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

  List<int> _getDevicesForSupply(int supplyId) {
    switch (supplyId) {
      case 1: return [3, 4]; // Frigorífico, Horno
      case 2: return [1, 2]; // Lavadora, Lavavajillas
      case 3: return [5];    // Caldera
      default: return [];
    }
  }

  String _getDeviceName(int deviceId) {
    switch (deviceId) {
      case 1: return 'Lavadora';
      case 2: return 'Lavavajillas';
      case 3: return 'Frigorífico';
      case 4: return 'Horno';
      case 5: return 'Caldera';
      default: return 'Dispositivo $deviceId';
    }
  }

  IconData _getDeviceIcon(int deviceId) {
    switch (deviceId) {
      case 1: return Icons.local_laundry_service;
      case 2: return Icons.wash; 
      case 3: return Icons.kitchen;
      case 4: return Icons.microwave;
      case 5: return Icons.thermostat;
      default: return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF53A1C2)),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, color: Color(0xFF71B9FD)),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final now = DateTime.now();
            
            final todayReadings = state.readings.where((r) => 
              r.supplyTypeId == supplyId &&
              r.createdAt.year == now.year &&
              r.createdAt.month == now.month &&
              r.createdAt.day == now.day
            ).toList();

            final Map<int, double> deviceTotals = {};
            final allowedDevices = _getDevicesForSupply(supplyId);
            
            for (var deviceId in allowedDevices) {
              deviceTotals[deviceId] = 0.0;
            }

            for (var r in todayReadings) {
              if (deviceTotals.containsKey(r.deviceId)) {
                deviceTotals[r.deviceId] = deviceTotals[r.deviceId]! + r.value;
              }
            }

            return Column(
              children: [
                // Lista de dispositivos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: deviceTotals.length,
                    itemBuilder: (context, index) {
                      final deviceId = deviceTotals.keys.elementAt(index);
                      final totalValue = deviceTotals[deviceId]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getDeviceIcon(deviceId), color: themeColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getDeviceName(deviceId),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${totalValue.toStringAsFixed(2)} $unit',
                                      style: TextStyle(
                                        color: themeColor == const Color(0xFFFFE957) ? const Color(0xFFD4C02E) : themeColor, 
                                        fontWeight: FontWeight.w800, 
                                        fontSize: 12
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Color(0xFF71B9FD)),
                                onPressed: () {},
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