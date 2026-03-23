import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/dashboard/dashboard_bloc.dart';
import '../../core/models/reading.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Función auxiliar para buscar la lectura más reciente de un suministro concreto.
  // Como la lista del repositorio ya viene ordenada por fecha descendente,
  // el primer elemento que coincida con el ID será el más actual.
  Reading? _getLatestReading(List<Reading> readings, int supplyId) {
    // try-catch porque firstWhere lanza un StateError si la lista no contiene el elemento. Es una alternativa rápida para no tener que importar el paquete 'collection' entero solo por usar firstWhereOrNull.
    try {
      return readings.firstWhere((r) => r.supplyTypeId == supplyId);
    } catch (e) {
      return null; // Si no hay datos aún, devolvemos null
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          // Estado de carga 
          if (state is DashboardInitial || state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF203DA3)));
          }

          // Estado de error
          if (state is DashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // Estado de listo 
          if (state is DashboardLoaded) {
            // Extraemos los últimos valores. (IDs: 1 = Luz, 2 = Agua, 3 = Gas)
            // Ligar la vista directamente a estos números (magic numbers) asume que el catálogo en base de datos es inmutable. Si la app crece, habría que mapear esto a otro Enum.
            final elecReading = _getLatestReading(state.readings, 1);
            final waterReading = _getLatestReading(state.readings, 2);
            final gasReading = _getLatestReading(state.readings, 3);

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Cabecera
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HomeFlow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF203DA3), 
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tarjeta de electricidad
                _buildSupplyCard(
                  title: 'Today\'s\nUsage',
                  value: elecReading != null ? elecReading.value.toStringAsFixed(2) : '0.00',
                  unit: ' kWh',
                  icon: Icons.bolt,
                  iconColor: Color(0xFFFFE957),
                  valueColor: Color(0xFFFFE957),
                ),
                const SizedBox(height: 16),

                // Tarjeta de agua
                _buildSupplyCard(
                  title: 'Today\'s\nUsage',
                  value: waterReading != null ? waterReading.value.toStringAsFixed(2) : '0.00',
                  unit: ' L',
                  icon: Icons.water_drop,
                  iconColor: Color(0xFF71B9FD),
                  valueColor: Color(0xFF71B9FD),
                ),
                const SizedBox(height: 16),

                // Tarjeta de gas
                _buildSupplyCard(
                  title: 'Today\'s\nUsage',
                  value: gasReading != null ? gasReading.value.toStringAsFixed(2) : '0.00',
                  unit: ' m3',
                  icon: Icons.local_fire_department,
                  iconColor: Color(0xFFBDB2FF),
                  valueColor: Color(0xFFBDB2FF),
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          // Fallback por si el bloc emite un estado no manejado en los ifs anteriores. SizedBox.shrink() es la opción de coste nulo para Flutter porque no requiere calcular layouts.
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget reutilizable para las tarjetas de consumo
  Widget _buildSupplyCard({
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(color: iconColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          // Icono con resplandor suave
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
        ],
      ),
    );
  }
}