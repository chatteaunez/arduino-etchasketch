import processing.serial.*;

// The serial port:
Serial myPort;

void setup(){
// List all the available serial ports:
printArray(Serial.list());

// Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 9600);
}

void draw(){

}

void keyPressed(){
  switch(keyCode){
     case UP:
       myPort.write("U");
       break;
     case DOWN:
       myPort.write("D");
       break;
     case LEFT:
       myPort.write("L");
       break;
     case RIGHT:
       myPort.write("R");
       break;
  }
  
  if(key=='o'||key=='O')myPort.write("O");
}