import os
import time
import random
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

url = os.environ.get('SPB_URL')
key = os.environ.get('SPB_KEY')
# UUID de un usuario de prueba creado en 'profiles'
test_user = os.environ.get('TEST_USER_UUID')
if not test_user:
    print("Error: No se ha encontrado TEST_USER_UUID en el archivo .env")
    exit()

range_config = {
        1: {"normal": (0.1, 3.5),  "anomaly": (3.51, 6.0)}, # Electricity
        2: {"normal": (0.5, 20.0), "anomaly": (20.01, 30.0)}, # Water
        3: {"normal": (0.1, 2.0),  "anomaly": (2.01, 5.0)},  # Gas
    }

supabase: Client = create_client(url, key)

def simulate_usage():

    # IDs de suministro según BD: 1 (Electricidad), 2 (Agua), 3 (Gas)
    supply_id = random.choice([1, 2, 3])

    # 10% de probabilidad de generar una anomalía/fuga/pico
    is_anomaly = random.random() < 0.1

    if supply_id not in range_config:
        print(f"Error: ID de suministro {supply_id} no reconocido.")
        return # Salimos de la función si el ID es inválido
    
    estado = "anomaly" if is_anomaly else "normal"
    rango = range_config[supply_id][estado]

    value = round(random.uniform(rango[0], rango[1]), 2)

    # Insertamos la lectura en Supabase
    try:
        data, count = supabase.table('readings').insert({
            "user_id": test_user,
            "supply_type_id": supply_id,
            "value": value
        }).execute()
        print(f"[{time.strftime('%X')}] Insertado suministro {supply_id} con valor {value}.")
    except Exception as e:
        print(f"Error al insertar: {e}")

if __name__ == "__main__":
    print("Iniciando simulador de HomeFlow... (Ctrl+C para detener).")
    try:
        while True:
            simulate_usage()
            time.sleep(5) # Inserta un dato cada 5 segundos
    except KeyboardInterrupt:
        print("\nSimulador detenido.")
            


