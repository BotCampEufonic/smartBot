import requests
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext

# Pega aquí tu token de Bot de Telegram
TELEGRAM_TOKEN = "7747284015:AAFhUe52apCgfXwYak5MSjNbXBhieh8GGzg"  # Reemplaza con tu token

SMARTCITIZEN_URL = "https://api.smartcitizen.me/devices/18831"

def get_smartcitizen_info():
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
        temperature = sensors.get("Sensirion SHT31 - Temperature", "N/A")
        noise = sensors.get("ICS43432 - Noise", "N/A")
        light = sensors.get("BH1730FVC - Light", "N/A")
        humidity = sensors.get("Sensirion SHT31 - Humidity", "N/A")
        battery = sensors.get("Battery SCK", "N/A")

        info = (
            f"Kit: {kit_name}\n"
            f"Ciudad: {city}\n"
            f"Latitud: {latitude}, Longitud: {longitude}\n"
            f"Última Lectura: {last_reading_at}\n"
            f"Temperatura: {temperature} °C\n"
            f"Ruido: {noise} dB\n"
            f"Luz: {light} lux\n"
            f"Humedad: {humidity} %\n"
            f"Batería: {battery} %"
        )
        return info
    except Exception as e:
        return f"Error obteniendo datos: {e}"

def info_command(update: Update, context: CallbackContext):
    info = get_smartcitizen_info()
    update.message.reply_text(info)

def main():
    updater = Updater(TELEGRAM_TOKEN, use_context=True)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler("info", info_command))
    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()