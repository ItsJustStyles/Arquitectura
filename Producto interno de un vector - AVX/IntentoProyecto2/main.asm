option casemap:none
includelib kernel32.lib
ExitProcess PROTO
.data

    ; 1. DEFINICIÓN EXPLÍCITA DE DATOS 

    ; Vector 1 completo de 8 elementos (usamos solo los primeros 6)
    Punto1  REAL8  2.0, -1.0, 4.0, 4.0, 6.0, 6.0, 0.0, 0.0
    
    ; Vector 2 completo de 8 elementos (usamos solo los primeros 6)
    Punto2  REAL8  0.4, 5.0, 1.5, -2.0, 2.5, 3.0, 0.0, 0.0
    
    ; Guardamos el resultado (un double repetido 8 veces)
    Producto REAL8 ?

.code
    main PROC

        ; A. Carga y Multiplicación
    
        ; Cargar la Parte 1 (x1..x4 * y1..y4)

        vmovupd ymm0, YMMWORD PTR [Punto1]
        vmovupd ymm2, YMMWORD PTR [Punto2]

        vmulpd ymm0, ymm0, ymm2                  ; ymm0 = (p1, p2, p3, p4) 
        ; Cargar la Parte 2 (x5, x6, 0, 0 * y5, y6, 0, 0)

        vmovupd ymm1, YMMWORD PTR [Punto1 + 32]
        vmovupd ymm3, YMMWORD PTR [Punto2 + 32]

        vmulpd ymm1, ymm1, ymm3                  ; ymm1 = (p5, p6, 0, 0) 

        ; B. Reducción Horizontal y Suma (45.5)
    
        ; 1. Reducción de YMM0 (p1..p4) a XMM4[0] 
    
        ; Extraer carril superior de ymm0 (p3, p4) a xmm5
        vextractf128 xmm5, ymm0, 1               ; xmm5 = [p3, p4]
    
        ; Sumar carriles: xmm4 = [p1, p2] + [p3, p4]
        vaddpd xmm4, xmm0, xmm5                  ; xmm4 = [p1+p3, p2+p4]
    
        ; Mover el segundo double a xmm5[0]
        vpermilpd xmm5, xmm4, 00000001b          ; xmm5[0] = p2+p4
    
        ; Suma final de la Parte 1
        vaddsd xmm4, xmm4, xmm5                  
        ; ---------------------------------------------------------
    
        ; 2. Reducción de YMM1 (p5, p6, 0, 0) 
    
        ; Mover p6 a xmm6[0]
        vshufpd xmm6, xmm1, xmm1, 00000001b      
    
        ; Suma final de la Parte 2: p5 + p6
        vaddsd xmm5, xmm1, xmm6                  
        ; ---------------------------------------------------------
    
        ; 3. Suma Total: XMM4[0] + XMM5[0]
        vaddsd xmm0, xmm4, xmm5                  
        ; =========================================================
        ; C. Salir
        ; =========================================================
    
        ; Guardar resultado

        vmovsd QWORD PTR [Producto], xmm0 
        vzeroupper
        mov ecx, 0

        call ExitProcess

    main ENDP

END