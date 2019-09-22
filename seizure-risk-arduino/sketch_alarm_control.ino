const byte alarmSwitchPin = 2;
const byte alarmPin = 7;
int val = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(alarmSwitchPin,INPUT);
  pinMode(alarmPin,OUTPUT);
  digitalWrite(alarmSwitchPin,LOW);

}

void loop() {
  // put your main code here, to run repeatedly:
  val = digitalRead(alarmSwitchPin);
  if(val == HIGH) {
    //play alarm tone here
    tone(alarmPin,500,500);
    delay(500);
  }
  noTone(alarmPin);
  delay(1000);
}

