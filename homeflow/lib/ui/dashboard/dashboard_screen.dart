import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/dashboard/dashboard_bloc.dart';
import '../../core/models/reading.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                            colors: [
                              Color(0xFF71B9FD),
                              Color(0xFFBDB2FF),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'HomeFlow',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Color(0xFF53A1C2), size: 32),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tarjetas
                  _buildSupplyCard(
                    tagText: 'Electricity', 
                    title: 'Today\'s\nUsage',
                    value: elecTotal.toStringAsFixed(2),
                    unit: ' kWh',
                    icon: Icons.bolt,
                    iconColor: const Color(0xFFFFE957), 
                    valueColor: const Color(0xFFFFE957),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSupplyCard(
                    tagText: 'Water', 
                    title: 'Today\'s\nUsage',
                    value: waterTotal.toStringAsFixed(2),
                    unit: ' L',
                    icon: Icons.water_drop,
                    iconColor: const Color(0xFF71B9FD), 
                    valueColor: const Color(0xFF71B9FD),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSupplyCard(
                    tagText: 'Gas',
                    title: 'Today\'s\nUsage',
                    value: gasTotal.toStringAsFixed(2),
                    unit: ' m³',
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFBDB2FF), 
                    valueColor: const Color(0xFFBDB2FF),
                  ),
                  
                  // Espacio extra para que la última tarjeta no la tape el menú flotante
                  const SizedBox(height: 100), 
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // El icono gigante difuminado de fondo a la derecha
          Positioned(
            right: 0,
            top: 10,
            bottom: 10,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: Icon(icon, color: iconColor.withOpacity(0.8), size: 60),
            ),
          ),
          
          // Contenido principal de la tarjeta
          Column(
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
                      mainAxisSize: MainAxisSize.min, // Crucial para que no se expanda por toda la tarjeta
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
                            color: Color(0xFF203DA3), // Tu azul marino corporativo
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
              
              // Textos de consumo y título
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