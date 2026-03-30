import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeflow/ui/insights/supply_detail_screen.dart';

import '../../logic/dashboard/dashboard_bloc.dart';
import '../../core/models/reading.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  double _calculateTodayTotal(List<Reading> readings, int supplyId) {
    final now = DateTime.now();
    final todayReadings = readings.where((r) => 
      r.supplyTypeId == supplyId &&
      r.createdAt.year == now.year &&
      r.createdAt.month == now.month &&
      r.createdAt.day == now.day
    );
    return todayReadings.fold(0.0, (sum, reading) => sum + reading.value);
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
      case 2: return Icons.kitchen;
      case 3: return Icons.kitchen;
      case 4: return Icons.microwave;
      case 5: return Icons.hvac;
      default: return Icons.device_unknown;
    }
  }

  Color _getThemeColor(int deviceId) {
    switch (deviceId) {
      case 1:
      case 2: return const Color(0xFF71B9FD); 
      case 3:
      case 4: return const Color(0xFFFFE957); 
      case 5: return const Color(0xFFBDB2FF); 
      default: return Colors.grey;
    }
  }

  String _getUnit(int deviceId) {
    switch (deviceId) {
      case 1:
      case 2: return 'L';
      case 3:
      case 4: return 'kWh';
      case 5: return 'm³';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF203DA3)));
            }

            if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is DashboardLoaded) {
              final elecTotal = _calculateTodayTotal(state.readings, 1);
              final waterTotal = _calculateTodayTotal(state.readings, 2);
              final gasTotal = _calculateTodayTotal(state.readings, 3);
              final dashboardBloc = context.read<DashboardBloc>();

              return _isSearching 
                  ? _buildSearchMode(state.readings)
                  : _buildNormalDashboard(elecTotal, waterTotal, gasTotal, dashboardBloc);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNormalDashboard(double elecTotal, double waterTotal, double gasTotal, DashboardBloc dashboardBloc) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        // Cabecera
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF71B9FD), Color(0xFFBDB2FF)],
                ).createShader(bounds);
              },
              child: const Text(
                'HomeFlow',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const Icon(Icons.more_horiz, color: Color(0xFF53A1C2), size: 32),
          ],
        ),
        const SizedBox(height: 24),

        // Barra de búsqueda inferior 
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            readOnly: true, // Evita que se abra el teclado aquí abajo
            onTap: () => setState(() => _isSearching = true), // Cambia al modo búsqueda
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              suffixIcon: Icon(Icons.search, color: Color(0xFF71B9FD)), // Lupa a la derecha
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Tarjeta 1: Electricidad
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
              value: dashboardBloc,
              child: const SupplyDetailScreen(supplyId: 1, title: 'Electricity', themeColor: Color(0xFFFFE957), unit: 'kWh'),
            )));
          },
          child: _buildSupplyCard(
            tagText: 'Electricity', 
            title: 'Today\'s\nUsage',
            value: elecTotal.toStringAsFixed(2),
            unit: ' kWh',
            icon: Icons.bolt,
            iconColor: const Color(0xFFFFE957), 
            valueColor: const Color(0xFFFFE957),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tarjeta 2: Agua
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
              value: dashboardBloc,
              child: const SupplyDetailScreen(supplyId: 2, title: 'Water', themeColor: Color(0xFF71B9FD), unit: 'L'),
            )));
          },
          child: _buildSupplyCard(
            tagText: 'Today', // Ajustado a tu imagen
            title: 'Today\'s\nUsage',
            value: waterTotal.toStringAsFixed(2),
            unit: ' L',
            icon: Icons.water_drop,
            iconColor: const Color(0xFF71B9FD), 
            valueColor: const Color(0xFF71B9FD),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tarjeta 3: Gas
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
              value: dashboardBloc,
              child: const SupplyDetailScreen(supplyId: 3, title: 'Gas', themeColor: Color(0xFFBDB2FF), unit: 'm³'),
            )));
          },
          child: _buildSupplyCard(
            tagText: 'Today', 
            title: 'Today\'s\nUsage',
            value: gasTotal.toStringAsFixed(2),
            unit: ' m³',
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFBDB2FF), 
            valueColor: const Color(0xFFBDB2FF),
          ),
        ),
        const SizedBox(height: 100), 
      ],
    );
  }

  Widget _buildSearchMode(List<Reading> allReadings) {
    final now = DateTime.now();
    final todayReadings = allReadings.where((r) => 
      r.createdAt.year == now.year && r.createdAt.month == now.month && r.createdAt.day == now.day
    );

    final Map<int, double> allDeviceTotals = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0};
    for (var r in todayReadings) {
      if (allDeviceTotals.containsKey(r.deviceId)) {
        allDeviceTotals[r.deviceId] = allDeviceTotals[r.deviceId]! + r.value;
      }
    }

    final query = _searchController.text.toLowerCase();
    final filteredDevices = allDeviceTotals.keys.where((id) {
      final name = _getDeviceName(id).toLowerCase();
      return name.contains(query);
    }).toList();

    return Column(
      children: [
        // Cabecera de búsqueda con botón Atrás
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 24, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true, // Abre el teclado automáticamente
                    onChanged: (value) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search devices...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      suffixIcon: Icon(Icons.search, color: Color(0xFF71B9FD)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Resultados
        Expanded(
          child: filteredDevices.isEmpty
              ? const Center(child: Text('No devices found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final deviceId = filteredDevices[index];
                    final totalValue = allDeviceTotals[deviceId]!;
                    final themeColor = _getThemeColor(deviceId);

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
                            child: Icon(_getDeviceIcon(deviceId), color: themeColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getDeviceName(deviceId), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    '${totalValue.toStringAsFixed(2)} ${_getUnit(deviceId)}',
                                    style: TextStyle(
                                      color: themeColor == const Color(0xFFFFE957) ? const Color(0xFFD4C02E) : themeColor, 
                                      fontWeight: FontWeight.w800, fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSupplyCard({
    required String tagText,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 10,
            bottom: 10,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: iconColor.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
              ),
              child: Icon(icon, color: iconColor.withOpacity(0.8), size: 60),
            ),
          ),
          
          Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // ... Todo el código de tu Row con el Tag "Today"
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 14, 
                          color: iconColor, 
                        ),
                        const SizedBox(width: 6), 
                        Text(
                          tagText, 
                          style: const TextStyle(
                            color: Color(0xFF203DA3), 
                            fontWeight: FontWeight.w700, 
                            fontSize: 13
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.info_outline, color: const Color(0xFF203DA3).withOpacity(0.5), size: 22),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700, 
                  fontSize: 15, 
                  color: Color(0xFF1E293B), 
                  height: 1.2
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: iconColor == const Color(0xFFFFE957) ? const Color(0xFFFACC15) : valueColor, 
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Color(0xFF64748B), 
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}