MCU_TARGETS=atmega32u4 atmega328p atmega644pa attiny4

.PHONY: all
all:
	$(foreach mcu,$(MCU_TARGETS),MCU=$(mcu) make mcu &&) true

.PHONY: mcu
mcu: blink_${MCU}.s blink_${MCU}.elf blink_${MCU}.hex blink_${MCU}.lss

%.elf: blink.c
	avr-gcc -mmcu=${MCU} -Os -o $@ $<

%.s: blink.c
	avr-gcc -mmcu=${MCU} -Os -S -o $@ $<

%.hex: %.elf
	avr-objcopy -O ihex -R .eeprom $< $@

%.lss: %.elf
	avr-objdump -x -S $< > $@

.PHONY: clean
clean:
	rm -f *.hex *.lss *.elf *.s

