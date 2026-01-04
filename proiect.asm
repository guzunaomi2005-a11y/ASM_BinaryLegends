assume cs:code, ds:data
data segment
sir_octeti db 3Fh,7Ah,12h,5Ch,20h,44h,55h,01h
nr_octeti dw 8
cuvant dw ?
data ends

code segment
start:
mov ax,data
mov ds,ax

;BITII 0-3 ai CUVANTULUI
mov al,sir_octeti[0] ;incarca primul octet in al, 3Fh
mov bl,al ;copiem in bl
and bl,0F0h ;pastram doar primii 4 biti
shr bl,4 ;ii punem  pe pozitiile 0-3

mov si,nr_octeti
dec si ;calculam indexul ultimului octet
mov al,sir_octeti[si] ;incarcam ultimul octet, 01h
mov cl,al
and cl,0Fh ;pastram doar ultimii 4 biti

xor bl,cl
and bl,0Fh;ne asiguram ca avem doar bitii 0-3
mov di,bx;salvam primii 4 biti ai cuvantului


;BITII 4-7 ai CUVANTULUI
mov cx,nr_octeti ;contor pt a parcurge tot sirul
xor si,si ;setam indexul la 0
xor dl,dl ;resetam registrul in care lucram

repeta_or:
mov al,sir_octeti[si] ;octetul curent
and al,3Ch ;izolam bitii 2 3 4 5
shr al,2 ;ii mutam pe pozitiile 0-3
or dl,al ;facem or cu rezultatul anterior
inc si ;crestem indexul
loop repeta_or

and dl,0Fh ;o masca pt a reduce rezultatul final la 4 biti
shl dx,4 ;mutam pe pozitiile 4-7, unde le este locul in cuvant
or di,dx ;le adaugam in di

;BITII 8-15 ai CUVANTULUI
mov cx,nr_octeti
xor si,si ;resetam index
xor al,al ;resetam registru

repeta_sum:
add al,sir_octeti[si] ;al este pe 8 biti=>orice depasire este ignorata
inc si
loop repeta_sum

mov ah,al
xor al,al ;curatam al pentru a nu suprapune datele la or
or di,ax

mov cuvant,di ;cuvantul COMPLET

;ROTIRI
mov cx,nr_octeti
xor si,si
xor bl,bl

repeta_rotiri:
mov al,sir_octeti[si] ;primul octet
mov bl,al ;il copiem in bl
shl bl,1 ;bitul 7 (high) iese si merge in cf
xor dl,dl ;resetam
adc dl,0 ;valorea din carry!!
shl bl,1
adc dl,0 ;acum avem suma primilor doi biti, N

push cx ;salvam contorul pe stiva
mov cl,dl ;mutam valoarea calculata N
rol al,cl ;facem o rotire cu N pozitii
pop cx ;luam inapoi valoarea contorului

mov sir_octeti[si],al ;salvam octetul nou rotit, inapoi
inc si ;trecem la urmatorul octet din sir
loop repeta_rotiri

mov ax,4C00h
int 21h
code ends
end start

