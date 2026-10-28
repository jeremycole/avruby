	.file	"blink.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__CCP__ = 0x3c
__tmp_reg__ = 16
__zero_reg__ = 17
	.text
	.section	.text.startup,"ax",@progbits
.global	main
	.type	main, @function
main:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	sbi 0x1,2
.L2:
	sbi 0x2,2
	ldi r20,lo8(799999)
	ldi r21,hi8(799999)
	ldi r22,hlo8(799999)
1:	subi r20,1
	sbci r21,0
	sbci r22,0
	brne 1b
	rjmp .
	nop
	cbi 0x2,2
	ldi r20,lo8(799999)
	ldi r21,hi8(799999)
	ldi r22,hlo8(799999)
1:	subi r20,1
	sbci r21,0
	sbci r22,0
	brne 1b
	rjmp .
	nop
	rjmp .L2
	.size	main, .-main
	.ident	"GCC: (GNU) 14.3.0"
