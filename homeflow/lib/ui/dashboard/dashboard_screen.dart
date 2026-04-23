import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeflow/ui/insights/supply_detail_screen.dart';

import '../../core/utils/icon_helper.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../core/models/reading.dart';

/// Interfaz principal que consolida el resumen de consumos diarios y la barra de búsqueda de dispositivos.
/// Se suscribe al estado reactivo del [DashboardBloc] para reflejar los datos del simulador en tiempo real.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Estado mutable de la vista que controla la transición entre el modo de visualización y el modo de búsqueda.
class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  /// Filtra y acumula el valor total de las lecturas registradas desde las 00:00 del día en curso para un suministro específico.
  double _calculateTodayTotal(List<Reading> readings, int supplyId) {
    final now = DateTime.now();
    final todayReadings = readings.where((r) {
      final localDate = r.createdAt.toLocal(); 
      return r.supplyTypeId == supplyId &&
             localDate.year == now.year &&
             localDate.month == now.month &&
             localDate.day == now.day;
    });
    return todayReadings.fold(0.0, (sum, reading) => sum + reading.value);
  }

  /// Despliega una lámina inferior (Bottom Sheet) con información pedagógica sobre la métrica seleccionada.
  void _showInfoBottomSheet(BuildContext context, String supplyType) {
    String description = '';
    
    switch (supplyType) {
      case 'Electricity':
        description = 'Este indicador refleja la energía eléctrica total consumida en la vivienda desde el inicio del día. Se mide en kilovatios hora (kWh) y es fundamental para entender el comportamiento de tu demanda energética y optimizar el ahorro en tu factura.';
        break;
      case 'Water':
        description = 'Representa el volumen acumulado de agua que ha fluido por la instalación hoy, medido en litros (L). Monitorizar este dato de forma constante te ayuda a tener un control preciso sobre el gasto hídrico y a identificar posibles anomalías o consumos fantasma.';
        break;
      case 'Gas':
        description = 'Registra el consumo de gas natural acumulado durante la jornada actual, expresado en metros cúbicos (m³). Es una métrica esencial para supervisar el uso de los sistemas de climatización y agua caliente, permitiéndote gestionar mejor el confort térmico de tu hogar.';
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF71B9FD), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'About $supplyType',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5EDFC),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Entendido', style: TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w700)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  /// Construye el árbol de widgets principal reaccionando a las emisiones del [DashboardBloc].
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
                  ? _buildSearchMode(state.readings, state.devices)
                  : _buildNormalDashboard(elecTotal, waterTotal, gasTotal, dashboardBloc);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Pinta las tarjetas resumen de consumos acumulados y el acceso a la barra de búsqueda.
  Widget _buildNormalDashboard(double elecTotal, double waterTotal, double gasTotal, DashboardBloc dashboardBloc) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
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
          ],
        ),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            readOnly: true,
            onTap: () => setState(() => _isSearching = true), 
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              suffixIcon: Icon(Icons.search, color: Color(0xFF71B9FD)), 
            ),
          ),
        ),
        const SizedBox(height: 24),
        
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
        
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
              value: dashboardBloc,
              child: const SupplyDetailScreen(supplyId: 2, title: 'Water', themeColor: Color(0xFF71B9FD), unit: 'L'),
            )));
          },
          child: _buildSupplyCard(
            tagText: 'Water', 
            title: 'Today\'s\nUsage',
            value: waterTotal.toStringAsFixed(2),
            unit: ' L',
            icon: Icons.water_drop,
            iconColor: const Color(0xFF71B9FD), 
            valueColor: const Color(0xFF71B9FD),
          ),
        ),
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
              value: dashboardBloc,
              child: const SupplyDetailScreen(supplyId: 3, title: 'Gas', themeColor: Color(0xFFBDB2FF), unit: 'm³'),
            )));
          },
          child: _buildSupplyCard(
            tagText: 'Gas', 
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

  /// Despliega el catálogo interactivo de dispositivos y su consumo parcial aplicando filtros por texto.
  Widget _buildSearchMode(List<Reading> allReadings, List<dynamic> allDevices) {
    final now = DateTime.now();
    
    // Lecturas de hoy
    final todayReadings = allReadings.where((r) => 
      r.createdAt.year == now.year && 
      r.createdAt.month == now.month && 
      r.createdAt.day == now.day
    ).toList();

    // Mapea los totales de consumo de hoy por ID de dispositivo
    final Map<int, double> todayTotals = {};
    for (var r in todayReadings) {
      todayTotals[r.deviceId] = (todayTotals[r.deviceId] ?? 0.0) + r.value;
    }

    // Filtra todo el catálogo de dispositivos por la búsqueda
    final query = _searchController.text.toLowerCase();
    final filteredDevices = allDevices.where((device) {
      final realDeviceName = device['name'].toString().toLowerCase();
      return realDeviceName.contains(query);
    }).toList();

    return Column(
      children: [
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
                    autofocus: true,
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

        Expanded(
          child: filteredDevices.isEmpty
              ? const Center(child: Text('No devices found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    
                    final deviceId = device['id'] as int;
                    final deviceName = device['name'].toString();
                    final supplyTypeId = device['supply_type_id'] as int;
                    final deviceIconName = device['icon_name'].toString();

                    final totalValue = todayTotals[deviceId] ?? 0.0; 
                    
                    // Colores según el tipo de suministro
                    final themeColor = supplyTypeId == 1 ? const Color(0xFFFFE957) : 
                                       supplyTypeId == 2 ? const Color(0xFF71B9FD) : 
                                       const Color(0xFFBDB2FF);
                                       
                    final deviceIcon = IconHelper.getIcon(deviceIconName);
                                       
                    final unit = supplyTypeId == 1 ? 'kWh' : 
                                 supplyTypeId == 2 ? 'L' : 'm³';

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
                            child: Icon(deviceIcon, color: themeColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    '${totalValue.toStringAsFixed(2)} $unit',
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

  /// Template estandarizado para los paneles contenedores de métricas totales.
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
                  GestureDetector(
                    onTap: () {
                      _showInfoBottomSheet(context, tagText);
                    },
                    child: Icon(Icons.info_outline, color: const Color(0xFF203DA3).withOpacity(0.5), size: 22),
                  ),
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