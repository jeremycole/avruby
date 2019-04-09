	.file	"blink.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
	.section	.text.startup,"ax",@progbits
.global	main
	.type	main, @function
main:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	sbi 0xa,3
.L2:
	sbi 0xb,3
	ldi r18,lo8(799999)
	ldi r24,hi8(799999)
	ldi r25,hlo8(799999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	cbi 0xb,3
	ldi r18,lo8(799999)
	ldi r24,hi8(799999)
	ldi r25,hlo8(799999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	rjmp .L2
	.size	main, .-main
	.ident	"GCC: (GNU) 8.3.0"
