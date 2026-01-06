ASSUME CS:CODE, DS:DATA
DATA SEGMENT
    sir DB 0Fh, 00h, 0FFh, 01h         
    len DW 4                               
    pos_originala DB 0
    max_biti_gasiti DB 0
    temp_cx DW 0                           
    msg_poz DB 0Dh, 0Ah, 'Pozitia originala: $'
DATA ENDS

CODE SEGMENT
    

START:
    MOV AX, DATA
    MOV DS, AX

    ;Determinare pozitie (inainte de sortare)
    MOV SI, 0
    MOV CX, len
    MOV BL, 0          ; Maximul de biti gasit

CAUTA_MAX_INITIAL:
    MOV AL, sir[SI]
    MOV DL, 0          ; Numarator biti 1
    MOV AH, 8          
BIT_COUNT:
    SHL AL, 1
    ADC DL, 0
    DEC AH
    JNZ BIT_COUNT
    
    ; Verificam: biti > 3 si biti > maximul anterior
    CMP DL, 3
    JBE URMATORUL
    CMP DL, BL
    JBE URMATORUL
    
    MOV BL, DL         ; Actualizam maximul
    MOV AX, SI         ; SI este indexul curent (0, 1, 2...)
    MOV pos_originala, AL 

URMATORUL:
    INC SI
    LOOP CAUTA_MAX_INITIAL

    ;Sortare descrescatoare
    MOV CX, len
    DEC CX
L1: MOV temp_cx, CX
    MOV SI, 0
L2: MOV AL, sir[SI]
    CMP AL, sir[SI+1]
    JAE NO_SWAP
    XCHG AL, sir[SI+1]
    MOV sir[SI], AL
NO_SWAP:
    INC SI
    LOOP L2
    MOV CX, temp_cx
    LOOP L1

    ;Afisare
    MOV AH, 09h
    LEA DX, msg_poz
    INT 21h

    MOV AL, pos_originala
    ADD AL, '0'        ; Transforma 2 în '2'(codul ASCII)
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Asteptare tasta si Exit
    MOV AH, 08h
    INT 21h
    MOV AX, 4C00h
    INT 21h
CODE ENDS
END START