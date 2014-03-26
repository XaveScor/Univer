; Если текст, начиная с этой строки, читается нормально,
; то файл в правильной кодировке.

include io.asm

stack segment stack
	dw 128 dup (?)
stack ends

data segment
	input db 101 (?) ; last symbol - $
	inputLength db 0
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code

	; Read string from console, push to `input` var. Set `inputLength` length(input).
	Read proc
	; <backup>
		push Ax
		push Bx
	; </backup>
	
	; <default>
		mov Ax, 0
		mov Bx, 0
	; </default>
	
	; <code>
	readStart:
		inch Al
		cmp Al, '.'
			je readEnd
		
		inc inputLength
		mov input[Bx], Al
		add Bx, type input
		jmp readStart
	readEnd:
		mov input[Bx], '$' ; set end of string
	; </code>
	
	; <restore>
		pop Bx
		pop Ax
	; </restore>
	Read endp

start:
	mov ax,data
	mov ds,ax
	
	call Read

	lea Dx, input
	outstr
	
    finish
code ends
    end start 
