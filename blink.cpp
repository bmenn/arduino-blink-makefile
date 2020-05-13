#include <Arduino.h>

void setup() {
        pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
        digitalWrite(LED_BUILTIN, HIGH);
        delay(1000);
        digitalWrite(LED_BUILTIN, LOW);
        delay(1000);
}

int main(void) {
	init();

#if defined(USBCON)
	USBDevice.attached();
#endif

	setup();
	for (;;) {
		loop();
		if (serialEventRun) serialEventRun();
	}

	return 0;
}
