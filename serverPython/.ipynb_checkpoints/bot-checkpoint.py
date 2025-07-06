import requests
import threading
import time
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext
from pythonosc.udp_client import SimpleUDPClient

# --- CONFIGURACIÓN ---
TELEGRAM_TOKEN = "7980483937:AAHUBgSNxiRrDNMTLNFppktwbeMkcLIJhHk"
SMARTCITIZEN_URL = "https://api.smartcitizen.me/devices/18831"
OSC_IP = "192.168.122.24"
#OSC_IP = "192.168.122.24"
OSC_PORT = 4560
osc_client = SimpleUDPClient(OSC_IP, OSC_PORT)

# --- FUNCIONES ---

def fetch_smartcitizen_data():
    try:
        r = requests.get(SMARTCITIZEN_URL)
        data = r.json()
        location = data.get("location", {})
        latitude = location.get("latitude", "N/A")
        longitude = location.get("longitude", "N/A")
        city = location.get("city", "Desconocida")
        kit_name = data.get("name", "Desconocido")
        last_reading_at = data.get("last_reading_at", "Desconocida")
        sensors = {s["name"]: s["value"] for s in data["data"]["sensors"]}

        return {
            "kit_name": kit_name,
            "city": city,
            "latitude": latitude,
            "longitude": longitude,
            "last_reading_at": last_reading_at,
            "temperature": sensors.get("Sensirion SHT31 - Temperature", None),
            "noise": sensors.get("TDK ICS43432 - Noise Level A weighting", None),
            "light": sensors.get("ROHM - BH1730FVC", None),
            "humidity": sensors.get("Sensirion SHT31 - Humidity", None),
            "battery": sensors.get("Battery SCK", None),
            "pm1": sensors.get("Sensirion SEN5X - PM1", None),
            "pm10": sensors.get("Sensirion SEN5X - PM10", None),
            "pm25": sensors.get("Sensirion SEN5X - PM2.5", None),
            "pm40": sensors.get("Sensirion SEN5X - PM4.0", None),
            "pm05": sensors.get("Sensirion SEN5X - PN0.5", None),
            "tps": sensors.get("Sensirion SEN5X - TPS", None),
        }

    except Exception as e:
        print(f"[ERROR] {e}")
        return None

def build_info_text(data):
    if not data:
        return "Error obteniendo datos."

    return (
        f"BOT camp: {data['kit_name']}\n"
        f"Kit: {data['kit_name']}\n"
        f"Ciudad: {data['city']}\n"
        f"Latitud: {data['latitude']}, Longitud: {data['longitude']}\n"
        f"Última Lectura: {data['last_reading_at']}\n"
        f"Temperatura: {data['temperature']} °C\n"
        f"Ruido: {data['noise']} dB\n"
        f"Luz: {data['light']} lux\n"
        f"Humedad: {data['humidity']} %\n"
        f"Batería: {data['battery']} %\n"
        f"-----------------------\n"
        f"pm1: {data['pm1']} ug/m3\n"
        f"pm10: {data['pm10']} ug/m3\n"
        f"pm25: {data['pm25']} ug/m3\n"
        f"pm40: {data['pm40']} ug/m3\n"
        f"pm05: {data['pm05']} ug/mm3\n"
        f"tps: {data['tps']} um"
    )

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

# --- HANDLER DEL BOT ---
def info_command(update: Update, context: CallbackContext):
    data = fetch_smartcitizen_data()
    text = build_info_text(data)
    update.message.reply_text(text)

def main():
    # Lanzar hilo para envío continuo por OSC
    threading.Thread(target=send_data_osc_loop, daemon=True).start()

    # Bot de Telegram
    updater = Updater(TELEGRAM_TOKEN, use_context=True)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler("info", info_command))
    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()
