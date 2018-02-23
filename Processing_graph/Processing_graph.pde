import oscP5.*;
import netP5.*;
OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

Graph MyArduinoGraph = new Graph(150, 80, 500, 300, color (200, 20, 20));
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

float[][] gesturePoints = new float[4][2];
float[] gestureDist = new float[4];
String[] names = {"Nothing", "Touch", "Grab", "In water"};
void setup() {

  size(1000, 500); 

  MyArduinoGraph.xLabel="Readnumber";
  MyArduinoGraph.yLabel="Amp";
  MyArduinoGraph.Title=" Graph";  
  noLoop();
  PortSelected=7;      /* ====================================================================
   adjust this (0,1,2...) until the correct port is selected 
   In my case 2 for COM4, after I look at the Serial.list() string 
   println( Serial.list() );
   [0] "COM1"  
   [1] "COM2" 
   [2] "COM4"
   ==================================================================== */
  SerialPortSetup();      // speed of 115200 bps etc.

  // OSC
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this, 6969);

  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */

  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("127.0.0.1", 6448);
}


void draw() {

  background(255);

  /* ====================================================================
   Print the graph
   ====================================================================  */

  if ( DataRecieved3 ) {
    pushMatrix();
    pushStyle();
    MyArduinoGraph.yMax=1000;      
    MyArduinoGraph.yMin=-200;      
    MyArduinoGraph.xMax=int (max(Time3));
    MyArduinoGraph.DrawAxis();    
    MyArduinoGraph.smoothLine(Time3, Voltage3);
    popStyle();
    popMatrix();

    float gestureOneDiff =0;
    float gestureTwoDiff =0;
    float gestureThreeDiff =0;

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    float totalDist = 0;
    int currentMax = 0;
    float currentMaxValue = -1;
    for (int i = 0; i < 4; i++)

    {

      //  gesturePoints[i][0] = 
      if (mousePressed && mouseX > 750 && mouseX<800 && mouseY > 100*(i+1) && mouseY < 100*(i+1) + 50)
      {
        fill(255, 0, 0);

        gesturePoints[i][0] = Time3[MyArduinoGraph.maxI];
        gesturePoints[i][1] = Voltage3[MyArduinoGraph.maxI];
      } else
      {
        fill(255, 255, 255);
      }

      //calucalte individual dist
      gestureDist[i] = dist(Time3[MyArduinoGraph.maxI], Voltage3[MyArduinoGraph.maxI], gesturePoints[i][0], gesturePoints[i][1]);
      totalDist = totalDist + gestureDist[i];
      if (gestureDist[i] < currentMaxValue || i == 0)
      {
        currentMax = i;
        currentMaxValue =  gestureDist[i];
      }
    }
    totalDist=totalDist /3;

    for (int i = 0; i < 4; i++)
    {
      float currentAmmount = 0;
      currentAmmount = 1-gestureDist[i]/totalDist;
      if (currentMax == i)
      {
        fill(0, 0, 0);
        //       text(names[i],50,450);
        fill(currentAmmount*255.0f, 0, 0);
      } else
      {
        fill(255, 255, 255);
      }

      stroke(0, 0, 0);
      rect(750, 100 * (i+1), 50, 50);
      fill(0, 0, 0);
      textSize(30);
      text(names[i], 810, 100 * (i+1)+25);

      fill(255, 0, 0);
      //   rect(800,100* (i+1), max(0,currentAmmount*50),50);
    }


    // OSC
//delay(500);
    /* create a new OscMessage with an address pattern, in this case /test. */
    OscMessage myOscMessage = new OscMessage("/wek/inputs");
    /* add a value (an integer) to the OscMessage */
    for(int i=0;i<Voltage3.length;i=i+2){
          myOscMessage.add(Voltage3[i]);
    }
    /* send the OscMessage to a remote location specified in myNetAddress */
    oscP5.send(myOscMessage, myBroadcastLocation);
  }
}

void stop()
{

  myPort.stop();
  super.stop();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
}