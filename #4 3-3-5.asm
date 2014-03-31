; ?a?? a??aa, ? c?? i a ia?? aaa???, c?a ?aai ??a? ?i??,
; a? a ?? ? ?a ???i??? ????a????.

include io.asm

stack segment stack
	dw 128 dup (?)
stack ends

data segment
	input db 100 dup (?), '$'
	output db 100 dup (?), '$'
	nums db 256 dup (0)
	inputLength dw 0
	result db 0
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
	L_read_Start:
		inch Al
		cmp Al, '.'
			je short L_read_End

		inc inputLength
		mov input[Bx], Al
		inc Bx
		jmp L_read_Start
	L_read_End:
		mov input[Bx], '$' ; set end of string
	; </code>

	; <restore>
		pop Bx
		pop Ax
	; </restore>
	ret
	Read endp
	
	; input:
	; Al: symbol code
	; return (bool)Al. If true then `1` else `0`
	isBigLatin proc
	; <code>
		cmp Al, 'A'
			jb L_isBigLatin_False
		cmp Al, 'Z'
			ja L_isBigLatin_False
		mov Al, 1 ; True
		ret
		L_isBigLatin_False:
			mov Al, 0
			ret
	; </code>
	isBigLatin endp
	
	; input:
	; Al: symbol code
	; return (bool)Al. If true then `1` else `0`
	isSmallLatin proc
	; <code>
		cmp Al, 'a'
			jb L_isSmallLatin_False
		cmp Al, 'z'
			ja L_isSmallLatin_False
		mov Al, 1 ; True
		ret
		L_isSmallLatin_False:
			mov Al, 0
			ret
	; </code>
	isSmallLatin endp
	
	; input:
	; Al: symbol code
	; return (bool)Al. If true then `1` else `0`
	isLatin proc
	; <backup>
		push Bx
	; </backup>
	
	; <code>
		mov Bx, Ax
		call isBigLatin
			cmp Al, 1
				je short L_isLatin_True
				
		mov Ax, Bx
		call isSmallLatin
			cmp Al, 1
				je short L_isLatin_True
		
		mov Al, 0 ; False
		jmp short L_isLatin_End
		
		L_isLatin_True:
			mov Al, 1
			
		L_isLatin_End:
	; </code>
	
	; <restore>
		pop Bx
	; </restore>
	ret
	isLatin endp
	
	true proc
	; <backup>
		push Ax
		push Bx
		push Cx
		push Dx
	; </backup>
	
	; <default>
		mov Ax, 0
		mov Bx, 0
		mov Cx, inputLength
		mov Dx, 10
	; </default>
	
	; <code>
	mov result, 1
		L_true_L:
		
			mov Al, input[Bx]
			
			mov Dh, Al
			call isBigLatin
				cmp Al, 0
					je short L_true_NotBigLetter
			
			mov Al, Dh
			mov Ah, 0
			div Dl
			add Ah, '0'
			jmp short L_true_End
			
			L_true_NotBigLetter:
				mov Ah, Dh
			L_true_End:
				mov output[Bx], Ah
				inc Bx
			loop L_true_L
	; </code>
	
	; <restore>
		pop Dx
		pop Cx
		pop Bx
		pop Ax
	; </restore>
	ret
	true endp
	
	false proc
	; <backup>
		push Bp
		push Bx
		push Cx
		push Si
	; </backup>
	
	; <default>
		mov Bp, 0
		mov Bx, 0
		mov Cx, inputLength
		mov Si, 0
	; </default>
	
	; <code>
	mov result, 2
		L_false_L1:
			mov Bl, input[Si]
			inc nums[Bx]
			inc Si
			loop L_false_L1
		
		mov Bl, 0
		mov Si, 0
		L_false_L2:
			mov Bl, input[Si]
			cmp nums[Bx], 1
				jne L_false_End
			mov output[Bp], Bl
			inc Bp
			inc nums[Bx]
			L_false_End:
				inc Si
			loop L_false_L2
	; </code>
	
	; <restore>
		pop Si
		pop Cx
		pop Bx
		pop Bp
	; </restore>
	
	ret
	false endp
	
	print proc
	; <backup>
		push Dx
	; </backup>
	
	; <default>
		mov Dx, 0
	; </default>
	
	; <code>
		mov Dl, result
		outint Dx
		outch ':'
		outch ' '
		lea Dx, output
		outstr
		newline
	; </code>
	
	; <restore>
		pop Dx
	; </restore>
	ret
	print endp
	
start:
	mov ax,data
	mov ds,ax

	call Read
	
	lea Dx, input
	outstr
	newline
	
	
	mov Al, input
	call isLatin
		cmp Al, 0
			je short L_If_False
	
	mov Bx, inputLength
	dec Bl
	
	mov Al, input[Bx]
	call isLatin
		cmp Al, 0
			je short L_If_False
			
	call true
	jmp short L_End
	
	L_If_False:
		call false
		
	L_End:
		call print
    finish
code ends
    end start
	
