;yamitk
IDEAL
MODEL small
STACK 100h
DATASEG
jumps
; --------------------------
; Your variables here
; --------------------------
	output dw ?
	output2 db '0$$$$$$$$$$'
	var1 dw ?
	var2 dw ?
	leftover dw ?
	action db ?
	EnterMessage db 'Please enter a number, an action and another digit: $', 10, 13 ;$- thats end of msg
	ErrorMessage db 'The input you just entered is not valid, please try again: $'
	DivBy0 db 'Dont you dare multiply by 0 ;) $'
	WrongAction db 'Dont you dare try a different char from for your action /, +, -, * ;) $'
	ten db 10
	outputLength dw 10
	ReturnAdress dw ?
	Wtemp dw ?
	Btemp db ?
 	
CODESEG
proc DisplayFullNumber
	pop [ReturnAdress]
	pop ax
	mov bx, 10      
	xor cx, cx     
	Dloop1:  
		xor dx, dx   
		div bx      
		push dx     
		inc cx      
		cmp ax, 0    
		jne Dloop1     
		mov ah, 02h 
	Dloop2:  
		pop dx      
		add dx, 30h     
		int 21h      
		loop Dloop2
		push [ReturnAdress]
		ret       
endp DisplayFullNumber

start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
EnterMsg:
	mov dx, offset EnterMessage
	mov ah, 9h
	int 21h
	jmp Input1
exit1:
	jmp exit
Input1: ;reads characters
	mov [var1], 0
	mov cx, 5
		Input11:
			mov ax, 10
			mul [var1]
			mov [var1], ax ;multiplying var1 by 10
			mov ah, 1 ;קולטים בכייף
			int 21h
			cmp al, 27 ;if esc
			je exit1
			cmp al, 0Dh ;enter
			je zehu 
			cmp al, '1'
			jb Error1
			cmp al, '9'
			ja Error1
			sub al, '0'
			cbw
			add [var1], ax
			loop Input11
		Zehu:
			mov ax, [var1] ;because theres unneceserry multiplying by 10
			div [ten]
			mov [var1], ax
			jmp Actiontion
		
	Error1:
		mov dl, 0ah
		mov ah, 2h
		int 21h		
		mov dx, offset ErrorMessage
		mov ah, 9h
		int 21h
		jmp Input1
;now the input has fully passed to var1

Actiontion:
	mov ah, 1h
	int 21h
	cmp al, 27
	je exit1
	mov [action], al
	mov dl, 0Ah
	mov ah, 2h
	int 21h ;next line
	jmp Input2

NotCoolAction:
	mov dx, offset WrongAction
	mov ah, 9h
	int 21h
	jmp restart
	
Input2:	
	mov [var2], 0
	mov cx, 5
	Input22:
		mov al, 10
		mul [var2]
		mov [var2], ax ;multiplying var1 by 10
		mov ah, 1
		int 21h
		cmp al, 27 ;if esc
		je exit1
		cmp al, 0Dh ;enter
		je Zehu2
		cmp al, '1'
		jb Error2
		cmp al, '9'
		ja Error2
		sub al, '0'
		cbw
		add [var2], ax
		loop Input22
		Zehu2:
			mov ax, [var2] ;because theres unneceserry multiplying by 10
			div [ten]
			mov [var2], ax
		jmp continue
	
	Error2:
		mov dl, 0ah
		mov ah, 2h
		int 21h
		mov dx, offset ErrorMessage
		mov ah, 9h
		int 21h
		jmp Input1
;now the input has fully passed to var2

	
continue:
	xor ax, ax ;instead of doing it for every action
	cmp [action], 2Bh ;ascii for +
	je Adding
	cmp [action], 2Dh ;ascii for -
	je Subbing
	cmp [action], 2Fh ;ascii for :
	je Division
	cmp [action], 2Ah ;ascii for *
	je Multiply
	jmp NotCoolAction

Adding:
	mov ax, [var1]
	mov [output], ax
	mov ax, [var2]
	add [output], ax
	jmp print
	
Subbing:
	mov ax, [var1]
	mov [output], ax
	mov ax, [var2]
	sub [output], ax
	cmp [output], 0
	jb negPrint
	jmp print
	negPrint:
		mov dl, '-'
		mov ah, 2h
		int 21h
		neg [output]
		jmp print

Division:
	xor dx, dx
	cmp [var2], 0
	je DivisionBy0
	mov ax, [var1]
	idiv [var2]
	mov [output], ax
	mov [leftover], dx 
	jmp print
	DivisionBy0:
		mov dx, offset DivBy0
		mov ah, 9h
		int 21h
		mov dl, 0ah
		mov ah, 2h
		int 21h
		jmp restart

Multiply:
	mov ax, [var1]
	imul [var2]
	mov [output], ax
	jmp print


;by now, in output there is the exact number I want to show
print:
	push [output]
	call DisplayFullNumber


PrintLeftOver:
	cmp [leftover], 0
	je restart
	mov dl, '('
	mov ah, 2h
	int 21h
	push [leftover]
	call DisplayFullNumber
	mov dl,')'
	mov ah, 2h
	int 21h

restart:
	mov dl, 0ah
	mov ah, 2h
	int 21h
	jmp start

exit:
	mov ax, 4c00h
	int 21h
END start