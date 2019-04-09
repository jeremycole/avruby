#define F_CPU 8000000

#include <avr/io.h>
#include <util/delay.h>

int main(int argc, char const *argv[])
{
  DDRD |= _BV(3);
  while(1) {
    PORTD |= _BV(3);
    _delay_ms(500);
    PORTD &= ~_BV(3);
    _delay_ms(500);
  }
  return 0;
}
