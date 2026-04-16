import os
import time
import random
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

url = os.environ.get('SPB_URL')
key = os.environ.get('SPB_KEY')

if not all([url, key]):
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

def get_devices(target_user=None):
    try:
        # Todos los dispositivos que tengan dueño
        query = supabase.table('devices').select("*").not_.is_('user_id', 'null')
        
        # Si recibe un usuario específico (Modo Demo), filtra la consulta
        if target_user:
            query = query.eq('user_id', target_user)
            
        response = query.execute()
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
    device_owner = device['user_id']

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
            "user_id": device_owner,
            "supply_type_id": supply_id,
            "device_id": device_id,
            "value": value
        }).execute()
         
        if estado_str != "Continua apagado":
            print(f"[{time.strftime('%X')}] {device_name} {estado_str} ({value} unidades).")
    except Exception as e:
        print(f"Error al insertar lectura de {device_name}: {e}")

def get_target_user():
    print("\n🤖 Menú HomeFlow")
    print("-"*40)
    print("1. Modo multiuser")
    print("2. Modo TFG")
    
    opcion = input("\nElige una opción (1 o 2): ")

    if opcion == '2':
        dev_response = supabase.table('devices').select('user_id, name').not_.is_('user_id', 'null').execute()
        
        email_map = {}
        try:
            users_response = supabase.auth.admin.list_users()
            for user in users_response:
                email_map[user.id] = user.email
        except Exception as e:
            print("Nota: No se pudieron obtener los emails. Verifica la clave service_role.")
        
        usuarios = {}
        for d in dev_response.data:
            uid = d['user_id']
            if uid not in usuarios:
                usuarios[uid] = []
            usuarios[uid].append(d['name'])
            
        if not usuarios:
            print("No hay dispositivos con dueño en la base de datos.")
            return None
            
        print("\nCuentas detectadas en la Base de Datos:")
        lista_uids = list(usuarios.keys())
        for i, uid in enumerate(lista_uids):
            aparatos = ", ".join(usuarios[uid][:3]) 
            
            identificador = email_map.get(uid, f"{uid[:8]}...")
            
            print(f"  [{i+1}] Cuenta: {identificador}")
            
        seleccion = input("\nIntroduce el número de la cuenta a elegir: ")
        try:
            indice = int(seleccion) - 1
            if 0 <= indice < len(lista_uids):
                uid_seleccionado = lista_uids[indice]
                identificador_seleccionado = email_map.get(uid_seleccionado, f"{uid_seleccionado[:8]}...")
                print(f"\n🚀 Iniciando simulador sobre la cuenta: {identificador_seleccionado}")
                return uid_seleccionado
        except ValueError:
            pass
        print("Selección no válida. Se usará el modo multiuser.")
        
    print("\n🌍 Iniciando en multiuser...")
    return None

if __name__ == "__main__":
    # Modo que el user quiere usar
    target_user = get_target_user()
    
    try:
        while True:
            # Dispositivos pedidos (le pasamos el filtro si existe)
            available_devices = get_devices(target_user)
            
            if not available_devices:
                print("Esperando dispositivos...")
            else:
                simulate_usage(available_devices)
                
            time.sleep(5)
    except KeyboardInterrupt:
        print("\nSimulador detenido.")