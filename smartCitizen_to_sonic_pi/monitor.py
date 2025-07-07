import serial
import threading
import time
from pythonosc.udp_client import SimpleUDPClient

OSC_IP = "127.0.0.1"
OSC_PORT = 4560
osc_client = SimpleUDPClient(OSC_IP, OSC_PORT)

lock = threading.Lock()
latest_data = {}

def read_serial_loop(ser):
    global latest_data
    while True:
        line = ser.readline().decode('utf-8', errors='ignore').strip()
        if line:
            parts = line.split('\t')
            if len(parts) >= 8:
                try:
                    pm_1_0 = float(parts[3])
                    pm_2_5 = float(parts[4])
                    pm_4_0 = float(parts[5])
                    pm_10_0 = float(parts[6])
                    noise = float(parts[7])
                    with lock:
                        latest_data = {
                            "pm_1_0": pm_1_0,
                            "pm_2_5": pm_2_5,
                            "pm_4_0": pm_4_0,
                            "pm_10_0": pm_10_0,                            
                            "noise": noise
                        }
                    #print(f"PM1.0: {pm_1_0}, PM2.5: {pm_2_5}, PM4.0: {pm_4_0}, PM10.0: {pm_10_0}")
                except ValueError:
                    print("⚠️ Error al convertir a float")
            else:
                print("⚠️ Línea ignorada (demasiado corta o no válida)")
        time.sleep(0.1)  # Para no saturar CPU

def send_data_osc_loop():
    global latest_data
    while True:
        with lock:
            data = latest_data.copy()
        if data:
            pm_1_0 = round(data["pm_1_0"])
            pm_2_5 = round(data["pm_2_5"])
            pm_4_0 = round(data["pm_4_0"])
            pm_10_0 = round(data["pm_10_0"])
            noise = round(data["noise"])

            osc_client.send_message("/pm_1_0", pm_1_0)
            osc_client.send_message("/pm_2_5", pm_2_5)
            osc_client.send_message("/pm_4_0", pm_4_0)
            osc_client.send_message("/pm_10_0", pm_10_0)
            osc_client.send_message("/noise", noise)

            print(f"[OSC] Enviando a {OSC_IP}:{OSC_PORT} -> PM1.0={pm_1_0}, PM2.5={pm_2_5}, PM4.0={pm_4_0}, PM10.0={pm_10_0}, noise={noise}")
        time.sleep(0.1)

def main():
    print("smart citizen connection")
    ser = serial.Serial('/dev/ttyACM0', 115200, timeout=1)
    time.sleep(2)
    ser.write(b"monitor SEN5X PM 1.0,SEN5X PM 2.5,SEN5X PM 4.0,SEN5X PM 10.0,noise\n")

    threading.Thread(target=read_serial_loop, args=(ser,), daemon=True).start()
    threading.Thread(target=send_data_osc_loop, daemon=True).start()

    # Mantener el programa vivo
    while True:
        time.sleep(1)

if __name__ == "__main__":
    main()
