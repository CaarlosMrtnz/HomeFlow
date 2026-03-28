import 'package:flutter/material.dart';
import 'package:homeflow/ui/alerts/notification_screen.dart';
import 'package:homeflow/ui/dashboard/dashboard_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Contenedores temporales
  final List<Widget> _screens = [
    const DashboardScreen(),
    Container(color: Colors.blue, child: const Center(child: Text('Insights'))),
    const NotificationsScreen(),
    Container(color: Colors.orange, child: const Center(child: Text('Search'))),
    Container(color: Colors.purple, child: const Center(child: Text('Account'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Para el efecto flotante
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Separación de los bordes
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Bordes circulares
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // ClipRRect porque el borderRadius del Container padre no recorta los efectos de Material. Sin esto, la animación del ripple al hacer tap desbordaría visualmente las esquinas.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0, // Sombra por defecto apagada

              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed, 
              selectedItemColor: const Color(0xFF203DA3), 
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}