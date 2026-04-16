import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeflow/core/utils/icon_helper.dart';
import 'dart:async';

import '../../logic/alerts/alerts_bloc.dart';
import '../../core/models/alert.dart';
import '../../core/models/enums.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _scheduleMidnightRefresh();
  }

  // Calcula cuánto falta para las 00:00:00
  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    // Calcula el instante exacto de la próxima medianoche (sumando 1 día)
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  
    // Calcular la diferencia de tiempo entre ahora y la medianoche evita usar un Timer.periodic, que poco a poco sufriría desvíos (drift) por los micro-retrasos del event loop de Dart.
    final timeUntilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () {
      if (mounted) {
        // Esto obliga a Flutter a volver a ejecutar el método build() recalculando así todos los "Today" y "Yesterday"
        setState(() {}); 
        
        // Se programa el reloj para la noche siguiente
        _scheduleMidnightRefresh(); 
      }
    });
  }

  @override
  void dispose() {
    // Si el usuario sale de la pantalla, se destruye el temporizador para no dejar procesos fantasma consumiendo memoria.
    _midnightTimer?.cancel();
    super.dispose();
  }

  // Función técnica para determinar la etiqueta del día 
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    // Truncar las horas reconstruyendo el DateTime es la forma más segura en Dart de comparar días enteros sin pelear con los milisegundos.
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final alertDate = DateTime(date.year, date.month, date.day);

    if (alertDate == today) return 'Today';
    if (alertDate == yesterday) return 'Yesterday';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Agrupamos la lista plana en un Mapa { 'Today': [Alerta1, Alerta2], 'Yesterday': [Alerta3] }
  // Hacemos esta agrupación en la UI y no en el BLoC porque el concepto de 'Hoy' o 'Ayer' depende estrictamente de la hora local del dispositivo en el momento de pintar la vista.
  Map<String, List<Alert>> _groupAlerts(List<Alert> alerts) {
    final grouped = <String, List<Alert>>{};
    for (var alert in alerts) {
      final label = _getDateLabel(alert.createdAt);
      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(alert);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding( 
              padding: const EdgeInsets.all(24.0), 
              child: ShaderMask(
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
                  'Notifications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    // El color blanco actúa como "lienzo" para que el gradiente pinte encima
                    color: Colors.white, 
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AlertsBloc, AlertsState>(
                builder: (context, state) {
                  if (state is AlertsInitial || state is AlertsLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF203DA3)));
                  }

                  if (state is AlertsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is AlertsLoaded) {
                    if (state.alerts.isEmpty) {
                      return const Center(
                        child: Text('No tienes notificaciones nuevas', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final groupedAlerts = _groupAlerts(state.alerts);
                    
                    // El mapa se convierte en una lista plana de Widgets (Textos de cabecera y tarjetas)
                    final List<Widget> listItems = [];
                    
                    groupedAlerts.forEach((dateLabel, dayAlerts) {
                      // Título del día
                      listItems.add(
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 8.0),
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF203DA3),
                            ),
                          ),
                        ),
                      );
                      
                      // Todas las tarjetas de ese día
                      for (var alert in dayAlerts) {
                        listItems.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: _buildNotificationCard(context, alert),
                          ),
                        );
                      }
                    });

                    // Aplanar todo en una única lista nos evita tener que anidar varios ListView.builder, lo cual arruinaría el rendimiento del scroll.
                    return ListView(
                      children: listItems,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Alert alert) {
    // Estados y colores del Badge (Leak, On, Off)
    Color badgeColor = Colors.grey;
    String badgeText = 'Unknown';
    
    switch (alert.description) {
      case AlertDescription.leak:
        badgeColor = const Color(0xFFEF5254); 
        badgeText = 'Possible leak detected'; 
        break;
      case AlertDescription.leftOn:
        badgeColor = const Color(0xFF43C9A3); 
        badgeText = 'On'; 
        break;
      case AlertDescription.leftOff:
        badgeColor = const Color(0xFF686868); 
        badgeText = 'Off'; 
        break;
      case AlertDescription.unknown:
        break;
    }

    // --- AQUÍ ESTÁ LA MAGIA ---
    // 1. El icono lo decide el traductor unificado buscando el nombre exacto del electrodoméstico
    IconData deviceIcon = IconHelper.getIcon(alert.deviceIconName); 
    
    // 2. El color de fondo lo decide el tipo de suministro
    Color iconBgColor = Colors.grey.shade200; 
    switch (alert.supplyTypeId) {
      case 1: 
        iconBgColor = const Color(0xFFFFE957); 
        break;
      case 2: 
        iconBgColor = const Color(0xFF71B9FD); 
        break;
      case 3: 
        iconBgColor = const Color(0xFFBDB2FF); 
        break;
      default:
        break;
    }

    // Formateo de la hora
    final timeString = 
    "${alert.createdAt.hour.toString().padLeft(2, '0')}:${alert.createdAt.minute.toString().padLeft(2, '0')}:${alert.createdAt.second.toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: () {
        if (!alert.isRead) {
          context.read<AlertsBloc>().add(MarkAlertAsRead(alert.id));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: alert.isRead ? null : Border.all(color: const Color(0xFF203DA3).withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor, // El fondo amarillo, azul o morado
                shape: BoxShape.circle, 
              ),
              child: Icon(
                deviceIcon, // El icono específico (lavadora, tv, horno...)
                color: const Color(0xFF203DA3), 
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 16, 
                          color: Color(0xFF203DA3) 
                        ),
                      ),
                      Text(
                        timeString,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6), 
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}