include io.asm
stack segment stack
	dw 128 dup (?)
stack ends

HEAP_SIZE EQU 512
NIL EQU 0

el struct
	first dw 0
	second dw 0
	third dw 0
	fourth dw 0
	num dw 0
	next dw 0
el ends

heap segment 'code'
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
				je short New_Err
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
	Empty db 8 dup ('A' - 1), '$'
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
			mov Al, 'A' - 1
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
	
	
	CompHash proc
		push Bx
		push Cx
		push Si
		
		mov Ax, 0
		mov Bx, 0
		mov Cx, 4
		mov Dx, 0
		mov Si, 26
		
		CompHash_loop:
			mul Si
			add Al, Buffer[Bx][Di]
			adc Ah, 0
			inc Bx
			sub Ax, 'A' - 1
			loop CompHash_loop
			
		pop Si
		pop Cx
		pop Bx
	ret
	CompHash endp
	
	CreateEl proc
		push Ax
		push Dx
		push Di
		
		mov Link.num, Cx
		
		mov Di, 0
		call CompHash
		mov Link.first, Dx
		mov Link.second, Ax
		
		mov Di, 4
		call CompHash
		mov Link.third, Dx
		mov Link.fourth, Ax
		
		pop Di
		pop Dx
		pop Ax
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
			je short Add2List_pushFirst
		;mov Bp, Bx
		
		
		Add2List_findPlace:
			mov Cx, 4
			mov Di, Bx
			lea Si, Link
			repe cmpsw
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
	
	Write4Symbol proc
		push Cx
		push Si
		
		mov Si, 26
		mov Cx, 4
		push Cx
		Write4Symbol_loop:
			cwd
			div Si
			cmp Dx, 0
				je WriteStrings_Null 
				add Dx, 'A' - 1
				push Dx
			WriteStrings_Null:
			mov Dx, 0
			loop Write4Symbol_loop
		Write4Symbol_loop2:
			pop Dx
			cmp Dx, 4
				je Write4Symbol_end
			outch Dl
			jmp Write4Symbol_loop2
		Write4Symbol_end:
		pop Si
		pop Cx
	ret
	Write4Symbol endp
	
	WriteStrings proc
		push Ax
		push Bx
		push Dx
		push ES
			
			mov Bx, heap
			mov ES, Bx
			
			mov Bx, ES:List
			cmp Bx, NIL
				je WriteStrings_end
			WriteStrings_loop:
				mov Dx, ES:[Bx].first
				mov Ax, ES:[Bx].second
				call Write4symbol
				
				mov Dx, ES:[Bx].third
				mov Ax, ES:[Bx].fourth
				call Write4symbol
				
				outch '('
				outint ES:[BX].num
				outch ')'
				outch ' '
				cmp ES:[Bx].next, NIL
					je short WriteStrings_end
					
				mov Bx, ES:[Bx].next
				jmp WriteStrings_loop
		
		WriteStrings_end:
		pop ES
		pop Dx
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
		
		push Cx
		lea Si, Buffer
		lea Di, Empty
		mov Cx, 8
		repe cmpsb
		pop Cx		
			je L
		
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