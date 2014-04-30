include io.asm
stack segment stack
	dw 128 dup (?)
stack ends

HEAP_SIZE EQU 512
NIL EQU 0

el struct
	left dd 0
	right dd 0
	num dw 0
	next dw 0
el ends

heap segment 'code'
	heap_head dw ?
	dw HEAP_SIZE dup (?) 
	
	Init_heap proc far
		push Ax
		push Cx
		push Si
		push ES
		
		mov Cx, heap
		mov ES, Cx
		
		mov Cx, HEAP_SIZE
		mov Ax, NIL
		mov Si, 2*HEAP_SIZE
		
		Init_heap_loop:
			mov ES:[Si], Ax
			mov Ax, Si
			sub Si, 2
			loop Init_heap_loop
		
		mov ES:heap_head, Ax
		
		pop ES
		pop Si
		pop Cx
		pop Ax
	ret
	Init_heap endp
	
	New proc far
		push Bx
		push Cx
		push ES
		
		mov Cx, heap
		mov ES, Cx
		
		mov Cx, 6
		
		mov Si, ES:heap_head
		mov Bx, Si
		New_loop:
			mov Bx, ES:[Bx]
			cmp Bx, NIL
				je New_Err
			loop New_loop
			
		mov ES:heap_head, Bx
		
		pop ES
		pop Cx
		pop Bx
	ret
	New_Err:
		lea Dx, ES:Err
		outstr
		newline
		finish
	new endp
	Err db 'Переполнение кучи$'
heap ends

data segment
	Buffer db 8 dup (' '), '$'
	errInput db 'Ошибка во входных данных$'
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
	
	Init proc
		call far ptr Init_heap
	ret
	Init endp
		
	Read proc
		push Ax
		push Di
		push ES
		
		mov Cx, 9
		mov Ax, '.'
		push Ax
		
		mov Ax, 0
		
		Read_inloop:
			inch Al
			cmp Al, '.'
				je Read_write2Buffer
			cmp Cx, 1
				je Read_err
			push Ax
			loop Read_inloop
		
		Read_write2Buffer:
		mov Cx, 9
		mov Ax, data
		mov ES, Ax
		lea Di, Buffer+7
		Read_endword:
		std
			pop Ax
			cmp Al, '.'
				je Read_space
			stosb
			loop Read_endword
			Read_space:
				mov Al, ' '
				rep stosb
		
		pop ES
		pop Di
		pop Ax
	ret
	Read_err:
		lea Dx, errInput
		outstr
		newline
		finish
	Read endp
start:
	mov ax,data
	mov ds,ax
	
	call Init
	call Read
	
	lea Dx, buffer
	outstr
	newline
    finish
code ends
    end start 