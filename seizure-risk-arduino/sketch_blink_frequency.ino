const byte blinkPin = 2;
const byte alarmSwitchPin = 4;
int blinkCount = 0;
unsigned long beginCountTime;
unsigned long endCountTime;
unsigned long blinkTime;
unsigned long freq;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(blinkPin,INPUT);
  pinMode(alarmSwitchPin,OUTPUT);
  attachInterrupt(digitalPinToInterrupt(blinkPin),incCounter,RISING);
  digitalWrite(alarmSwitchPin,LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  if((blinkCount > 0) && (blinkCount < 40)) {
    //do nothing
  }
  else if(blinkCount == 40) {
    noInterrupts();
    endCountTime = millis();
    blinkTime = endCountTime - beginCountTime;
    //Serial.println(" ");
    //Serial.println(blinkTime);
    freq = 40000/blinkTime;
    Serial.print("freq = ");
    Serial.println(freq);
    if((freq>=4) && (freq<=35)) {
      soundAlarm();
    }
    else {
      stopAlarm();
    }
    blinkCount = 0;
    interrupts();
  }
  else if(blinkCount == 0) {
    noInterrupts();
    beginCountTime = millis();
    interrupts();
  }
}

void incCounter() {
  blinkCount++;
  //Serial.print("RISE ");
}

void soundAlarm() {
  digitalWrite(alarmSwitchPin,HIGH);
}

void stopAlarm() {
  digitalWrite(alarmSwitchPin,LOW);
}
