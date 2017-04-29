
int d = 2;


//left sensor signal pin assignments
int leftTrigPin = 3;
int leftEchoPin=10;

int rightTrigPin = 4;
int rightEchoPin = 9;

long durationLeft;
int distanceLeft;

long durationRight;
int distanceRight;


void setup() {
  // right motor pin assignments

  //forward 
  pinMode(7,OUTPUT);
  //reverse
  pinMode(8,OUTPUT);
  //right side pwm
  pinMode(5,OUTPUT);

  //left motor pin assignments

  //forward
  pinMode(12,OUTPUT);
  //reverse
  pinMode(13,OUTPUT);
  //left side pwm
  pinMode(6,OUTPUT);

  //Switch
  pinMode(14,INPUT);

  
  pinMode(rightTrigPin,OUTPUT);
  pinMode(rightEchoPin,INPUT);

  pinMode(leftTrigPin,OUTPUT);
  pinMode(leftEchoPin,INPUT);
  
  
    Serial.begin(9600);


}

void loop() {
  // put your main code here, to run repeatedly:

  d = digitalRead(14);

if(d==0){


  digitalWrite(rightTrigPin,LOW);
  digitalWrite(leftTrigPin,LOW);
  delayMicroseconds(5);

  digitalWrite(rightTrigPin,HIGH);
  delayMicroseconds(10);
  digitalWrite(rightTrigPin,LOW);
  durationRight = pulseIn(rightEchoPin,HIGH);
  distanceRight = durationRight * 0.034029/2;

  Serial.print("DistanceRight: ");
  Serial.println(distanceRight);

  digitalWrite(leftTrigPin,HIGH);
  delayMicroseconds(10);
  digitalWrite(leftTrigPin,LOW);
  durationLeft = pulseIn(leftEchoPin,HIGH);
  distanceLeft = durationLeft * 0.034029/2;

   
   
  Serial.print("DistanceLeft: ");
  Serial.println(distanceLeft);

if((distanceLeft > 30) && (distanceRight > 30)){

  
digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,220);
analogWrite(5,220);
  
  
  }else if((distanceLeft < 20) && (distanceRight < 20)){

  
digitalWrite(8,HIGH);
digitalWrite(7,LOW);
digitalWrite(13,HIGH);
digitalWrite(12,LOW);

analogWrite(6,150);
analogWrite(5,150);
  
  
  }else if( ((distanceLeft < 30) && (distanceLeft > 20)) && ((distanceRight < 30) && (distanceRight > 20)) ){

  
digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,HIGH);
digitalWrite(12,LOW);

analogWrite(6,0);
analogWrite(5,0);
  
  
  }





} else{

  analogWrite(5,0);
  analogWrite(6,0);

  
  
  }





}
