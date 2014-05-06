include io.asm
stack segment stack
	dw 128 dup (?)
stack ends

HEAP_SIZE EQU 512
NIL EQU 0

el struc
	string db 8 dup (' ')
	num dw 0
	next dw 0
el ends

heap segment 'code'
	assume cs: heap
	
	heap_head dw ?
	dw HEAP_SIZE dup (?)
	List dw NIL
	
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
		
		mov Di, ES:heap_head
		mov Bx, Di
		New_loop:
			mov Bx, ES:[Bx]
			cmp Bx, NIL
				je New_Err
			loop New_loop
		
		New_back:
			mov ES:heap_head, Bx

		pop ES
		pop Cx
		pop Bx
	ret
	New_Err:
		cmp Cx, 0
			je New_back
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
	Link el <>
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
	
	Init proc
		call far ptr Init_heap
	ret
	Init endp
		
	Read proc
		push Ax
		push Cx
		push Di
		push ES
		
		mov Cx, 9
		mov Ax, '.'
		push Ax
		mov Ax, 0
		
		Read_inloop:
			inch Bl
			cmp Bl, ','
				je Read_write2Buffer
			cmp Bl, '.'
				je Read_write2Buffer
			cmp Cx, 1
				je Read_err
			push Bx
			loop Read_inloop
		
		Read_write2Buffer:
		mov Cx, 9
		mov Ax, data
		mov ES, Ax
		lea Di, Buffer+7
		std
		Read_endword:
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
		pop Cx
		pop Ax
	ret
	Read_err:
		lea Dx, errInput
		outstr
		newline
		finish
	Read endp
	
	CreateEl proc
		mov Link.num, Cx
		
		push Cx
		push Si
		push Di
		push ES
		
		mov Cx, data
		mov ES, Cx
		
		cld
		mov Cx, 4
		lea Si, Buffer
		lea Di, Link
		rep movsw
		
		pop ES
		pop Di
		pop Si
		pop Cx
	ret
	CreateEl endp
	
	Add2List proc
		push Bx
		push Cx
		push Si
		push Di
		push Bp
		push ES
		
		mov Bx, heap
		mov ES, Bx
		
		cld
		mov Bx, ES:List
		cmp Bx, NIL
			je Add2List_pushFirst
		
		
		Add2List_findPlace:
			mov Cx, 8
			mov Di, Bx
			lea Si, Link
			repe cmpsb
				je Add2List_end
				jb Add2List_push
			cmp ES:[Bx].next, NIL
				je Add2List_pushEnd
			mov Bp, Bx
			mov Bx, ES:[Bx].next
			jmp Add2List_findplace
		
		Add2List_push:
			cmp Bx, ES:List
				je Add2List_pushFirst
			call far ptr New
			mov ES:[Bp].next, Di
			mov ES:[Di].next, Bx
			mov Cx, 5
			lea Si, Link
			rep movsw
			jmp Add2List_end
			
		Add2List_pushEnd:
			call far ptr New
			mov ES:[Bx].next, Di
			mov ES:[Di].next, NIL
			mov Cx, 5
			lea Si, Link
			rep movsw
			jmp Add2List_end
			
		Add2List_pushFirst:
			call far ptr New
			mov ES:List, Di
			mov ES:[Di].next, Bx
			mov Cx, 5
			lea Si, Link
			rep movsw
			
		Add2List_end:
		pop ES
		pop Bp
		pop Di
		pop Si
		pop Cx
		pop Bx
	ret
	Add2List endp
	
	WriteStrings proc
		push Ax
		push Bx
		push Cx
		push Si
		push ES
			
			mov Bx, heap
			mov ES, Bx
			
			mov Bx, ES:List
			cmp Bx, NIL
				je WriteStrings_end
			
			WriteStrings_loop:
				mov Cx, 8
				mov Si, 0
				WriteString_begin:
					mov Al, ES:[Bx].string[Si]
					cmp Al, ' '
						je WriteString_miss
						outch Al
					WriteString_miss:
						inc Si 
					loop WriteString_begin
				outch '('
				outint ES:[BX].num
				outch ')'
				outch ' '
				cmp ES:[Bx].next, NIL
					je WriteStrings_end	
				mov Bx, ES:[Bx].next
				jmp WriteStrings_loop
		
		WriteStrings_end:
		pop ES
		pop Si
		pop Cx
		pop Bx
		pop Ax
	ret
	WriteStrings endp
start:
	mov ax,data
	mov ds,ax
	mov ES, Ax
	
	call Init
	mov Cx, 0
	L:
		call Read
		inc Cx 
		call CreateEl
		call Add2List
		cmp Bl, '.'
			je Readed
		jmp L
	Readed:
		call WriteStrings
	
	newline
	finish
code ends
    end start 