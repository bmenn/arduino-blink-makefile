ARDUINO_DIR = /usr/share/arduino
ARDUINO_CORE = $(ARDUINO_DIR)/hardware/arduino/cores/arduino
ARDUINO_PINS = $(ARDUINO_DIR)/hardware/arduino/variants/standard

AVRDUDE = avrdude

MCU = atmega328p
CFLAGS = -I$(ARDUINO_CORE) -I$(ARDUINO_PINS)

.PHONY: build flash clean

build: build/blink.hex

build/libcore.a: build/libs/wiring.o build/libs/wiring_digital.o
	avr-ar rcs $@ $^

build/%.o: %.cpp
	avr-g++ $(CFLAGS) -x c++ -MMD -c -DF_CPU=16000000L -Wall -Os -mmcu=$(MCU) -o $@ $^
	# What does -c -MMD -Os do?

# TODO Adds builds for Arduino core libs
build/libs/%.o: $(ARDUINO_CORE)/%.c
	mkdir -p build/libs
	# -c is important, not sure why
	avr-gcc $(CFLAGS) -c -DF_CPU=16000000L -mmcu=$(MCU) -o $@ $^

build/%.elf: build/%.o build/libcore.a
	# Linking
	avr-gcc $(CFLAGS) -mmcu=$(MCU) -Wl,--gc-sections -Os -o $@ $< -Lbuild -lcore -lc -lm

build/%.hex: build/%.elf
	avr-objcopy -O ihex -R .eeprom $^ $@

flash: build/blink.hex
	$(AVRDUDE) -p atmega328p -c arduino -b 115200 -P /dev/ttyS3 -D -U flash:w:$<:i

clean:
	rm -rf build
