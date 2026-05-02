# HomeFlow (TFG) 💧⚡🔥

HomeFlow es el proyecto práctico de mi Trabajo de Fin de Grado (TFG). Es una aplicación diseñada para centralizar los datos de consumo doméstico (agua, electricidad y gas) en una única interfaz. El objetivo es ofrecer un control detallado del gasto de la vivienda y proporcionar un sistema de alertas en tiempo real ante posibles anomalías o consumos críticos.

## 🚀 Características Principales
* **Monitorización en tiempo real:** Visualización del estado y consumo actual de los electrodomésticos y grifos.
* **Sistema de alertas reactivo:** Notificaciones instantáneas (ej. detección de fugas o picos de tensión) generadas en la base de datos y reflejadas inmediatamente en la interfaz.
* **Historial gráfico:** Representación visual de los datos históricos para identificar patrones de gasto.
* **Arquitectura robusta:** Separación estricta entre la interfaz de usuario y la lógica de negocio para garantizar la escalabilidad y el rendimiento.

## 🛠️ Stack Tecnológico
He dividido la arquitectura del proyecto en tres piezas fundamentales:

* **Frontend (App Móvil):** Desarrollado con **Flutter** y **Dart**. He implementado el patrón arquitectónico **BLoC** (Business Logic Component) junto con `equatable` para gestionar el estado de forma predecible, optimizando los repintados de la interfaz.
* **Backend (Base de Datos):** Gestionado a través de **Supabase** (PostgreSQL). Actúa como única fuente de verdad (*Single Source of Truth*). He configurado políticas de seguridad (RLS), *Triggers* SQL para automatizar las alertas y suscripciones mediante *WebSockets* para la bidireccionalidad de datos.
* **Simulador (Hardware Mock):** Al carecer de sensores IoT físicos, he programado un script en **Python** que inyecta datos de consumo en la base de datos de forma continua, emulando el comportamiento real de una vivienda.

## 📂 Estructura del Repositorio
* `/homeflow`: Contiene el código fuente completo de la aplicación móvil (Flutter).
* `/simulator`: Incluye el script de simulación y la lógica de generación aleatoria de consumos (Python).

## ⚙️ Requisitos Previos
Para poder compilar y ejecutar este proyecto en un entorno local, es necesario tener instalado:
* Flutter SDK (Versión 3.x o superior).
* Python 3 (Versión 3.8 o superior).
* Un entorno de desarrollo como VS Code o Android Studio.
* Las credenciales del proyecto de Supabase (URL y Anon Key).

## 💻 Instalación y Puesta en Marcha

Sigue estos pasos para arrancar el entorno completo (Simulador + Aplicación):

**1. Clonar el repositorio**
git clone https://github.com/CaarlosMrtnz/HomeFlow.git

**2. Configurar las credenciales (Supabase)**
Debido a buenas prácticas de seguridad, las claves del backend no se suben al repositorio. Debes crear un archivo de configuración e introducir las claves de conexión a tu instancia de Supabase.

**3. Iniciar el simulador de consumo (Python)**
Este script es estrictamente necesario para poblar la base de datos en tiempo real y que la aplicación tenga flujos de información que mostrar y procesar. Abre una nueva instancia de la terminal y ejecuta los siguientes comenados.
```bash
cd simulator
python simulador.py
```

**4. Ejecutar la aplicación (Flutter)**
Abre una nueva instancia de la terminal, resuelve las dependencias del proyecto (paquetes de Dart) y lanza la compilación en tu emulador o dispositivo físico conectado.
```bash
cd homeflow
flutter pub get
flutter run
```

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` incluido en el repositorio para más detalles. 

En resumen: eres libre de utilizar, modificar y distribuir este código, incluso con fines comerciales, siempre y cuando se incluya la nota de copyright original y el aviso de la licencia.