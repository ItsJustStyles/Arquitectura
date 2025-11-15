includelib \Windows\System32\kernel32.dll
ExitProcess proto

.data

	num dd 1013 ;El numero primo al que se le buscaran las raíces primitivas

	factores dd 10 DUP(?)
	cantFactores dd 0

	raicesRes dd 500 DUP(?)	; Vector donde se guardaran las raíces encontradas

.code

	main PROC

		sub RSP, 8
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
		call raices

		call ExitProcess

	main ENDP
		

	raices PROC
		sub RSP, 8
		mov dword ptr [RSP], 1 ;	Contador para el for  

		xor RSI, RSI
		mov RSI, 0
		xor RAX, RAX
		mov EAX, [RSP + 40]	; El número primo
		mov R8, [RSP + 32] ; El inicio del vector de los factores de num
		mov R9d, [RSP + 24] ; La cantidad de factores del num (p-1)
		mov RDI, [RSP + 16] ; El vector donde se guardaran las raices del numero

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
				jmp bucleFactores

			finRaices:
				add dword ptr [RSP], 1
				jmp bucleFactores

		returnBucle:
			add RSP, 8
			ret 32


			
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

END