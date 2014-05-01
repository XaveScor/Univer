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
	
	CreateEl proc
		mov Link.num, Cx
		
		push Ax
		push Bx
		push Cx
		push Dx
		push Si
		
		mov Cx, 4
		mov Ax, 0
		mov Bx, 0
		mov Dx, 0
		mov Si, 26
		CreateEl_Left:
			mul Si
			add Al, Buffer[Bx]
			adc Ah, 0
			inc Bx
			sub Ax, 'A' - 1
			loop CreateEl_Left
		
		mov Link.first, Dx
		mov Link.second, Ax
		
		mov Cx, 4
		mov Ax, 0
		mov Bx, 0
		mov Dx, 0
		CreateEl_Right:
			mul Si
			add Al, Buffer[Bx + 4]
			adc Ah, 0
			inc Bx
			sub Ax, 'A' - 1
			loop CreateEl_Right
		
		mov Link.third, Dx
		mov Link.fourth, Ax
		
		pop Si
		pop Dx
		pop Cx
		pop Bx
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
		lea Si, Link.first
		
		mov Bx, ES:List
		mov Bp, Bx
		cmp Bx, NIL
			je short Add2List_push
		
		cld
		Add2List_findPlace:
			mov Cx, 4
			mov Di, Bx 
			repe cmpsw
				je short Add2List_end
				jb short Add2List_push
			cmp ES:[Bx].next, NIL
				je short Add2List_push
			mov Bp, Bx
			mov Bx, ES:[Bx].next
			jmp Add2List_findplace
		
		Add2List_push:
			call far ptr New
			mov ES:[Bp].next, Di
			mov ES:[Di].next, Bx
			mov Cx, 5
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
		Write4Symbol_loop:
			cwd
			div Si
			cmp Dx, 0
				jne WriteStrings_leftNull 
				add Dx, 'A' - 1
				outch Dl
			WriteStrings_leftNull:
			mov Dx, 0
			loop Write4Symbol_loop
		
		pop Si
		pop Cx
	ret
	Write4Symbol endp
	
	WriteStrings proc
		push Ax
		push Bx
		push Dx
		push ES
			
			mov Bx, ES:List
			WriteStrings_loop: 
				mov Dx, ES:[Bx].first
				mov Ax, ES:[Bx].second
				call Write4symbol
				
				mov Dx, ES:[Bx].third
				mov Ax, ES:[Bx].third
				call Write4symbol
				
				cmp ES:[Bx].next, NIL
					je short WriteStrings_end
				outch '('
				outint ES:[BX].num
				outch ')'
				outch ' '
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