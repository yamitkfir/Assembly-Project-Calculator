;yamitk PROJECT!
IDEAL
MODEL small
STACK 100h
DATASEG
jumps ;so I can do long jumps in all its forms! (je, jne, jb, ja...)
; --------------------------
; Your variables here
; --------------------------
	output dw ?
	var1 dw 0
	var2 dw 0
	leftover dw 0
	action db ?
	WelcomeMessage db 'welcome to my calculator! hope you have some fun', 13, 10, '$' ;$- thats end of msg
	EnterMessage db 'Please enter a num (,enter), an action ( -, /, *, +) and another num(enter):', 13, 10, '$' ;13, 10 - next line
	ErrorMessage db 'The input you just entered is not valid, please try again: $'
	DivBy0 db 'Dont you dare divide by 0 ;) $'
	WrongAction db 'Dont you dare try a different char from for your action /, +, -, * ;) $'
	TooBig db 'sorry m8, im not capble of handling this large number. try again: $'
	ten dw 10
	outputLength dw 10
	ReturnAdress dw ?
	Wtemp dw ?
	Btemp db ?
	isneg db 0 ;temp, for the input
	isneg1 db 0
	isneg2 db 0
	isnegoutput db 0
	raised_error db 0
 	
CODESEG
proc DisplayFullNumber
	pop [ReturnAdress]
	pop ax ;IGNORE_LINE
	;(מפריע לצ'קר כי לא עשו לו פוש, אבל הפוש נעשה למשתנה אחר, שצריך להדפיס).
	;ax is the number to display
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
	push [ReturnAdress] ;IGNORE_LINE
	;(מפריע לצ'קר כי אין פופ אבל לא צריך לעשות לזה פופ כי זו פונקצייה).
	ret
endp DisplayFullNumber

proc input
	pop [ReturnAdress]
	pop [Wtemp] ;the var i want to put num in
	mov [Wtemp], 0 ; resetting it just in case it has some junk in it
	mov cx, 6
Input11:
	mov ax, 10
	mul [Wtemp] ; dx:ax has the answer
	mov [Wtemp], ax ;multiplying the var by 10
	mov ah, 1 ;קולטים בכייף
	int 21h
	cmp al, 27 ;if esc
	je exit ;IGNORE_LINE
	;ends the whole program
	cmp al, 0Dh ;if enter
	je zehu
	cmp al, 45 ;if -
	je negnum
	jmp ok
negnum:
	cmp [Wtemp], 0
	je continuebegnum ;just making sure the '-' is in the first digit! if not, thats an arror...
	jmp Error1
continuebegnum:
	mov [isneg], 1
	loop Input11
ok:
	cmp al, '0'
	jb Error1
	cmp al, '9'
	ja Error1
	sub al, '0'
	cbw
	add [Wtemp], ax
	loop Input11
zehu:
	mov ax, [Wtemp] ;because theres unneceserry multiplying by 10
	div [ten]
	push ax;IGNORE_LINE
	;(the checker doesnt see a pop to ax, but it is used in label INPUT1 and pops to var1)
	jmp Yalla
Error1:
	mov dl, 0ah
	mov ah, 2h
	int 21h ;line seperator
	mov dx, offset ErrorMessage
	mov ah, 9h
	int 21h ;print error msg
	mov [Wtemp], 0 ;resetting the var
	mov [var1], 0
	mov [var2], 0 ;just in case theres something in them, resetting both vars
	mov cx, 6
	mov [raised_error], 1
	jmp thatsit
Error2:
	mov dl, 0ah
	mov ah, 2h
	int 21h ;line seperator
	mov dx, offset TooBig
	mov ah, 9h
	int 21h ;print error msg
	mov [Wtemp], 0 ;resetting the var
	mov [var1], 0
	mov [var2], 0 ;just in case theres something in them, resetting both vars
	mov cx, 6
	jmp Input11
Yalla:
	cmp cx, 0
	je toobigm8
	cmp [isneg], 0 ;checking if the user put - in the beggining
	jne itsneg
	jmp thatsit
toobigm8: ; the input is 6 chars long, but i only allow up to 5!
	jmp Error2
itsneg: ;the user put - in the beggining
	neg [Wtemp]
	cmp [var1], 0
	jne var2neg
	jmp var1neg
var2neg:
	mov [isneg2], 0
	jmp thatsit
var1neg:
	mov [isneg1], 0
	jmp thatsit
thatsit:
	push [ReturnAdress] ;IGNORE_LINE
	ret
endp input

proc procadd
	pop [ReturnAdress]
	mov ax, [var1]
	mov [output], ax
	mov ax, [var2]
	add [output], ax
	push [ReturnAdress] ;IGNORE_LINE
	ret
endp procadd

proc procsub
	pop [ReturnAdress]
	mov ax, [var1]
	mov [output], ax
	mov ax, [var2]
	sub [output], ax
	mov bx, [var1]
	cmp bx, [var2]
	jb negnumber ;if var1 is smaller than var2
	jmp finito
negnumber:
	mov [isnegoutput], 1
	neg [output]
finito:
	push [ReturnAdress] ;IGNORE_LINE
	ret
endp procsub

proc procdivision
	pop [ReturnAdress]
	xor dx, dx
	mov ax, [var1]
	cmp ax, [var2]
	jb var1ismallerthanvar2
	jmp cool
var1ismallerthanvar2:
	mov dx, offset ErrorMessage
	mov ah, 9h
	int 21h ;print error msg
	;im not able to do that at the moment, sry
	mov dl, 0ah
	mov ah, 2h
	int 21h
	mov [raised_error], 1
	jmp endprocdiv
cool:
	cmp [var2], 0
	je DivisionBy0
	mov ax, [var1]
	idiv [var2] ;idiv 
	mov [output], ax
	mov [leftover], dx 
	jmp endprocdiv
DivisionBy0:
	mov dx, offset DivBy0
	mov ah, 9h
	int 21h ;print error msg
	mov dl, 0ah
	mov ah, 2h
	int 21h
	mov [raised_error], 1
endprocdiv:
	push [ReturnAdress] ;IGNORE_LINE
	ret
endp procdivision

proc procmultiply
	pop [ReturnAdress]
	mov ax, [var1]
	imul [var2]
	mov [output], ax
	push [ReturnAdress] ;IGNORE_LINE
	ret
endp procmultiply

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
	mov [var1], 0
	mov [var2], 0
	mov [leftover], 0
	mov [action], 0
	mov [raised_error], 0
	mov [isnegoutput], 0

EnterMsg:
	mov dx, offset EnterMessage
	mov ah, 9h
	int 21h
	jmp Input1

Input1: ;reads characters
	push [var1]
	call input
	pop [var1]
	cmp [raised_error], 0
	jne restart
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
	cmp [action], 2Fh ;ascii for /
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
	cmp [raised_error], 0
	jne restart
;now the input has fully passed to var2

continue:
	xor ax, ax ;instead of doing it for every action
	cmp [action], 2Bh ;ascii for +
	je Adding
	cmp [action], 2Dh ;ascii for -
	je Subbing
	cmp [action], 2Fh ;ascii for /
	je Division
	cmp [action], 2Ah ;ascii for *
	je Multiply
	jmp NotCoolAction

Adding:
	call procadd
	jmp print
	
Subbing:
	call procsub
	cmp [raised_error], 0 ;if not equal, that means there is some error
	jne restart
	jmp print

Division:
	call procdivision
	cmp [raised_error], 0
	jne restart
	jmp print

Multiply:
	call procmultiply
	jmp print

;by now, in output there is the exact number I want to show
;if isnegoutput is 0, the output is positive
;if isnegoutput is 1, the output is negative

print:
	mov dl, '='
	mov ah, 2h
	int 21h
	cmp [output], 0
	jb negPrint
	cmp [isnegoutput], 0
	jne negPrint
	jmp justprint
negPrint:
	mov dl, '-'
	mov ah, 2h
	int 21h
justprint:
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