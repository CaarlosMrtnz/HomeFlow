import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:homeflow/core/models/reading.dart';

import '../../logic/dashboard/dashboard_bloc.dart';

/// Pantalla de análisis que visualiza el histórico de consumos semanales mediante gráficos de barras interactivos.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

/// Mantiene el estado del filtro de visualización activo y transforma los datos brutos del BLoC para el formato requerido por la gráfica.
class _InsightsScreenState extends State<InsightsScreen> {
  // 0 = General, 1 = Luz, 2 = Agua, 3 = Gas
  int _selectedFilter = 0;

  /// Extrae y acumula las lecturas de un tipo de suministro específico, mapeándolas a los 7 días de la semana actual.
  List<double> _getWeeklyData(List<Reading> liveReadings, int supplyId) {
    final List<double> weeklyTotals = List.filled(7, 0.0);
    final now = DateTime.now();

    // Calcula el límite temporal inferior desplazando la fecha actual al inicio de la semana
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfThisWeek = DateTime(monday.year, monday.month, monday.day);
    // El fin de la semana es el Domingo a las 23:59:59
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    for (var reading in liveReadings) {
      if (reading.supplyTypeId == supplyId) {
        final localDate = reading.createdAt.toLocal();

        // Solo pasa si pertenece a la semana actual
        if (localDate.isAfter(startOfThisWeek.subtract(const Duration(seconds: 1))) && 
            localDate.isBefore(endOfThisWeek.add(const Duration(seconds: 1)))) {
          
          int index = localDate.weekday - 1; 
          weeklyTotals[index] += reading.value;
        }
      }
    }
    return weeklyTotals;
  }

  /// Construye el árbol de widgets reactivo basándose en las emisiones del [DashboardBloc].
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

            if (state is DashboardLoaded) {
              final elecData = _getWeeklyData(state.readings, 1);
              final waterData = _getWeeklyData(state.readings, 2);
              final gasData = _getWeeklyData(state.readings, 3);

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            colors: [
                              Color(0xFF71B9FD),
                              Color(0xFFBDB2FF),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This week',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A399F)),
                    ),
                    const SizedBox(height: 32),

                    // Gráfica
                    Expanded(
                      child: _buildBarChart(elecData, waterData, gasData),
                    ),
                    const SizedBox(height: 40),

                    // Fila de 4 Botones (general + suministros)
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton(
                            id: 0, 
                            title: 'All', 
                            icon: Icons.stacked_bar_chart_rounded, 
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton(
                            id: 3, 
                            title: 'Gas', 
                            icon: Icons.local_fire_department, 
                            color: const Color(0xFFBDB2FF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton(
                            id: 1, 
                            title: 'Elec.', 
                            icon: Icons.bolt, 
                            color: const Color(0xFFFFE957),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton(
                            id: 2, 
                            title: 'Water', 
                            icon: Icons.water_drop, 
                            color: const Color(0xFF71B9FD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Configura y renderiza el gráfico de barras apiladas utilizando [fl_chart].
  /// Gestiona de forma dinámica las escalas, ejes y formato de unidades según el filtro activo.
  Widget _buildBarChart(List<double> elecData, List<double> waterData, List<double> gasData) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: false, 
        ),
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.black.withOpacity(0.05), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // Eje y dinámico
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45, // Ancho reservado para que quepan las letras
              getTitlesWidget: (value, meta) {
                // Si el valor es 0, no mostramos texto para mantener limpio el origen
                if (value == 0) return const SizedBox.shrink();

                // Si fl_chart manda un número con decimales (ej. 10.5), lo ignoramos
                if (value % 1 != 0) return const SizedBox.shrink();

                String text = value.toInt().toString();
                
                // La unidad se añade solo si hay un filtro específico activo
                if (_selectedFilter == 1) text += ' kWh';
                if (_selectedFilter == 2) text += ' L';
                if (_selectedFilter == 3) text += ' m³';

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (index) {
          final gas = gasData[index];
          final elec = elecData[index];
          final water = waterData[index];
          
          List<BarChartRodStackItem> stackItems = [];
          double totalHeight = 0;

          if (_selectedFilter == 0 || _selectedFilter == 3) {
            stackItems.add(BarChartRodStackItem(0, gas, const Color(0xFFBDB2FF)));
            totalHeight += gas;
          }
          if (_selectedFilter == 0 || _selectedFilter == 1) {
            final start = totalHeight;
            stackItems.add(BarChartRodStackItem(start, start + elec, const Color(0xFFFFE957)));
            totalHeight += elec;
          }
          if (_selectedFilter == 0 || _selectedFilter == 2) {
            final start = totalHeight;
            stackItems.add(BarChartRodStackItem(start, start + water, const Color(0xFF71B9FD)));
            totalHeight += water;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalHeight > 0 ? totalHeight : 0.1,
                width: 18, 
                rodStackItems: stackItems,
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent,
              )
            ],
          );
        }),
      ),
    );
  }

  /// Componente reutilizable para los selectores de tipo de suministro. 
  /// Desencadena el redibujado local mutando `_selectedFilter`.
  Widget _buildFilterButton({
    required int id,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedFilter == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = id;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isSelected ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isSelected) 
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}