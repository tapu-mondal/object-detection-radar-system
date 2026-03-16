#include <Servo.h>

Servo myServo;

#define trigPin 9
#define echoPin 10
#define servoPin 3
#define buzzerPin 6

int angle = 0;
int stepAngle = 2;

// ---------------------------
// Distance Function
// ---------------------------
long getDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);

  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 30000);  
  if (duration == 0) return 500;  // No object

  long distance = duration * 0.034 / 2;
  return distance;
}

// ---------------------------
// Setup
// ---------------------------
void setup() {
  Serial.begin(9600);

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);

  myServo.attach(servoPin);
}

// ---------------------------
// Loop
// ---------------------------
void loop() {

  long d = getDistance();

  // >>> Serial output for Processing Radar <<<
  Serial.print(angle);
  Serial.print(",");
  Serial.print(d);
  Serial.println(".");

  // >>> Passive Buzzer Sound <<<
  if (d <= 50) tone(buzzerPin, 1000);  // constant tone for passive buzzer
  else noTone(buzzerPin);

  // >>> Servo Sweep <<<
  myServo.write(angle);
  angle += stepAngle;

  if (angle >= 180 || angle <= 0) {
    stepAngle = -stepAngle;
  }

  delay(35);
}
