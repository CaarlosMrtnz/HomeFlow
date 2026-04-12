import os
import time
import random
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

url = os.environ.get('SPB_URL')
key = os.environ.get('SPB_KEY')
test_user = os.environ.get('TEST_USER_UUID')

if not all([url, key, test_user]):
    print("Error: Revisa tus variables de entorno en el archivo .env")
    exit()

supabase: Client = create_client(url, key)

range_config = {
    1: {"normal": (0.1, 3.5),  "anomaly": (3.51, 6.0)}, 
    2: {"normal": (0.5, 20.0), "anomaly": (20.01, 30.0)},
    3: {"normal": (0.1, 2.0),  "anomaly": (2.01, 5.0)},
}

# Guardar el estado en memoria funciona para este script en local. 
device_states = {}

def get_devices():
    try:
        # Usamos .or_ para filtrar: o el user_id es null (globales) o es el test_user (propios)
        response = supabase.table('devices').select("*").or_(f"user_id.is.null,user_id.eq.{test_user}").execute()
        return response.data
    except Exception as e:
        print(f"Error al obtener dispositivos: {e}")
        return []

def simulate_usage(devices):
    if not devices:
        return

    device = random.choice(devices)
    device_id = device['id']
    supply_id = device['supply_type_id']
    device_name = device['name']

    if device_id not in device_states:
        device_states[device_id] = False

    is_currently_on = device_states[device_id]

    if not is_currently_on:

        # Probabilidades arbitrarias altas para forzar movimiento en la UI de Flutter y no quedarnos mirando una pantalla estática durante las pruebas.
        turn_on = random.random() < 0.3
        if turn_on:
            device_states[device_id] = True
            estado_str = "encendido"
            rango = range_config[supply_id]["normal"]
            value = round(random.uniform(rango[0], rango[1]), 2)
        else:
            value = 0.0
            estado_str = "Continua apagado"
    else:

        turn_off = random.random() < 0.2
        if turn_off:
            device_states[device_id] = False
            value = 0.0
            estado_str = "apagado"
        else:

            # 10% de probabilidad fija de anomalía para probar los triggers de BD, el envío de notificaciones y la UI de alertas sin tener que forzar el dato a mano.
            is_anomaly = random.random() < 0.1
            estado_str = "¡Posible leak!" if is_anomaly else "ya estaba encendido"
            rango = range_config[supply_id]["anomaly" if is_anomaly else "normal"]
            value = round(random.uniform(rango[0], rango[1]), 2)

    try:
        supabase.table('readings').insert({
            "user_id": test_user,
            "supply_type_id": supply_id,
            "device_id": device_id,
            "value": value
        }).execute()
         
        if estado_str != "Continua apagado":
            print(f"[{time.strftime('%X')}] {device_name} {estado_str} ({value} unidades).")
    except Exception as e:
        print(f"Error al insertar lectura de {device_name}: {e}")

if __name__ == "__main__":
    print("Iniciando simulador de HomeFlow...")
    
    try:
        while True:
            available_devices = get_devices()
            
            if not available_devices:
                print("ERROR: No se han encontrado electrodomésticos para este usuario.")
            else:
                simulate_usage(available_devices)
                
            # Loop de 5 segundos
            time.sleep(5)
    except KeyboardInterrupt:
        print("\nSimulador detenido.")