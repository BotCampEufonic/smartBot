/**
 * oscP5message by andreas schlegel
 * example shows how to create osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5("192.168.122.204",4560);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.122.24",4560);
}


void draw() {
  background(0);  
}

void mousePressed() {
  println("enviando");
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/pm1");
  
  myMessage.add(int(random(0,255))); /* add an int to the osc message */


  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message.hola");
  println(" nombre de mensaje: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
   theOscMessage.print();
}
