import http.requests.*;
import oscP5.*;
import netP5.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
//String apiUrl = "https://api.telegram.org/bot7747284015:AAFhUe52apCgfXwYak5MSjNbXBhieh8GGzg"
String apiUrl = "https://api.telegram.org/bot7980483937:AAHUBgSNxiRrDNMTLNFppktwbeMkcLIJhHk";
int lastUpdateId = 0;
OscP5 oscP5;
NetAddress remoteLocation;

void setup() {
  size(400, 400);
  fill(0);
  textSize(16);
  
  // Inicializar oscP5 y configurar la dirección remota (IP y puerto del segundo sketch)
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress("127.0.0.1", 12001);
}

void draw() {
  background(255);
  checkForUpdates();
}

void checkForUpdates() {
  GetRequest get = new GetRequest(apiUrl + "/getUpdates?offset=" + lastUpdateId);
  get.send();
  String response = get.getContent();
  
  JSONObject json = parseJSONObject(response);
  JSONArray result = json.getJSONArray("result");
  
  for (int i = 0; i < result.size(); i++) {
    JSONObject update = result.getJSONObject(i);
    lastUpdateId = update.getInt("update_id") + 1;
    
    if (update.hasKey("message")) {
      JSONObject message = update.getJSONObject("message");
      String chatId = String.valueOf(message.getJSONObject("chat").getInt("id"));
      String text = message.getString("text");
      
      if (text.equals("/info")) {
        // Enviar mensaje OSC al segundo sketch
        OscMessage msg = new OscMessage("/info");
        msg.add(chatId);  // Añadir el chatId al mensaje OSC
        oscP5.send(msg, remoteLocation);
      }
      if (text.equals("/hola")) {
        println("hola");
      }
    }
  }
}

void sendMessage(String chatId, String text) {
  PostRequest post = new PostRequest(apiUrl + "/sendMessage");
  post.addData("chat_id", chatId);
  post.addData("text", text);
  post.send();
}

// Recibir mensajes OSC de respuesta del segundo sketch
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/infoResponse")) {
    String chatId = theOscMessage.get(0).stringValue();
    String infoMessage = theOscMessage.get(1).stringValue();
    sendMessage(chatId, infoMessage);
  }
}
