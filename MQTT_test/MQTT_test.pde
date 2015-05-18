#include <Wasp3G.h>
#include <WaspPWR.h>
#include <WaspFrame.h>
#include "WaspMQTTClient.h"
#include "WaspMQTTUtils.h"


char MQTT_USERNAME[] = "";
char MQTT_PASSWORD[] = "";
char MQTT_DEVICE_ID[] = "appsaloon";  // Used as client_id, if we suppose that one device represents one client.
char MQTT_TOPIC[] = "appsaloon";
char MQTT_HOST[] = "iot.eclipse.org";
long MQTT_PORT = 1883;

int8_t answer;

long lastTime = 0;

MQTTUtils j;
WaspMQTTClient c;
Wasp3GMQTTClient client;

void cmdCallBack(char *topic, uint8_t* message, unsigned int len);

void setup() {
	boolean ans = false;

	USB.ON();
	USB.println(F("> USB port started."));

	client = Wasp3GMQTTClient();

	c = WaspMQTTClient(MQTT_HOST, MQTT_PORT, cmdCallBack, client);

	answer = 0;

	while(answer != 1) {
		answer = c.connect(MQTT_DEVICE_ID, MQTT_USERNAME, MQTT_PASSWORD);
		if(answer != 1)
		{
		  USB.println(F("Unable to connect to network."));
		}
	}
}


void loop() {

	delay(200);

	if(!c.loop()) {
		USB.print(F("MQTT loop failure."));
	}

	if (millis() > lastTime + 2000) {
		j.setTopic("/raceAlert");
		j.startJsonObject(true);
		j.addKeyValuePair("b", PWR.getBatteryLevel());
		j.endJsonObject();
		
		if(c.publish(j.getTopic(), j.getMessage())) {
		  	USB.println(F("Response Sent."));
		}
		else {
		  	USB.println(F("Response does not sent."));
		}
		lastTime = millis();
	}
}


void cmdCallBack(char *inTopic, uint8_t *message, unsigned int len) {}
