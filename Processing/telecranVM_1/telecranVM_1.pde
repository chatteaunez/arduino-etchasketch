// positions of the knobs, in radians
float xKnob = 0;
float yKnob = 0;
float step = 0.1;

// saving the screen ration (calculated in full spins of the knobs)
PVector screenRatio = new PVector(5, 3.5);

PVector pointer = new PVector(0, 0);
PVector prevPointer = new PVector(0, 0);

boolean up, down, left, right;

boolean manualMode = false;

JSONArray json;
int timer;

PGraphics knob;

boolean stepMode = false;
float maxStepAngle = 0.2;
int stepDelay = 500;
int lastStepTime = 0;
PVector stepAngle = new PVector(0, 0);

void setup() {
  size(500, 350);
  background(#989686);
  frameRate(20);

  knob = createGraphics(40, 40);
  knob.beginDraw();
  knob.fill(255);
  knob.noStroke();
  knob.ellipse(20, 20, 40, 40);
  knob.fill(100);
  knob.ellipse(20, 10, 10, 10);
  knob.endDraw();

  if (!manualMode)json = loadJSONArray("test.json");
}

void draw() {
  if (manualMode)updateKnobs();
  else stepKnobs();

  pushMatrix();
  translate(0, height-1);

  pointer = radsToCoord(xKnob, yKnob);
  stroke(#000000);
  strokeWeight(1.2);
  line(pointer.x, -pointer.y, prevPointer.x, -prevPointer.y);
  prevPointer=pointer;

  popMatrix();

  imageMode(CENTER);
  pushMatrix();
  translate(30, height-30);
  rotate(xKnob);
  image(knob, 0, 0);
  popMatrix();
  pushMatrix();
  translate(width-30, height-30);
  rotate(yKnob);
  image(knob, 0, 0);
  popMatrix();
}

PVector radsToCoord(float xr, float yr) {
  float xRatio = (width / screenRatio.x) / TAU;
  float yRatio = (height / screenRatio.y) / TAU;

  PVector r = new PVector(xr*xRatio, yr*yRatio);
  return r;
}

void keyPressed() {
  if (keyCode==DOWN)up=true;
  if (keyCode==UP)down=true;
  if (keyCode==LEFT)left=true;
  if (keyCode==RIGHT)right=true;

  if (key==' ')background(#989686);
}

void keyReleased() {
  if (keyCode==DOWN)up=false;
  if (keyCode==UP)down=false;
  if (keyCode==LEFT)left=false;
  if (keyCode==RIGHT)right=false;
}

void updateKnobs() {
  if (up)yKnob-=step;
  if (down)yKnob+=step;
  if (left)xKnob-=step;
  if (right)xKnob+=step;

  if (xKnob<0)xKnob=0;
  if (yKnob<0)yKnob=0;
  if (xKnob>screenRatio.x*TAU)xKnob=screenRatio.x*TAU;
  if (yKnob>screenRatio.y*TAU)yKnob=screenRatio.y*TAU;
  println("horizontal knob: "+xKnob/TAU+"tau || vertical knob: "+yKnob/TAU+"tau");
}

void stepKnobs() {
  if (stepMode && millis()>lastStepTime+stepDelay) {
    while (stepAngle.x<maxStepAngle && stepAngle.y<maxStepAngle) {
      if (timer>0 && timer<json.size()) {
        JSONObject step = json.getJSONObject(timer);
        stepAngle.x+=step.getFloat("x");
        stepAngle.y+=step.getFloat("y");
        println("horizontal knob: "+xKnob/TAU+"tau || vertical knob: "+yKnob/TAU+"tau");
      }
      timer++;
    }
    lastStepTime = millis();
    if(stepAngle.x>maxStepAngle){
      xKnob+=maxStepAngle;
      stepAngle.x = 0;
    }
    if(stepAngle.y>maxStepAngle){
      yKnob+=maxStepAngle;
      stepAngle.y = 0;
    }
  } 
  else if(!stepMode){
    if (timer>0 && timer<json.size()) {
      JSONObject step = json.getJSONObject(timer);

      xKnob+=step.getFloat("x");
      yKnob+=step.getFloat("y");
      println("horizontal knob: "+xKnob/TAU+"tau || vertical knob: "+yKnob/TAU+"tau");
    }
    timer++;
  }
}