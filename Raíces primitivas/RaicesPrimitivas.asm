includelib \Windows\System32\kernel32.dll
ExitProcess proto

GetStdHandle proto
WriteConsoleA proto
ReadConsoleA proto
Console equ -11

.data

	num dd 0 ;El numero primo al que se le buscaran las raíces primitivas

	factores dd 10 DUP(?)
	cantFactores dd 0

	raicesRes dd 11000 DUP(?)	; Vector donde se guardaran las raíces encontradas
	cantRaices dd 0

	buffer db 10 dup(' '), ' '

	STD_INPUT_HANDLE equ 0FFFFFFF6h
	stdin dq ?
	nBytesRead dq ?
	buffer_input db 7 dup(?)

	buffer_start dq ? 
	buffer_length dq ?

    stdout qword ?
	nBytesWritten qword ?

.code

	main PROC
		sub RSP, 8


		call leerNumero

		xor R8, R8
		mov R8d, num
		push R8
		xor R8, R8
		lea R8, factores
		push R8
		xor R8, R8
		lea R8, cantFactores
		push R8
		call factoresPrimos
		xor R8, R8

		mov R8d, num
		push R8
		xor R8, R8
		lea R8, factores
		push R8
		xor R8, R8
		mov R8d, cantFactores
		push R8
		xor R8, R8
		lea R8, raicesRes
		push R8
		xor R8, R8
		lea R8, cantRaices
		push R8
		xor R8, R8
		call raices

		mov R8d, cantRaices
		push R8
		xor R8, R8
		lea R8, raicesRes
		push R8
		xor R8, R8
		lea R8, [buffer + 9]
		push R8
		xor R8, R8
		lea R8, buffer_start
		push R8
		xor R8, R8
		lea R8, buffer_length
		push R8
		xor R8, R8
		lea R8, nBytesWritten
		push R8
		call ImprimirRaices

		call ExitProcess

	main ENDP
		

	raices PROC
		sub RSP, 8
		mov dword ptr [RSP], 1 ;	Contador para el for  

		xor RSI, RSI
		mov RSI, 0
		xor RAX, RAX
		mov EAX, [RSP + 48]	; El número primo
		mov R8, [RSP + 40] ; El inicio del vector de los factores de num
		mov R9d, [RSP + 32] ; La cantidad de factores del num (p-1)
		mov RDI, [RSP + 24] ; El vector donde se guardaran las raices del numero
		mov R15, [RSP + 16]
		mov dword ptr [R15], 0

		mov R11, 1 ; Va a contener el valor del factor anterior
		mov R10d, EAX
		dec R10d ; Contiene el numero p - 1
		mov R12d, 1

		bucleFactores:
			mov R14d, 1
			mov RSI, 0
			cmp R10d, R12d
			jl returnBucle

			confirmarRaiz:

				push RAX
				dec RAX
				mov ECX, R12d
				xor RDX, RDX
				mov R13d, [R8 + RSI]
				idiv R13d
				mov EBX, EAX
				pop RAX
				push R8
				mov R8, RAX

				call exponenciacionModular
				pop R8

				cmp EDX, 1
				jz noGuardarRaiz
				add RSI, 4
				
				cmp R9d, R14d
				jnz l_aumentarRaiz
				jmp guardaRaiz

			l_aumentarRaiz:
				inc R14d
				jmp confirmarRaiz

			noGuardarRaiz:
				inc R12d
				jmp bucleFactores

			guardaRaiz:
				mov dword ptr [RDI], R12d
				add RDI, 4
				inc R12d
				inc dword ptr [R15]
				jmp bucleFactores

			finRaices:
				add dword ptr [RSP], 1
				jmp bucleFactores

		returnBucle:
			add RSP, 8
			ret 40


			
	raices ENDP

	factoresPrimos PROC
		
		mov EAX, [RSP + 24] ; Contiene el numero p
		dec EAX	; Decrementa en 1 el contenido de EAX (p - 1)

		mov RDI, [RSP + 16]	; Inicio del vector factores
		mov RSI, [RSP + 8] ; El valor para contar los factores
		mov dword ptr [RSI], 0

		mov ECX, 2

		DividirPorDos:

			cmp EAX, 1
			je ReturnFactor

			xor EDX, EDX
			mov R9d, EAX
			idiv ECX

			cmp EDX, 0
			jnz ProbarImpares

			mov dword ptr [RDI], ECX
			add RDI, 4
			inc dword ptr [RSI]
			mov EAX, EAX
			jmp DividirPorDos

		ProbarImpares:
			mov EAX, R9d
			mov ECX, 3

		IterarImpares:
			cmp ECX, 1
			je ReturnFactor

			mov EBX, EAX
			mov EAX, ECX
			mul ECX

			cmp EAX, EBX
			mov EAX, EBX
			jg UltFactor

			xor EDX, EDX
			idiv ECX

			cmp EDX, 0
			jnz siguienteImpar

			mov dword ptr [RDI], ECX
			add RDI, 4
			inc dword ptr [RSI]

			mov EAX, EAX
			jmp IterarImpares

		siguienteImpar:
			add ECX, 2
			jmp IterarImpares

		UltFactor:
			cmp EAX, 1
			jle ReturnFactor

			mov DWORD PTR [RDI], EAX
			inc DWORD PTR [RSI]

		ReturnFactor:
			ret 24


	factoresPrimos ENDP

	exponenciacionModular PROC
		push RAX

		;ECX el a
		;EBX el exponente
		;R8 el n

		mov EAX, ECX
		idiv R8
		mov ECX, EDX

		sub RSP, 8
		mov dword ptr [RSP], 1

		mov EAX, 1

		bucleModulo:

			cmp [RSP], EBX
			jz finModulo

			mov RAX, RDX
			imul ECX
			idiv R8
			
			add dword ptr [RSP], 1
			jmp bucleModulo

		finModulo:
			add RSP, 8
			pop RAX
			ret

	exponenciacionModular ENDP

	BinToAscii PROC
		mov r14, [rsp + 32]
		mov rbx, [rsp + 24] ; buffer_length
		mov eax, [rsp + 16] ; numero
		mov rdi, [rsp + 8] ; buffer
		mov rcx, 10
		mov r10, 0

		conversion_loop:
			xor rdx, rdx
			div rcx
			add dl, '0'
			mov byte ptr [rdi], dl
			inc r10
			dec rdi

			cmp rax, 0
			jnz conversion_loop

			inc rdi
			mov qword ptr [r14], rdi

			inc r10
			mov qword ptr [rbx], r10

			ret 24

	BinToAscii ENDP
	
	
	
	ImprimirRaices PROC

		sub rsp, 40
		mov r12d, [rsp + 88] ; cantRaices
		mov r15, [rsp + 80] ; raicesRes
		mov r13, [rsp + 72] ; Buffer

		mov r10, [rsp + 64] ; buffer_start
		mov r11, [rsp + 56]	; buffer_length
		mov R9, [rsp + 48] ; nBytesWritten

		mov rsi, 0
		

		mov rcx, Console
		call GetStdHandle
		mov stdout, rax

		bucle_imprimir: 
			mov r8d, [r15 + rsi]
			add rsi, 4

			push r10

			push r11
			push r8 ; El número que se convierte a su formato ascii correspondiente
			push r13 ;
			xor r8, r8
			call BinToAscii
			pop r10

			mov  rcx, stdout
			mov  rdx, qword ptr [r10]              
			mov  r8, qword ptr [r11]         
			push r10
			push r11
			call WriteConsoleA             
			pop r10
			pop r11

			dec r12
			cmp r12, 0
			jnz bucle_imprimir

			add rsp, 40
			ret 48

	ImprimirRaices ENDP

	asciiToBin PROC
		
		lea rdx, buffer_input
		mov rcx, nBytesRead
		dec rcx
		dec rcx

		mov rax, 0      
		mov rsi, 0
		
		mov r10, 10

	conversion_loop:
		cmp rsi, rcx
		jge end_loop
		movzx r11d, byte ptr [rdx + rsi]
		sub r11d, '0'
		
		push rdx
		mov rdx, r10
		mul rdx
		pop rdx

		add rax, r11

		inc rsi
		jmp conversion_loop


	end_loop:
		mov qword ptr [num], rax 
		ret

	asciiToBin ENDP



	leerNumero PROC

		sub rsp, 40

		mov rcx, STD_INPUT_HANDLE
		call GetStdHandle
		mov stdin, rax

		mov rcx, stdin
		lea rdx, buffer_input
		mov r8, 7
		lea r9, nBytesRead

		call ReadConsoleA
		add rsp, 40
		call asciiToBin
		ret

	leerNumero ENDP

END