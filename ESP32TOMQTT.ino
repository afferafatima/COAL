#include <WiFi.h>
#include <Arduino.h>
#include <PubSubClient.h>
#include <ESP32Firebase.h>
const char* ssid = "TP-Link_7E20";           // Replace with your network's SSID
const char* password = "94822939h";   // Replace with your network's password
const char* mqtt_server = "Broker.hivemq.com"; // MQTT broker address
const int mqtt_port = 1883;                     // MQTT default port
const char* inTopic = "ldr";          // Topic to subscribe to
const char* outTopic = "threshold";
#define REFERENCE_URL "https://ldr-value-fd7db-default-rtdb.asia-southeast1.firebasedatabase.app/"  // Your Firebase project reference url

Firebase firebase(REFERENCE_URL);
WiFiClient espClient;
PubSubClient client(espClient);

long currentTime , lastTime;
int count = 0 ;
char messages[50];
 int receivedData  = 0;
void connectToWiFi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
  }
}

void reconnect() {
  while (!client.connected()) {

    if (client.connect(mqtt_server )) {
      
      client.subscribe(inTopic);
    }
   
  }
}
void callback(char* topic, byte* payload, unsigned int length) {
  String receivedValue = ""; // Clear the variable before storing new data
  String value = "";
  for (int i = 0; i < length; i++) {
    value += (char)payload[i];
  }

}
void setup() {
  Serial.begin(9600);
  
  connectToWiFi();
 client.setServer(mqtt_server , 1883);
 client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
 reconnect();
  }
   client.loop();
  if (Serial.available() > 0) {
     receivedData = Serial.read();
  }
  currentTime  = millis();
  if(currentTime - lastTime > 2000)
  {
    snprintf(messages , 75 , "%ld" , receivedData);
    client.publish(outTopic , messages);
    firebase.setInt("LDR/ldr", receivedData);
    lastTime = millis();
  }
  
}
