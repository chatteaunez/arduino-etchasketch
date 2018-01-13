#include <Stepper.h>
const int stepValue = 16; // define the step unit

Stepper x(stepValue, 4,6,5,7);   // first stepper controls the x axis
Stepper y(stepValue, 8,10,9,11); // second stepper controls the y axis

// counters allow to reset the motor to their original positions
int xStepCount = 0;
int yStepCount = 0;

int command; // the received command is stored here

void setup() {
  // initiate communication with the port
  Serial.begin(9600);

  // set the speed of the motor
  // (this is the RPM of the inner motor, the output shaft will move a lot slower)
  x.setSpeed(1500);
  y.setSpeed(1500);
}

void loop() {
  
  if (Serial.available() > 0) {
    // read the incoming byte:
    command = Serial.read();
  
    // show me what you got:
    Serial.print("I received: ");
    Serial.println(command);
    
    switch(command){
     case 85:
      y.step(stepValue);  //UP
      yStepCount++;
      break;
     case 68:
      y.step(-stepValue); //DOWN
      yStepCount--;
      break;
     case 76:
      x.step(-stepValue); //LEFT
      xStepCount--;
      break;
     case 82:
      x.step(stepValue);  //RIGHT
      xStepCount++;
      break;
     case 79:
      // return to origin
      x.step(-xStepCount*stepValue);
      y.step(-yStepCount*stepValue);
      xStepCount = 0;
      yStepCount = 0;
      break;
    }   
  }
}
