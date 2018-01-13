// The purpose of this sketch is to load a set of coordinates (created in the ScriptSaver sketch),
// run through it and move the motors accordingly using arduino.
//
// copyLeft: leo catonnet

import processing.serial.*;

float stepAngle = 0.048; // angle in rad corresponding to a step of the motor
PVector stepBuffer = new PVector(0,0); // steps the motor has to execute
PVector knobPos = new PVector(0,0); // current angle of the virtual knob
PVector knobBuffer = new PVector(0,0); // delta angle in radiant waiting to be converted to steps

// delay between steps
int stepDelay = 60;
int lastStepTime;

boolean playing = false;
 
// The serial port:
Serial myPort;

PVector screenRatio = new PVector(5, 3.5); // stores the screen ratio (calculated in full spins of the knobs)

// current and last position of the pointer on the pixel matrix
PVector pointer = new PVector(0, 0);
PVector prevPointer = new PVector(0, 0);

JSONArray json; // our programmed coordinate (expressed in radian)
int index; // where are we in the array

PGraphics knob; // knob image

void setup() {
  size(500, 350);
  background(#989686);
  
  // creating the knob's visual
  knob = createGraphics(40, 40);
  knob.beginDraw();
  knob.fill(255);
  knob.noStroke();
  knob.ellipse(20, 20, 40, 40);
  knob.fill(100);
  knob.ellipse(20, 10, 10, 10);
  knob.endDraw();
  
  // loading the coordinates from file
  json = loadJSONArray("test.json");
  
  // list all the available serial ports:
  printArray(Serial.list());
  // open the port 
  myPort = new Serial(this, Serial.list()[1], 9600);
}

void draw(){
  if(playing){
    
    // if our steps are all done create new ones
    if(stepBuffer.x==0 && stepBuffer.y==0){
     createSteps(); 
    }
    
    // send a step to each motor
    if (millis()>lastStepTime+stepDelay) {
      playSteps();
      lastStepTime = millis();
    }
    
    // show me the steps left
    println("stepBuffer.x="+stepBuffer.x+" // stepBuffer.y="+stepBuffer.y);
  }
  
  //draw knobs
  imageMode(CENTER);
  pushMatrix();
  translate(30, height-30);
  rotate(knobPos.x);
  image(knob, 0, 0);
  popMatrix();
  pushMatrix();
  translate(width-30, height-30);
  rotate(knobPos.y);
  image(knob, 0, 0);
  popMatrix();
}



void createSteps(){
  
  // get the next set of coordinates
  if (index>0 && index<json.size()) {
    JSONObject fileStep = json.getJSONObject(index);
    knobBuffer.x+=fileStep.getFloat("x");
    knobBuffer.y+=fileStep.getFloat("y");
  } 
  index++;
  
  // if the delta angle is greater that our step, transfer it to the stepBuffer
  if(abs(knobBuffer.x)>stepAngle){
   stepBuffer.x += int(knobBuffer.x/stepAngle);
   knobBuffer.x-=stepAngle*stepBuffer.x;
  }
  if(abs(knobBuffer.y)>stepAngle){
   stepBuffer.y += int(knobBuffer.y/stepAngle);
   knobBuffer.y-=stepAngle*stepBuffer.y;
  }
  
  
}

// this function empties the stepBuffer and send the info to the Arduino
// it also add the angle to the knob position to render on the virtual machine
void playSteps(){
   if(stepBuffer.x>0){
     knobPos.x+=stepAngle;
     stepBuffer.x--;
     myPort.write("R");
   }
   if(stepBuffer.x<0){
     knobPos.x-=stepAngle;
     stepBuffer.x++;
     myPort.write("L");
   } 
   if(stepBuffer.y>0){
     knobPos.y+=stepAngle;
     stepBuffer.y--;
     myPort.write("U");
   }
   if(stepBuffer.y<0){
     knobPos.y -=stepAngle;
     stepBuffer.y++;
     myPort.write("D");
   } 
   renderStep();
}

// this function trace the theorical path of the pointer on the virtual machine
void renderStep(){
  pushMatrix();
  translate(0, height-1);
  pointer = radsToCoord(knobPos.x, knobPos.y);
  stroke(#000000);
  strokeWeight(1.2);
  line(pointer.x, -pointer.y, prevPointer.x, -prevPointer.y);
  prevPointer=pointer;
  popMatrix();
}

// this mini function convert the angle of the knob into pixel coordinates
PVector radsToCoord(float xr, float yr) {
  float xRatio = (width / screenRatio.x) / TAU;
  float yRatio = (height / screenRatio.y) / TAU;

  PVector r = new PVector(xr*xRatio, yr*yRatio);
  return r;
}

void keyPressed(){
  
  // these allow to manually control the motors
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
  
  // this comman return the motors to their starting points
  if(key=='o'||key=='O')myPort.write("O"); 
  
  // toggle the "playing" state
  if(key==' '){
    playing=!playing;
    println("playing state = "+playing);
  }
  
  // full reset of the drawing
  if(key=='r'||key=='R'){
    myPort.write("O");
    playing=false;
    index=0;
    stepBuffer.x= 0;
    stepBuffer.y= 0;
    knobPos.x = 0;
    knobPos.y = 0;
    knobBuffer.x = 0;
    knobBuffer.y = 0; 
    background(#989686);
  }
}