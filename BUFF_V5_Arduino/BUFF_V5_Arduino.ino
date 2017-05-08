
#include <Servo.h>
#include <Wire.h> //I2C Arduino Library
#include <SoftwareSerial.h>

SoftwareSerial mySerial(2, 11); // RX, TX  
// Connect HM10      Arduino Uno
//     Pin 1/TXD          Pin 2
//     Pin 2/RXD          Pin 11

#define address 0x1E //0011110b, I2C 7bit address of HMC5883
Servo servoMain; // Define our Servo
int d = 2;

float finalHead = -1000;

float heading2son = 1000;

String dataFromPhone="";

String phoneHeadingArray[10];
String phoneSpeedArray[10];
String phoneStatus = "";





//left sensor signal pin assignments
int leftTrigPin = 3;
int leftEchoPin=10;

int rightTrigPin = 4;
int rightEchoPin = 9;

long durationLeft;
int distanceLeft;

long durationRight;
int distanceRight;


    int x,y,z; //triple axis data



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
  

   servoMain.attach(15); // servo on digital pin 15
   servoMain.write(90);
  
    Serial.begin(9600);
      mySerial.begin(9600);
      Wire.begin();

    //Put the HMC5883 IC into the correct operating mode
  Wire.beginTransmission(address); //open communication with HMC5883
  Wire.write(0x02); //select mode register
  Wire.write(0x00); //continuous measurement mode
  Wire.endTransmission();



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

  //Serial.print("DistanceRight: ");
  //Serial.println(distanceRight);

  digitalWrite(leftTrigPin,HIGH);
  delayMicroseconds(10);
  digitalWrite(leftTrigPin,LOW);
  durationLeft = pulseIn(leftEchoPin,HIGH);
  distanceLeft = durationLeft * 0.034029/2;
   
   
  //Serial.print("DistanceLeft: ");
  //Serial.println(distanceLeft);



    String asd = mySerial.readStringUntil('%');
    int firstDelimIndex = asd.indexOf('_');
    int lastDelimIndex = asd.indexOf('&');
    String phoneHeading = asd.substring(0,firstDelimIndex);
    String phoneSpeed = asd.substring(firstDelimIndex+1,lastDelimIndex);
    phoneStatus = asd.substring(lastDelimIndex+1,asd.length());

   Serial.println(phoneHeading);
   Serial.println(phoneSpeed);
   Serial.println(phoneStatus);
   

      if((phoneHeadingArray[9] != NULL) && (phoneSpeedArray[9] != NULL)){

        //KIÇA EKLE KAYDIR
        for(int j = 1; j<10;j++){

          phoneHeadingArray[j-1] = phoneHeading[j];
          phoneSpeedArray[j-1] = phoneSpeed[j];
            
          }

          phoneHeadingArray[9] = phoneHeading;
          phoneSpeedArray[9] = phoneSpeed;
        
      
      }else{

      for(int i = 0; i<10;i++){
        
        if((phoneHeadingArray[i] == NULL) && (phoneSpeedArray[i] == NULL)){
      
          phoneHeadingArray[i]=phoneHeading;
          phoneSpeedArray[i]=phoneSpeed;

        
        }

      }
    
      }

  

//düz takip
if((distanceRight>30) && (distanceLeft>30) && (servoMain.read() == 90)){

mySerial.write("Following User");

  finalHead = -1000;
heading2son = 1000;

digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,180);
analogWrite(5,180);

    //obstacle'ı takip ediyor
    }else if((distanceRight<30) && (distanceLeft>30) && (servoMain.read() == 0)){

mySerial.write("Avoiding Obstacle");


      digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,180);
analogWrite(5,180);
      
      //sola dön
      }else if((distanceRight>60) && (distanceLeft<30) && (servoMain.read()==90)){

        mySerial.write("Following User");

            digitalWrite(8,LOW);
            digitalWrite(7,HIGH);
            digitalWrite(13,LOW);
            digitalWrite(12,HIGH);

            analogWrite(6,0);
            analogWrite(5,180);
      
      
      //sağa dön
      }else if((distanceRight<30) && (distanceLeft>60) && (servoMain.read()==90)){

        mySerial.write("Following User");
      
            digitalWrite(8,LOW);
            digitalWrite(7,HIGH);
            digitalWrite(13,LOW);
            digitalWrite(12,HIGH);

            analogWrite(6,180);
            analogWrite(5,0);
      
      //obstacle atlatıldı
      }else if((distanceLeft > 30) && (distanceRight > 30) && (servoMain.read() == 0)){

mySerial.write("Avoided Obstacle");

  finalHead = -1000;
heading2son = 1000;

digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,180);
analogWrite(5,180);

delay(500);

analogWrite(6,0);
analogWrite(5,0);

  
  //Tell the HMC5883 where to begin reading data
  Wire.beginTransmission(address);
  Wire.write(0x03); //select register 3, X MSB register
  Wire.endTransmission();
  
 
 //Read data from each axis, 2 registers per axis
  Wire.requestFrom(address, 6);
  if(6<=Wire.available()){
    x = Wire.read()<<8; //X msb
    x |= Wire.read(); //X lsb
    z = Wire.read()<<8; //Z msb
    z |= Wire.read(); //Z lsb
    y = Wire.read()<<8; //Y msb
    y |= Wire.read(); //Y lsb
  }

  float initHead=atan2(x, y)/0.0174532925;
  if(initHead < 0) initHead+=360;
  initHead=360-initHead; // N=0/360, E=90, S=180, W=270

    initHead = initHead + 90;  // *DÖNÜŞ İÇİN
  if(initHead < 0){
    initHead += 360;
    }                             // *DÖNÜŞ İÇİN

    Serial.println("Heading ilk: ");
    Serial.println(initHead);

  while(finalHead < initHead){
    
digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,180);
analogWrite(5,0);

  //Tell the HMC5883 where to begin reading data
  Wire.beginTransmission(address);
  Wire.write(0x03); //select register 3, X MSB register
  Wire.endTransmission();
  
 
 //Read data from each axis, 2 registers per axis
  Wire.requestFrom(address, 6);
  if(6<=Wire.available()){
    x = Wire.read()<<8; //X msb
    x |= Wire.read(); //X lsb
    z = Wire.read()<<8; //Z msb
    z |= Wire.read(); //Z lsb
    y = Wire.read()<<8; //Y msb
    y |= Wire.read(); //Y lsb
  }

  finalHead=atan2(x, y)/0.0174532925;
  if(finalHead < 0) finalHead+=360;
  finalHead=360-finalHead; // N=0/360, E=90, S=180, W=270

    Serial.println("Heading son: ");
    Serial.println(finalHead);
    
    }

    servoMain.write(90);
    analogWrite(6,0);
 analogWrite(5,0); 
 delay(2000);

  
      //adam durdu
      }else if ((distanceRight<30) && (distanceRight > 20) && (distanceLeft<30) && (distanceRight>20) && (phoneStatus.equals("stopped"))){

      mySerial.write("BUFF stopped w/ user");
      
 servoMain.write(90);
 analogWrite(6,0);
 analogWrite(5,0); 
      
      
      }else if ((distanceRight<30) && (distanceRight > 20) && (distanceLeft<30) && (distanceRight>20) && (phoneStatus.equals("moving"))){

mySerial.write("Encountered Obstacle");


  //Tell the HMC5883 where to begin reading data
  Wire.beginTransmission(address);
  Wire.write(0x03); //select register 3, X MSB register
  Wire.endTransmission();
  
 
 //Read data from each axis, 2 registers per axis
  Wire.requestFrom(address, 6);
  if(6<=Wire.available()){
    x = Wire.read()<<8; //X msb
    x |= Wire.read(); //X lsb
    z = Wire.read()<<8; //Z msb
    z |= Wire.read(); //Z lsb
    y = Wire.read()<<8; //Y msb
    y |= Wire.read(); //Y lsb
  }

  float heading2ilk=atan2(x, y)/0.0174532925;
  if(heading2ilk < 0) heading2ilk+=360;
  heading2ilk=360-heading2ilk; // N=0/360, E=90, S=180, W=270

  heading2ilk = heading2ilk - 90;  // *DÖNÜŞ İÇİN
  if(heading2ilk < 0){
    heading2ilk += 360;
    }                             // *DÖNÜŞ İÇİN

  Serial.println("Heading ilk: ");
  Serial.println(heading2ilk);

 while(heading2son > heading2ilk){
    
digitalWrite(8,LOW);
digitalWrite(7,HIGH);
digitalWrite(13,LOW);
digitalWrite(12,HIGH);

analogWrite(6,0);
analogWrite(5,180);

  //Tell the HMC5883 where to begin reading data
  Wire.beginTransmission(address);
  Wire.write(0x03); //select register 3, X MSB register
  Wire.endTransmission();
  
 
 //Read data from each axis, 2 registers per axis
  Wire.requestFrom(address, 6);
  if(6<=Wire.available()){
    x = Wire.read()<<8; //X msb
    x |= Wire.read(); //X lsb
    z = Wire.read()<<8; //Z msb
    z |= Wire.read(); //Z lsb
    y = Wire.read()<<8; //Y msb
    y |= Wire.read(); //Y lsb
  }

  heading2son=atan2(x, y)/0.0174532925;
  if(heading2son < 0) heading2son+=360;
  heading2son=360-heading2son; // N=0/360, E=90, S=180, W=270

  Serial.println("Heading son: ");
  Serial.println(heading2son);
    
    }
     
 servoMain.write(0);
 analogWrite(6,0);
 analogWrite(5,0); 
 delay(2000);
   
      }else if((distanceRight<20) && (distanceLeft<20)){

        mySerial.write("Following User");

digitalWrite(8,HIGH);
digitalWrite(7,LOW);
digitalWrite(13,HIGH);
digitalWrite(12,LOW);

        
 analogWrite(6,150);
 analogWrite(5,150);
        
        }



  
  }else{
    analogWrite(6,0);
    analogWrite(5,0); 
    
    }
  }



