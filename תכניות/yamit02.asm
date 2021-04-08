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
	var1 dw ?
	var2 dw ?
	leftover dw ?
	action db ?
	WelcomeMessage db 'welcome to my calculator! hope you have some fun and grade it 100 at least', 13, 10, '$' ;$- thats end of msg
	EnterMessage db 'Please enter a num (,enter), an action ( -, /, *, +) and another num(enter):', 13, 10, '$'
	ErrorMessage db 'The input you just entered is not valid, please try again: $'
	DivBy0 db 'Dont you dare divide by 0 ;) $'
	WrongAction db 'Dont you dare try a different char from for your action /, +, -, * ;) $'
	ten dw 10
	outputLength dw 10
	ReturnAdress dw ?
	Wtemp dw ?
	Btemp db ?
 	
CODESEG
proc DisplayFullNumber
	pop [ReturnAdress]
	pop ax ;ax is be the number to display
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

proc input
	pop [ReturnAdress]
	pop [Wtemp]
	
	mov [Wtemp], 0
	mov cx, 5
		Input11:
			mov ax, 10
			mul [Wtemp] ; dx:ax has the answer
			mov [Wtemp], ax ;multiplying the var by 10
			mov ah, 1 ;קולטים בכייף
			int 21h
			cmp al, 27 ;if esc
			je exit
			cmp al, 0Dh ;enter
			je zehu 
			cmp al, '0'
			jb Error1
			cmp al, '9'
			ja Error1
			sub al, '0'
			cbw
			add [Wtemp], ax
			loop Input11
		Zehu:
			mov ax, [Wtemp] ;because theres unneceserry multiplying by 10
			div [ten]
			push ax
			jmp Yalla
		
	Error1:
		mov dl, 0ah
		mov ah, 2h
		int 21h		
		mov dx, offset ErrorMessage
		mov ah, 9h
		int 21h
		jmp Input1
	
	Yalla:
		push [ReturnAdress]
		ret
endp input

start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	mov dx, offset WelcomeMessage
	mov ah, 9h
	int 21h
	jmp EnterMsg

startAgain:
	mov ax, @data
	mov ds, ax

EnterMsg:
	mov dx, offset EnterMessage
	mov ah, 9h
	int 21h
	jmp Input1
exit1:
	jmp exit

Input1: ;reads characters
	push [var1]
	call input
	pop [var1]
;now the input has fully passed to var1

Actiontion:
	mov ah, 1h
	int 21h
	cmp al, 27
	je exit
	mov [action], al
	mov dl, 0Ah
	mov ah, 2h
	int 21h ;next line
	JustMakeSureActionIsFine:	
		cmp [action], 2Bh ;ascii for +
		je Input2
		cmp [action], 2Dh ;ascii for -
		je Input2
		cmp [action], 2Fh ;ascii for :
		je Input2
		cmp [action], 2Ah ;ascii for *
		je Input2
		;if the action we got is none of the above, NotCoolAction will rise

NotCoolAction:
	mov dx, offset WrongAction
	mov ah, 9h
	int 21h
	jmp restart

Input2:	
	push [var2]
	call input
	pop [var2]
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
	mov dl, '='
	mov ah, 2h
	int 21h
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
	jmp startAgain

exit:
	mov ax, 4c00h
	int 21h
END start