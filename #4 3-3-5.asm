; …a«? a??aa, ­ c?­ i a ia®© aaa®??, c?a ?aai ­®a¬ «i­®,
; a® a ©« ? ?a ??«i­®© ?®¤?a®???.

include io.asm

stack segment stack
	dw 128 dup (?)
stack ends

data segment
	input db 101 dup (?) ; last symbol - $
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
	LreadStart:
		inch Al
		cmp Al, '.'
			je LreadEnd

		inc inputLength
		mov input[Bx], Al
		inc Bx
		jmp LreadStart
	LreadEnd:
		mov input[Bx], '$' ; set end of string
	; </code>

	; <restore>
		pop Bx
		pop Ax
	; </restore>
	ret
	Read endp

start:
	mov ax,data
	mov ds,ax

	call Read

    finish
code ends
    end start
	