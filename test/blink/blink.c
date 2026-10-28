#define F_CPU 8000000

#include <avr/io.h>
#include <util/delay.h>

int main(int argc, char const *argv[])
{
  DDRB |= _BV(2);
  while(1) {
    PORTB |= _BV(2);
    _delay_ms(500);
    PORTB &= ~_BV(2);
    _delay_ms(500);
  }
  return 0;
}
