#define NUMDELAY 6
#define NUMPWM   6

// analog read pins for delay detection
unsigned int inPins[NUMDELAY] = {A0,A1,A2,A3,A4,A5};

// delay -> pwm
unsigned int outPins[NUMDELAY+NUMPWM] = {2,4,7,8,12,13, 3,5,6,9,10,11};
unsigned int pinDelays[NUMDELAY+NUMPWM] = {2000,2000,2000,2000,2000,2000, 15,15,15,15,15,15,};

// delay -> pwm
int currentState[NUMDELAY+NUMPWM] = {0,0,0,0,0,0,  0,0,0,0,0,0};
unsigned long nextUpdate[NUMDELAY+NUMPWM] = {0,0,0,0,0,0,   0,0,0,0,0,0};

byte i = 0;
byte j = 0;

int readState = 0;
int toPin = 0;

void setup() {                
  // initialize pins
  for(i=0; i<(NUMDELAY+NUMPWM); i++) {
    pinMode(outPins[i], OUTPUT);
  }

  for(i=0; i<(NUMDELAY+NUMPWM); i++) {
    digitalWrite(outPins[i], LOW);
  }
}


void loop() {

  // read input switches to see if state has to change on the delayed lights
  for(i=0; i<NUMDELAY; i++) {
    readState = analogRead(inPins[i]);
    if(readState > 500)
      readState = HIGH;
    else
      readState = LOW;

    // if currentState and switch differ, and there's nothing scheduled
    if((readState != currentState[i]) && (nextUpdate[i] == 0)) {
      // schedule an update
      nextUpdate[i] = millis() + pinDelays[i];
    }
    // if we scheduled something before
    // but light went back to current state before switching
    else if((readState == currentState[i]) && (nextUpdate[i] != 0)) {
      nextUpdate[i] = 0;      
    }
  }

  // update the delayed outputs
  for(i=0; i<NUMDELAY; i++) {
    // if there's something schedule and we passed that time
    if((nextUpdate[i] != 0) && (millis() > nextUpdate[i])) {
      // update the pin
      currentState[i] = !(currentState[i]);
      // no more updates scheduled
      nextUpdate[i] = 0;
      //update pin
      digitalWrite(outPins[i], currentState[i]);
    } 
  }

  // update the PWM pins
  j = NUMDELAY;
  for(i=0; i<NUMPWM; i++) {
    // if it's time to update
    if(millis() > nextUpdate[j+i]){
      // schedule next update
      nextUpdate[j+i] = millis() + pinDelays[j+i];
      // update the current state
      currentState[j+i] += 1;
      // check if it's time to change directions
      if(currentState[j+i] == 320) {
        currentState[j+i] = -320;
      }

      // write to pin
      toPin = abs(currentState[j+i]);
      if(toPin > 255)
        toPin = 255;

      analogWrite(outPins[j+i], toPin);
    }
  }

}


