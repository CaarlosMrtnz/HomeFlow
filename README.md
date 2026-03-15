# HomeFlow (TFG) 💧⚡🔥

HomeFlow es una aplicación en desarrollo para mi Trabajo de Fin de Grado (TFG). Su objetivo es centralizar los datos de consumo de agua, luz y gas de una vivienda en una única interfaz para ayudar a gestionar el gasto y detectar anomalías en tiempo real.

> **Estado del proyecto:** 🚧 En desarrollo (Fase de integración backend-frontend).

## 🛠️ Stack Tecnológico
El proyecto se divide en tres piezas fundamentales:
* **Frontend:** Aplicación multiplataforma creada con Flutter y el patrón BLoC.
* **Backend:** Base de datos relacional y gestión en tiempo real con Supabase (PostgreSQL). Incluye triggers SQL para la detección de umbrales críticos.
* **Simulador:** Script en Python que inyecta datos continuamente para recrear el comportamiento de sensores reales en una vivienda.

## 📂 Estructura del Repositorio
* `/homeflow`: Código fuente de la aplicación móvil (Flutter).
* `/simulator`: Script de simulación y lógica de generación de datos (Python).

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` incluido en el repositorio para más detalles. 

En resumen: eres libre de utilizar, modificar y distribuir este código, incluso con fines comerciales, siempre y cuando se incluya la nota de copyright original y el aviso de la licencia.
