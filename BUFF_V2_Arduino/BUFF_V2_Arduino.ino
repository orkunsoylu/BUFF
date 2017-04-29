 
#include <SoftwareSerial.h>
#include <SimpleTimer.h>



//left sensor signal pin assignments
int leftTrigPin = 3;
int leftEchoPin=10;

int rightTrigPin = 4;
int rightEchoPin = 9;

long durationLeft;
int distanceLeft;

long durationRight;
int distanceRight;

int d=2;




SoftwareSerial BTserial(2, 11);
SimpleTimer timer;
 
char c = ' ';
String tmp= " ";
String asd = "";
//MAJOR
String distance = "";
//MINOR
String heading = "";
int dataIndex = 0;
String phoneUUID = "E253829193599384D58D5020F77905CB"; 
String oldHeading = "";
String oldDistance = "";

// a function to be executed periodically
void repeatMe() {
   BTserial.write("AT+DISI?");
  delay(500);
   asd = BTserial.readStringUntil('\n');
   //Serial.print(asd);
   //Serial.println();
   tmp = asd.substring(19,24);
   if(tmp == "DISC:"){

     if(asd.indexOf(phoneUUID) >= 0){

        dataIndex = asd.indexOf(phoneUUID) + phoneUUID.length();
       
        distance = asd.substring(dataIndex+1,dataIndex + 5);
        heading = asd.substring(dataIndex + 5,dataIndex + 9);

        //MOTOR

        if(oldHeading == NULL){

           oldHeading = heading;

      
          
          }else{
            
            //MOTOR

            int oldHeadingInt = (int) strtol(&oldHeading[0],NULL,16);
            int headingInt = (int) strtol(&heading[0],NULL,16);

                   
            Serial.print(oldHeadingInt);
            Serial.println();
            Serial.print(headingInt);
            
            int temp = headingInt - oldHeadingInt;

            if((temp > 5) && (abs(temp) < 180)){


                double leftDegree = temp * 14.2;
                
                digitalWrite(12,HIGH);
                digitalWrite(13,LOW);

                digitalWrite(7,HIGH);
                digitalWrite(8,LOW);

                analogWrite(5,0);
                analogWrite(6,255);

                delay(1000);
              
              
              }else if ((temp < -5) && (abs(temp) > 180)){

              temp = temp + 360;
              
               double leftDegree = temp * 14.2;
                
                digitalWrite(12,HIGH);
                digitalWrite(13,LOW);

                digitalWrite(7,HIGH);
                digitalWrite(8,LOW);

                analogWrite(5,0);
                analogWrite(6,255);

                delay(1000);

              
          } else if((temp < -5) && (abs(temp) < 180)){

            

              double rightDegree = abs(temp) * 12.5;

              digitalWrite(12,HIGH);
              digitalWrite(13,LOW);

              digitalWrite(7,HIGH);
              digitalWrite(8,LOW);

              analogWrite(5,255);
              analogWrite(6,0);

delay(1000);
           
                
                }else if((temp > 5) && (abs(temp) > 180)){

            

              double rightDegree = (360-temp) * 12.5;

              digitalWrite(12,HIGH);
              digitalWrite(13,LOW);

              digitalWrite(7,HIGH);
              digitalWrite(8,LOW);

              analogWrite(5,255);
              analogWrite(6,0);

delay(1000);
           
                
                }else{
                  
                  analogWrite(5,0);
                  analogWrite(6,0);
                  
                  }

        oldHeading = heading;                                  
            
            }


        //oldDistance = distance;



 

        
      
      }
    
    }


}
 
void setup() 
{

 pinMode(rightTrigPin,OUTPUT);
  pinMode(rightEchoPin,INPUT);

  pinMode(leftTrigPin,OUTPUT);
  pinMode(leftEchoPin,INPUT);
  
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
  
    Serial.begin(9600);
      while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
    Serial.println("Arduino is ready");
 
    BTserial.begin(9600); 
    
    while(!BTserial){}

    timer.setInterval(5000, repeatMe);
    
}


 
void loop()
{

  d = digitalRead(14);

 if(d == 0){

     timer.run();

    
    }else{

        analogWrite(5,0);
        analogWrite(6,0);
      
      }


 

      // Keep reading from HC-05 and send to Arduino Serial Monitor
//    if (BTserial.available())
//    {  
//        c = BTserial.read();
//        Serial.write(c);
//    }
// 
//    // Keep reading from Arduino Serial Monitor and send to HC-05
//    if (Serial.available())
//    {
//        c =  Serial.read();
//        BTserial.write(c);  
//    }
//
//    
// 
//}
//
}



