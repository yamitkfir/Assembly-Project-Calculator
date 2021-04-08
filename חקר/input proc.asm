;My Name
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	var dw 4000
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	mov ax, 10
	mul var
			
exit:
	mov ax, 4c00h
	int 21h
END start


