ASSUME CS:CODE, DS:DATA 
DATA SEGMENT 

	mesaj_input  db 'Introduceti octetii in format HEX (8-16 valori): $', 13, 10 ; program interactiv
	mesaj_invalid  db 'Numar octeti invalid! Introduceti intre 8 si 16, $', 13, 10
	sir_intrare db 100, ?, 100 dup (?) ;lungime maxima/ nr de caractere introduse/ caractere efective (input) 
	octeti db 16 dup (?) 
	nr_octeti db 0
	newline db 13,10,'$' ; sir pentru newline
	hex_table db '0123456789ABCDEF'
	octeti_original db 16 dup (?)

	; pentru sortare si octetul cu cei mai multi biti
     	 pos_originala DB 0
    	max_biti_gasiti DB 0
    	temp_cx DW 0                           
    	msg_poz DB 0Dh, 0Ah, 'Pozitia originala: $'

	C dw 0 ;cuvantul C -folosit mai departe 
DATA ENDS 

CODE SEGMENT 
start:
	mov ax, data 
	mov ds, ax
	citire:
	;afisare mesaj
	mov ah, 09h
	mov dx, offset mesaj_input
	int 21h

	;citire sir 
	mov ah, 0Ah 
	mov dx, offset sir_intrare
	int 21h 

	;conversie din hex in binar 
	mov si, offset sir_intrare + 2 ; adresa primul element din sirul de intrare 
	mov di, offset octeti 
	mov cl, sir_intrare[1]
	mov bx, 0 ;nr de octeti 
   	mov ch, 0 
	
	conv_loop:

	 cmp cl, 0
       je conv_final
	cmp byte ptr [si], ' '
	je sari_spatiu

	;OCTET SUPERIOR 
	mov al, [si]
	cmp al, '9' 
	jbe cifra_mare 
	;daca este litera:
	sub al, 'A'-10  ; A->10, B-> 11
	jmp gata_mare 
	
	cifra_mare:
	sub al, '0'
	gata_mare:
	shl al, 4
	mov ah, al
	
	;OCTET INFERIOR
	inc si
	dec cl 
	mov al, [si]
	cmp al, '9'
	jbe cifra_mica 
	;daca e litera 
	sub al, 'A'- 10
	jmp gata_mica 
	
	cifra_mica:
	sub al, '0'
	gata_mica:
	or ah, al 
	
	;salvare octet
	mov [di], ah
	inc di 
	inc bl

	inc si
	dec cl 
	jmp conv_loop

sari_spatiu:
	inc si 
	dec cl
	jmp conv_loop

conv_final:
	mov nr_octeti, bl


; validare nr octeti 8..16
    cmp bl, 8
    jb invalid_input
    cmp bl, 16
    ja invalid_input

;fac o copie a sirului de octeti deoarece va fi stricata la rotiri 
mov si, offset octeti
mov di, offset octeti_original
mov cl, nr_octeti
xor ch, ch

copiere:
    mov al, [si]
    mov [di], al
    inc si
    inc di
loop copiere

    jmp afis_octeti_start

invalid_input:
    mov ah, 09h
    mov dx, offset mesaj_invalid
    int 21h
    jmp citire



afis_octeti_start:
    mov si, offset octeti
    mov cl, nr_octeti

afis_octeti:
    mov al, [si]
    call afis_binar     
    inc si
    dec cl
    jnz afis_octeti

    ; afisare newline dupa sir
    mov ah, 09h
    mov dx, offset newline
    int 21h
afis_hex_start:
  mov si, offset octeti
  mov cl, nr_octeti

afisare_hex_loop:
    mov al, [si]
    call afis_hex
    inc si
    dec cl
    jnz afisare_hex_loop

; afisare newline la final
mov ah, 09h
mov dx, offset newline
int 21h



jmp Georgiana ; salt catre georgiana pentru continuarea programului 

; SUBRUTINA BINAR
afis_binar:
    push ax
    push cx         ; salvam cl (numar octeti ramasi)
    mov cl, 8       ; 8 biti pentru afisare
    mov bl, al
binar_loop:
    shl bl,1
    jc bit_1
    mov dl,'0'
    jmp scrie
bit_1:
    mov dl,'1'
scrie:
    mov ah,02h
    int 21h
    dec cl
    jnz binar_loop
    ; afișăm spațiu după octet
    mov dl,' '
    mov ah,02h
    int 21h
    pop cx          ; restauram cl
    pop ax
    ret
;SUBRUTINA HEXADECIMAL
afis_hex:
    push ax
    push bx
    push cx
    push dx

    mov ch, al        ; salvam octetul

    mov bx, offset hex_table

    mov al, ch
    shr al, 4
    xlat 
    mov dl, al
    mov ah, 02h
    int 21h

   
    mov al, ch
    and al, 0Fh
    xlat
    mov dl, al
    mov ah, 02h
    int 21h

    ; spatiu
    mov dl, ' '
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret

Georgiana:
mov al,octeti[0] ;incarca primul octet in al, 3Fh
mov bl,al ;copiem in bl
and bl,0F0h ;pastram doar primii 4 biti
shr bl,4 ;ii punem  pe pozitiile 0-3

mov al, nr_octeti
mov ah,0
mov si, ax
dec si ;calculam indexul ultimului octet
mov al,octeti[si] ;incarcam ultimul octet, 01h
mov cl,al
and cl,0Fh ;pastram doar ultimii 4 biti

xor bl,cl
and bl,0Fh;ne asiguram ca avem doar bitii 0-3
mov di,bx;salvam primii 4 biti ai cuvantului


;BITII 4-7 ai CUVANTULUI
mov cl,nr_octeti ;contor pt a parcurge tot sirul
mov ch,0
xor si,si ;setam indexul la 0
xor dl,dl ;resetam registrul in care lucram

repeta_or:
mov al,octeti[si] ;octetul curent
and al,3Ch ;izolam bitii 2 3 4 5
shr al,2 ;ii mutam pe pozitiile 0-3
or dl,al ;facem or cu rezultatul anterior
inc si ;crestem indexul
loop repeta_or

and dl,0Fh ;o masca pt a reduce rezultatul final la 4 biti
mov dh,0
shl dx,4 ;mutam pe pozitiile 4-7, unde le este locul in cuvant
or di,dx ;le adaugam in di

;BITII 8-15 ai CUVANTULUI
mov cl,nr_octeti
mov ch,0
xor si,si ;resetam index
xor al,al ;resetam registru

repeta_sum:
add al,octeti[si] ;al este pe 8 biti=>orice depasire este ignorata
inc si
loop repeta_sum

mov ah,al
xor al,al ;curatam al pentru a nu suprapune datele la or
or di,ax

mov c,di;cuvantul COMPLET

;ADAUGAT DE NAOMI PENTRU VERIFICARE -AFISARE CUVANT C 
mov ax, c
push ax
mov al, ah ;octetul superior 
call afis_binar 
pop ax

push ax
mov al, al ;octetul inferior 
call afis_binar
pop ax

push ax
mov al, ah
call afis_hex
pop ax 

push ax
mov al, al
call afis_hex
pop ax

mov ah, 09h
mov dx, offset newline
int 21h


;ROTIRI
mov cl,nr_octeti
mov ch,0
xor si,si
xor bl,bl

repeta_rotiri:
mov al,octeti[si] ;primul octet
mov bl,al ;il copiem in bl
xor dl, dl ; resetam
shl bl,1 ;bitul 7 (high) iese si merge in cf
adc dl,0 ;valorea din carry!!
shl bl,1
adc dl,0 ;acum avem suma primilor doi biti, N

push cx ;salvam contorul pe stiva
mov cl,dl ;mutam valoarea calculata N
rol al,cl ;facem o rotire cu N pozitii
pop cx ;luam inapoi valoarea contorului

mov octeti[si],al ;salvam octetul nou rotit, inapoi
inc si ;trecem la urmatorul octet din sir
loop repeta_rotiri

;ADAUGAT DE NAOMI PENTRU A VEDEA/AFISA ROTIRILE 

mov ah, 09h
mov dx, offset newline
int 21h

mov si, offset octeti
mov cl, nr_octeti

afis_rotiri_binar:
    mov al, [si]
    call afis_binar
    inc si
    dec cl
    jnz afis_rotiri_binar

mov ah, 09h
mov dx, offset newline
int 21h

mov si, offset octeti
mov cl, nr_octeti

afis_rotiri_hex:
    mov al, [si]
    call afis_hex
    inc si
    dec cl
    jnz afis_rotiri_hex

mov ah, 09h
mov dx, offset newline
int 21h


;STUDENT 3- MARIA 
  ;Determinare pozitie (inainte de sortare)
    MOV SI, 0
    MOV CL, nr_octeti
    MOV CH, 0
    MOV BL, 0          ; Maximul de biti gasi

CAUTA_MAX_INITIAL:
    MOV AL, octeti_original[SI]
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
    MOV CL, nr_octeti
    MOV CH, 0
    DEC CX
L1: MOV temp_cx, CX
    MOV SI, 0
L2: MOV AL, octeti_original[SI]
    CMP AL, octeti_original[SI+1]
    JAE NO_SWAP
    XCHG AL, octeti_original[SI+1]
    MOV octeti_original[SI], AL
NO_SWAP:
    INC SI
    LOOP L2
    MOV CX, temp_cx
    LOOP L1



; INTRODUS DE NAOMI PENTRU A AFISA SIRUL SORTAT - PENTRU USURINTA
mov ah, 09h
lea dx, newline
int 21h

mov si, offset octeti_original
mov cl, nr_octeti
xor ch, ch 

afis_sort_binar:
    mov al, [si]
    call afis_binar
    inc si
    dec cl
    jnz afis_sort_binar

; newline
mov ah, 09h
mov dx, offset newline
int 21h

mov si, offset octeti_original
mov cl, nr_octeti

afis_sort_hex:
    mov al, [si]
    call afis_hex
    inc si
    dec cl
    jnz afis_sort_hex

; newline final
mov ah, 09h
mov dx, offset newline
int 21h

;DE AICI INAPOI LA MARIA 


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


mov ax, 4C00h
int 21h

CODE ENDS 
END start