import serial
import time

def main():


    print("smart citizen connection")
    # Abre el puerto serie. Cambia el puerto si es necesario.
    ser = serial.Serial('/dev/ttyACM0', 115200, timeout=1)

    # Espera a que el dispositivo esté listo
    #time.sleep(2)

    # Espera un momento para que el puerto se estabilice
    time.sleep(2)

    # Envía el comando "monitor noise"
    ser.write(b"monitor noise\n")

    # Lee datos durante, por ejemplo, 10 segundos
    start_time = time.time()
   
    
    
    
    while time.time() - start_time < 60:
        line = ser.readline().decode('utf-8', errors='ignore').strip()
        if line:
            print(line)

    # Cierra la conexión
    ser.close()
    # Lanzar hilo para envío continuo por OSC
#    threading.Thread(target=send_data_osc_loop, daemon=True).start()

    




def send_data_osc(data):
    if not data:
        return
    osc_client.send_message("/temperature", data["temperature"])
    osc_client.send_message("/noise", data["noise"])
    osc_client.send_message("/light", data["light"])
    osc_client.send_message("/humidity", data["humidity"])
    osc_client.send_message("/battery", data["battery"])
    osc_client.send_message("/pm1", data["pm1"])
    osc_client.send_message("/pm10", data["pm10"])
    osc_client.send_message("/pm25", data["pm25"])
    osc_client.send_message("/pm40", data["pm40"])
    osc_client.send_message("/pm05", data["pm05"])
    osc_client.send_message("/tps", data["tps"])
    osc_client.send_message("/kit", data["kit_name"])
    osc_client.send_message("/city", data["city"])

    # --- DEBUG POR CONSOLA ---
    print("[OSC] Datos enviados:", {
        "temperature": data["temperature"],
        "noise": data["noise"],
        "light": data["light"],
        "humidity": data["humidity"],
        "battery": data["battery"],
        "pm1": data["pm1"],
        "pm10": data["pm10"],
        "pm25": data["pm25"],
        "pm40": data["pm40"],
        "pm05": data["pm05"],
        "tps": data["tps"],
        "kit": data["kit_name"],
        "city": data["city"]
    })
    print("[OSC] Datos enviados:", {
        "temperature": data["temperature"],
        "noise": data["noise"],
        "light": data["light"],
        "humidity": data["humidity"],
        "battery": data["battery"],
        "pm1": data["pm1"],
        "pm10": data["pm10"],
        "pm25": data["pm25"],
        "pm40": data["pm40"],
        "pm05": data["pm05"],
        "tps": data["tps"],
        "OSC_PORT": OSC_PORT,
        "OSC_IP": OSC_IP
    })

def send_data_osc_loop():
    while True:
        data = fetch_smartcitizen_data()
        send_data_osc(data)
        time.sleep(10)
if __name__ == "__main__":
    main()
