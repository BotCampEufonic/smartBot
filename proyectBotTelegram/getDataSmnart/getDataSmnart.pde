import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;

// Mapa interactivo
UnfoldingMap map;

// Información del kit
float latitude = 0;
float longitude = 0;
String city = "Desconocida";
String kitName = "Desconocido";
String lastReadingAt = "Desconocida";
float temperature = 0;
float noise = 0;
float light = 0;
float humidity = 0;
float battery = 0;  // Variable para almacenar el nivel de batería

void setup() {
  size(1920, 1080, P2D);
  smooth();

  // Inicializar oscP5 y configurar la dirección remota (IP y puerto del primer sketch)
  oscP5 = new OscP5(this, 12001);
  remoteLocation = new NetAddress("127.0.0.1", 12000);
  
  // Inicializar mapa
  map = new UnfoldingMap(this, new Microsoft.HybridProvider());
  MapUtils.createDefaultEventDispatcher(this, map);
  map.setTweening(true);

  // Cargar datos del kit SmartCitizen
  loadData();
}

void draw() {
  // Dibujar el mapa
  map.draw();

  // Mostrar información sobre la ubicación y los sensores
  fill(0, 150);
  rect(10, 10, width - 20, 220, 10);

  fill(255);
  textSize(16);
  textAlign(LEFT, CENTER);
  
  // Aumentar tamaño de la fuente para el nombre del kit y la batería
  textSize(20); // Tamaño grande para el nombre y la batería
  fill(255);  // Nombre del kit en color blanco
  text("Kit: " + kitName, 20, 30);
  
  // Mostrar el nivel de batería en color rojo si es menor al 50%
  String batteryText = "Batería: " + nf(battery, 1, 2) + " %";
  if (battery < 50) {
    fill(255, 0, 0);  // Rojo si la batería es menor al 50%
  } else {
    fill(0, 0, 255);  // Azul si la batería es mayor al 50%
  }
  text(batteryText, width - 20 - 150, 30); // Ajustar la posición de la batería a la derecha

  // Cambiar tamaño de la fuente para el resto de la información
  textSize(16);  // Tamaño más pequeño para los otros datos
  
  // Mostrar el resto de la información
  fill(255);
  textAlign(LEFT, CENTER);
  text("Ciudad: " + city, 20, 50);
  text("Latitud: " + nf(latitude, 1, 5) + ", Longitud: " + nf(longitude, 1, 5), 20, 70);
  text("Última Lectura: " + lastReadingAt, 20, 90);
  text("Temperatura: " + nf(temperature, 1, 2) + " °C", 20, 110);
  text("Ruido: " + nf(noise, 1, 2) + " dB", 20, 130);  // Mostrar el nivel de ruido
  text("Luz: " + nf(light, 1, 2) + " lux", 20, 150);   // Mostrar el nivel de luz
  text("Humedad: " + nf(humidity, 1, 2) + " %", 20, 170); // Mostrar el nivel de humedad

  // Dibujar marcador en la ubicación del kit
  Location kitLocation = new Location(latitude, longitude);
  ScreenPosition pos = map.getScreenPosition(kitLocation);
  fill(255, 50, 50, 200);
  noStroke();
  ellipse(pos.x, pos.y, 20, 20);
}

void loadData() {
  try {
    // Cargar datos desde la API de SmartCitizen
    JSONObject deviceData = loadJSONObject("https://api.smartcitizen.me/devices/18831");

    // Extraer información de ubicación y sensores
    JSONObject location = deviceData.getJSONObject("location");
    latitude = location.getFloat("latitude");
    longitude = location.getFloat("longitude");
    city = location.getString("city");
    
    // Extraer el nombre del kit
    kitName = deviceData.getString("name");

    // Extraer la fecha y hora de la última lectura
    lastReadingAt = deviceData.getString("last_reading_at");
    println("last_reading_at: " + lastReadingAt);

    // Extraer datos de sensores
    JSONObject data = deviceData.getJSONObject("data");
    JSONArray sensors = data.getJSONArray("sensors");

    for (int i = 0; i < sensors.size(); i++) {
      JSONObject sensor = sensors.getJSONObject(i);
      String description = sensor.getString("name");

      switch (description) {
        case "Sensirion SHT31 - Temperature":
          temperature = sensor.getFloat("value");
          break;
        case "ICS43432 - Noise":
          noise = sensor.getFloat("value");
          break;
        case "BH1730FVC - Light":
          light = sensor.getFloat("value");
          break;
        case "Sensirion SHT31 - Humidity":
          humidity = sensor.getFloat("value");
          break;
        case "Battery SCK":
          battery = sensor.getFloat("value");
          break;
      }
    }

    // Centrar y acercar el mapa a la ubicación del sensor
    map.zoomAndPanTo(13, new Location(latitude, longitude));

    // Enviar `last_reading_at` por OSC
    OscMessage msg = new OscMessage("/lastReadingAt");
    msg.add(lastReadingAt);
    oscP5.send(msg, remoteLocation);

  } catch (Exception e) {
    println("Error al cargar los datos: " + e.getMessage());
  }
}

// Recibir mensajes OSC del primer sketch
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/info")) {
    String chatId = theOscMessage.get(0).stringValue();
    String infoMessage = "Kit: " + kitName + "\n" +
                         "Ciudad: " + city + "\n" +
                         "Latitud: " + nf(latitude, 1, 5) + ", Longitud: " + nf(longitude, 1, 5) + "\n" +
                         "Última Lectura: " + lastReadingAt + "\n" +
                         "Temperatura: " + nf(temperature, 1, 2) + " °C\n" +
                         "Ruido: " + nf(noise, 1, 2) + " dB\n" +
                         "Luz: " + nf(light, 1, 2) + " lux\n" +
                         "Humedad: " + nf(humidity, 1, 2) + " %\n" +
                         "Batería: " + nf(battery, 1, 2) + " %";
    // Enviar mensaje OSC de respuesta al primer sketch
    OscMessage msg = new OscMessage("/infoResponse");
    msg.add(chatId);
    msg.add(infoMessage);
    oscP5.send(msg, remoteLocation);
  }
}
