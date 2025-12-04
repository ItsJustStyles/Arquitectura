.data
	vector: .hword 3, -12, -15, 7, 5, 9, -1, 15, -30, 1
			.equ size, (. - vector)
	sizeVector: .word 10

.text
	.global _start


_start:
	ldr r0, vectorAOrdenar
	
	ldr r8, tamanoVector
	ldr r8, [r8]
	lsl r8, r8, #1
	add r8, r8, r0
	bl bubbleSort
	b end

bubbleSort:

	loop:

		ldr r0, vectorAOrdenar
		sub r8, #2
		mov r7, #0

	loop2:
		ldrsh r1, [r0]
		ldrsh r2, [r0, #2]
		cmp r1, r2
		
		movgt r3, r1
		movgt r1, r2
		movgt r2, r3
		movgt r7, #1
		strh r1, [r0]
		strh r2, [r0, #2]
		
		
		add r0, #2
		cmp r0, r8
		blt loop2

		cmp r7, #0
		moveq pc, lr
		
		cmp r0, r8
		beq loop
		movne pc, lr
	
vectorAOrdenar: .word vector
tamanoVector: .word sizeVector	


end:
	.end