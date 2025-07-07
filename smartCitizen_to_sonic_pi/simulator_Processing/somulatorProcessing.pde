import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress sonicPi;

float[] pm = {250, 350, 430, 460}; // pm_1, pm_2, pm_4, pm_10
float noise = 37;

float maxPM = 500;
float minNoise = 34;
float maxNoise = 80;

int selectedBar = -1;  // índice barra seleccionada

int barX[] = {50, 110, 170, 230};
int barWidth = 40;
int barCount = 4;

void setup() {
  size(400, 300);
  frameRate(30);
  textSize(16);

  oscP5 = new OscP5(this, 12000);
  sonicPi = new NetAddress("127.0.0.1", 4560);
}

void draw() {
  background(30);

  // Si no hay barra seleccionada, simula cambios suaves
  if (selectedBar == -1) {
    for (int i = 0; i < barCount; i++) {
      pm[i] += random(-5, 5);
      pm[i] = constrain(pm[i], 0, maxPM);
    }
    noise += random(-0.5, 0.5);
    noise = constrain(noise, minNoise, maxNoise);
  }

  // Dibuja barras
  for (int i = 0; i < barCount; i++) {
    fill(100 + i*40, 100, 255 - i*50, 200);
    float barHeight = map(pm[i], 0, maxPM, 0, height);
    rect(barX[i], height - barHeight, barWidth, barHeight);
    fill(255);
    text(nf(pm[i], 0, 1), barX[i], height - barHeight - 10);
  }

  // Barra para noise
  fill(180);
  float noiseHeight = map(noise - minNoise, 0, maxNoise - minNoise, 0, height);
  rect(290, height - noiseHeight, barWidth, noiseHeight);
  fill(255);
  text(nf(noise, 0, 1), 290, height - noiseHeight - 10);

  // Títulos
  fill(255);
  text("PM1.0", 60, height - 5);
  text("PM2.5", 120, height - 5);
  text("PM4.0", 180, height - 5);
  text("PM10", 240, height - 5);
  text("Noise", 300, height - 5);

  // Envía valores por OSC
  sendOSC("/pm_1_0", pm[0]);
  sendOSC("/pm_2_5", pm[1]);
  sendOSC("/pm_4_0", pm[2]);
  sendOSC("/pm_10_0", pm[3]);
  sendOSC("/noise", noise);
}

void mousePressed() {
  // Detecta si clicas dentro de alguna barra
  for (int i = 0; i < barCount; i++) {
    if (mouseX > barX[i] && mouseX < barX[i] + barWidth) {
      selectedBar = i;
      break;
    }
  }
  // Para noise barra
  if (mouseX > 290 && mouseX < 290 + barWidth) {
    selectedBar = 4; // 4 para noise
  }
}

void mouseDragged() {
  if (selectedBar >= 0 && selectedBar <= 3) {
    // Convierte la posición vertical del mouse a valor PM
    float val = map(height - mouseY, 0, height, 0, maxPM);
    pm[selectedBar] = constrain(val, 0, maxPM);
  } else if (selectedBar == 4) {
    float val = map(height - mouseY, 0, height, minNoise, maxNoise);
    noise = constrain(val, minNoise, maxNoise);
  }
}

void mouseReleased() {
  selectedBar = -1;
}

void sendOSC(String addr, float val) {
  OscMessage msg = new OscMessage(addr);
  msg.add(val);
  oscP5.send(msg, sonicPi);
}
