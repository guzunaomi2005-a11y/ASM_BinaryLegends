ASSUME CS:CODE, DS:DATA 
DATA SEGMENT 

	mesaj_input  db 'Introduceti octetii in format HEX (8-16 valori): $', 13, 10 ; program interactiv
	mesaj_invalid  db 'Numar octeti invalid! Introduceti intre 8 si 16, $', 13, 10
	sir_intrare db 100, ?, 100 dup (?) ;lungime maxima/ nr de caractere introduse/ caractere efective (input) 
	octeti db 16 dup (?) 
	nr_octeti db 0
	newline db 13,10,'$' ; sir pentru newline

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

jmp Georgiana ; salt catre georgiana pentru continuarea programului 

; --- Subrutina afis_binar ---
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


Georgiana:
;AICI TREBUIE SA CONTINUE GEORGIANA 
;Aici Va face calculul cuvantului C 
;sortare, rotiri, etc

mov ah, 4Ch
mov al, 00h   ; cod de iesire 0
int 21h

CODE ENDS 
END start


