;--------------------------------------------
; BASELIB - base64x.asm
; Copyright (c)2015,2016 Soffian Abdul Rasad
; All rights reserved. Read licence.txt
; For Linux64
;--------------------------------------------
; Compile : nasm -f elf64 thisfile.asm
; Link	  : ld thisfile.o -o thisfile
; Run	  : ./thisfile
;--------------------------------------------
global _start

section .data
blank   db '...',0ah,0
empty 	db 'The stack (assumed) empty...',0ah,0
two 	db 'Stack after two PUSHes...',0ah,0
one	db 'Stack after one POP...',0ah,0	
val1 	dq 45h    ;will push these two data onto the stack
val2 	dq 77h    ;and pop this one later

section .text
_start:
	push 42h
	push 45h
        push 77h
	
	sub r9,5h
	call dumpreg

	call prnline

        mov rax,5   ;see 5 items of stack (1 item = 8 bytes)
        call stackview	

        call prnline

        pop rcx
        call stackview
	
	call 	exitx

;----------------------------
;prnreg(1)
;Display 64-bit register
;Display formatted hex
;----------------------------
;RAX	: Register to display
;----------------------------
;Ret	: -
;Note	: 16-digit Hex format
;	: Unsigned
;----------------------------
align 8
prnreg:
	push	rdi
	push	rax
	push	rcx
	push	rbx
	sub	rsp,16
	mov	rbx,rax
	cld
	mov	rdi,rsp
	xor	rax,rax
	mov	ecx,16
.begin: shld	rax,rbx,4
	add	al,'0'
	rol	rbx,4
	cmp	al,'9'
	jbe	.go
	add	al,7	
.go:	stosb
	xor	al,al
	sub	rcx,1
	jnz	.begin
	mov	ebx,16
	mov	rax,rsp
	call	prnstr
	add	rsp,16
	pop	rbx
	pop	rcx
	pop	rax
	pop	rdi
	ret
;--------------------------------
;prnregd(1)
;Display signed 64-bit Register
;--------------------------------
;RAX	: Register to display
;--------------------------------
;Ret	: -
;Note	: 19-digit decimal format
;--------------------------------
align 8
prnregd:
	push	rax
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rbx
	sub	rsp,32
	mov	rbx,19
	mov	rsi,rax
	test	rax,rax
	jns	.nop
	neg	rax
.nop:	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,10
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	dec	rdi
	mov	[rdi],dl
	sub	rbx,1
	jnz	.go
	dec	rdi
	mov	byte[rdi],'+'
	test	rsi,rsi
	jns	.nope
	mov	byte[rdi],'-'
.nope:	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rbx
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;--------------------------------
;prnregdu(1)
;Display unsigned 64-bit Register
;--------------------------------
;RAX	: Register to display
;--------------------------------
;Ret	: -
;Note	: 20-digit decimal format
;--------------------------------
align 8
prnregdu:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	push	rbx
	sub	rsp,32
	mov	rbx,20
	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,10
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	sub	rdi,1
	mov	[rdi],dl
	sub	rbx,1
	jnz	.go
	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rbx
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;------------------------------------
;dumpreg(1)
;Display Register Dump
;------------------------------------
;Arg	: Push type of display;
;	  0 - unsigned hex
;	  1 - unsigned int
;	  2 - signed int
;------------------------------------
;Ret	: -
;Note	: RIP doesn't count argument
;	: Arg must follow tightly
;------------------------------------
align 8
dumpreg:
	push	rbp
	mov	rbp,rsp
	push	rdx
	push	rcx
	push	rbx
	push	rax
	push	r15
	push	r14 
	push	r13 
	push	r12 
	push	r11 
	push	r10 
	push	r9 
	push	r8
	push	rdi
	push	rsi 
	push	rdx 
	push	rcx 
	push	rbx 
	push	rax
	mov	rbx,.disp
	mov	rdx,[rbp+16]
	mov	eax,'RAX|'
	pop	rcx
	call	rbx
	mov	eax,'RBX|'
	pop	rcx
	call	rbx
	mov	eax,'RCX|'
	pop	rcx
	call	rbx
	call	prnline
	mov	eax,'RDX|'
	pop	rcx
	call	rbx
	mov	eax,'RSI|'
	pop	rcx
	call	rbx
	mov	eax,'RDI|'
	pop	rcx
	call	rbx
	call	prnline
	mov	eax,'RBP|'
	mov	rcx,[rbp]
	call	rbx
	mov	eax,'RSP|'
	lea	rcx,[rbp+24]
	call	rbx
	mov	eax,'R8 |'
	pop	rcx
	call	rbx
	call	prnline
	mov	eax,'R9 |'
	pop	rcx
	call	rbx
	mov	eax,'R10|'
	pop	rcx
	call	rbx
	mov	eax,'R11|'
	pop	rcx
	call	rbx
	call	prnline
	mov	eax,'R12|'
	pop	rcx
	call	rbx
	mov	eax,'R13|'
	pop	rcx
	call	rbx
	mov	eax,'R14|'
	pop	rcx
	call	rbx
	call	prnline
	mov	eax,'R15|'
	pop	rcx
	call	rbx
	mov	eax,'RIP|'
	mov	rcx,[rbp+8]
	sub	rcx,7  ;8 in DLL/SO
	call	rbx
	call	prnline
	pop	rax
	pop	rbx
	pop	rcx
	pop	rdx
	mov	rsp,rbp
	pop	rbp
	ret	8
.disp:	call	prnstreg
	mov	rax,rcx
	cmp	rdx,2
	ja	.def
	cmp	rdx,0
	je	.def
	cmp	rdx,2
	je	.2
	cmp	rdx,1
	je	.1
	jmp	.nxt
.2:	call	prnregd
	jmp	.nxt
.1:	call	prnregdu
	jmp	.nxt
.def:	call	prnreg
.nxt:	call	prnspace
	retn
;-------------------------
;dumpseg
;Display segment registers
;-------------------------
;Arg	: -
;-------------------------
;Ret	: -
;Note	: -
;-------------------------
align 8
dumpseg:
	push	rax
	mov	eax,'CS| '
	call	prnstreg
	mov	eax,cs
	call	.next
	call	prnspace
	mov	eax,'DS| '
	call	prnstreg
	mov	eax,ds
	call	.next
	mov	al,' '
	call	prnchr
	mov	eax,'SS| '
	call	prnstreg
	mov	eax,ss
	call	.next
	mov	al,' '
	call	prnchr
	mov	eax,'ES| '
	call	prnstreg
	mov	eax,es
	call	.next
	call	prnspace
	mov	eax,'FS| '
	call	prnstreg
	mov	eax,fs
	call	.next
	call	prnspace
	mov	eax,'GS| '
	call	prnstreg
	mov	eax,gs
	call	.next
	pop	rax
	ret
.next:	cmp	rax,0xf
	ja	.ok
	push	'0'
	call	prnchrs
.ok:	call	prnhexu
	ret
;-----------------------
;flags(1)
;Display RFLAG
;-----------------------
;Arg	: pushfq
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
flags:
	push	rcx
	push	rbx 
	push	rax
	cld
	sub	rsp,16
	mov	rax,'ODI SZ A'
	mov	rbx,0x0a43205020
	xor	ecx,ecx
	mov	[rsp],rax
	mov	[rsp+8],rbx
	mov	rax,rsp
	call	prnstrz
	mov	ebx,11
	mov	rax,[rsp+8*6]
	call	bitfield
	add	rsp,16
	pop	rax
	pop	rbx
	pop	rcx
	ret	8
;--------------------------------
;stackview(1)
;Display stack
;--------------------------------
;RAX	: Number of items to view
;--------------------------------
;Ret	: -
;Note	: content |hex_address
;	: * Top of Stack(TOS)
;	: 1 item = 8 bytes
;--------------------------------
align 8
stackview:
	push	rdx
	push	rcx
	push	rax
	cmp	rax,0
	jle	.done
	mov	rcx,rax
	lea	rdx,[rsp+rax*8+8*3]
.again: mov	rax,[rdx]
	call	prnreg
	mov	rax,' |'
	call	prnstreg
	sub	rdx,8
	mov	rax,rdx
	add	rax,8
	call	prnreg
	sub	rcx,1
	jz	.ok
	call	prnline
	jmp	.again
.ok:	mov	eax,0x0A2A
	call	prnstreg
.done:	pop	rax
	pop	rcx
	pop	rdx
	ret
;--------------------------
;memview(2)
;View memory dump
;--------------------------
;RBX	: size (+up,-down)
;RAX	: label,address
;--------------------------
;Ret	: -
;Note	: Leftmost is MSB
;--------------------------
align 8
memview:
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	push	rdx
	xor	rdx,rdx
	test	rbx,rbx
	jns	.up
	mov	rdx,1
	neg	rbx
	sub	rax,8
.up:	mov	rcx,rbx
.next:	mov	rdi,7
.final: mov	rsi,rax
	xor	rax,rax
.again: mov	al,[rsi+rdi]
	cmp	al,0xf
	ja	.skip
	push	'0'
	call	prnchrs
.skip:	call	prnhexu
	call	prnspace
	sub	rdi,1
	jns	.again
	push	'|'
	call	prnchrs
	mov	rax,rsi
	call	prnreg
	call	prnline
	add	rax,8
	test	rdx,rdx
	jz	.ok
	sub	rax,16
.ok:	sub	rcx,8
	jz	.done
	js	.done
	cmp	rcx,8
	jge	.next
	mov	rdi,8
	sub	rdi,rcx
	xchg	rcx,rdi
	sub	rdi,1
.pad:	mov	rax,'   '
	call	prnstreg
	loop	.pad
	mov	rax,rsi
	test	edx,edx
	jnz	.neg
	add	rax,8
	jmp	.final
.neg:	sub	rax,8
	jmp	.final
.done:	pop	rdx
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax
	ret
;---------------------------------
;memviewc(2)
;View memory dump
;---------------------------------
;RBX	: size
;RAX	: label,address
;---------------------------------
;Ret	: -
;Note	: Leftmost is LSB
;	: Emphasis on strings
;---------------------------------
align 8
memviewc:
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	push	rdx
	mov	rcx,rbx
.go:	mov	rsi,rax
	mov	rbx,8
.final: call	prnreg
	mov	rax,'| '
	call	prnstreg
	mov	rdi,rsi
.again: mov	al,[rsi]
	mov	dl,[rsi]
	call	chr_isalpha
	test	rax,rax
	jz	.nope
	mov	al,dl
	call	prnchr
	call	prnspace
	jmp	.next
.nope:	mov	al,dl
	cmp	al,0xf
	ja	.full
	push	'0'
	call	prnchrs
.full:	call	prnhexu
.next:	call	prnspace
	inc	rsi
	sub	rbx,1
	jnz	.again
	mov	rax,rdi
	add	rax,8
	call	prnline
	sub	rcx,8
	jz	.done
	js	.done
	cmp	rcx,8
	jge	.go
	mov	rbx,rcx
	jmp	.final
.done:	pop	rdx
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax
	ret
;----------------------------
;mem_reset(2)
;Clear memory of RBX bytes
;----------------------------
;RBX	: size/bytes to clear
;RAX	: offset / pointer
;----------------------------
;Ret	: -
;Note	: Clear by bytes
;----------------------------
align 8
mem_reset:
	push	rdi
	push	rcx
	push	rax
	mov	rcx,rbx
	mov	rdi,rax
	mov	al,0
	rep	stosb
	pop	rax
	pop	rcx
	pop	rdi
	ret
;----------------------------
;mem_set(3)
;Set memory of RBX bytes
;----------------------------
;CL	: Set byte to use
;RBX	: size/bytes to set
;RAX	: offset / pointer
;----------------------------
;Ret	: -
;Note	: Set by bytes
;----------------------------
align 8
mem_set:
	push	rdi
	push	rcx
	push	rax
	push	rdx
	mov	dl,cl
	mov	rcx,rbx
	mov	rdi,rax
	mov	al,dl
	rep	stosb
	pop	rdx
	pop	rax
	pop	rcx
	pop	rdi
	ret
;-----------------------------------
;mem_insertr(2)
;Insert register content into memory
;-----------------------------------
;RBX	: Value(s) to insert
;RAX	: Memory location
;-----------------------------------
;Ret	: -
;Note	: -
;-----------------------------------
align 8
mem_insertr:
	cmp	rbx,0
	jnz	.ok
	ret
.ok:	push	rdi
	push	rax
	push	rbx
	cld
	mov	rdi,rax
.next:	xor	rax,rax
	shld	rax,rbx,8
	test	al,al
	jz	.nxt
.norm:	stosb
.nxt:	shl	rbx,8
	jnz	.next
.done:	pop	rbx
	pop	rax
	pop	rdi
	ret
;----------------------------
;mem_copy(3)
;Copy memory content of RCX bytes
;----------------------------
;RCX	: Number of bytes to copy
;RBX	: Source pointer
;RAX	: Destination pointer
;----------------------------
;Ret	: -
;Note	: -
;----------------------------
align 8
mem_copy:
	push	rsi
	push	rdi
	push	rax
	push	rcx
	mov	rdi,rax
	mov	rsi,rbx
	rep	movsb
	pop	rcx
	pop	rax
	pop	rdi
	pop	rsi
	ret
;----------------------------------
;mem_load(1)/2
;Load a file to memory
;----------------------------------
;RAX	: Filename path string
;----------------------------------
;Ret	: RAX - block pointer
;	: RBX - Size
;Note	: Should re-claim memory
;	: File name must be 0-ended
;----------------------------------
align 8
mem_load:
	push	rbp
	mov	rbp,rsp
	push	rdx
	push	rcx
	mov	rbx,0
	call	file_open
	mov	rdx,rax     ;file handle
	call	file_size
	mov	rcx,rax     ;file size
	call	mem_alloc
	mov	rbx,rax     ;buffer
	mov	rax,rdx     ;file ptr
	call	file_read
	mov	rax,rdx
	call	file_close
	mov	rax,rbx     ;block ptr
	mov	rbx,rcx     ;size
	pop	rcx
	pop	rdx
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------------
;opsize(2)/1
;Get size between 2 labels
;----------------------------------
;RBX	: Label (reg64,add64)
;RAX	: Label (reg64,add64)
;----------------------------------
;Ret	: Size
;Note	: Order of label is irrelevant
;----------------------------------
align 8
opsize:
	sub	rax,rbx
	jns	.ok
	neg	rax
.ok:	ret
;----------------------------------
;opcode(2)
;Encode instrns between 2 labels
;----------------------------------
;RAX	: Label 1 (first/lead label)
;RBX	: Label 2
;----------------------------------
;Ret	: -
;Note	: Label 1 must be the first
;	: Leftmost is MSB
;----------------------------------
align 8
opcode:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	mov	rdx,rax
	call	opsize
	test	rax,rax
	jz	.quit
	mov	rcx,rax
	mov	rbx,rdx
	add	rbx,rcx
	xor	eax,eax
	sub	rbx,1
.again: mov	al,[rbx]
	cmp	al,0xf
	ja	.nxt
	push	'0'
	call	prnchrs
.nxt:	call	prnhexu
	call	prnspace
	sub	rbx,1
	loop	.again
.quit:	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret
;-----------------------------
;prnint(1)
;Display Signed 64-bit Decimal
;-----------------------------
;RAX	: Value to display
;-----------------------------
;Ret	: -
;Note	: -
;-----------------------------
align 8
prnint:
	push	rax
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	sub	rsp,32
	mov	rsi,rax
	test	rax,rax
	jns	.nop
	neg	rax
.nop:	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,10
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	sub	rdi,1
	mov	[rdi],dl
	test	rax,rax
	jnz	.go
	test	rsi,rsi
	jns	.done
	sub	rdi,1
	mov	byte[rdi],'-'
.done:	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;prnintu(1)
;Display unsigned 64-bit Decimal
;-------------------------------
;RAX	: Value to display
;-------------------------------
;Ret	: -
;Note	: -
;-------------------------------
align 8
prnintu:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	sub	rsp,32
	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,10
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	sub	rdi,1
	mov	[rdi],dl
	test	rax,rax
	jnz	.go
	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;------------------------------------
;prnhex(1)
;Display 64-bit Signed Hexadecimal
;------------------------------------
;RAX	: Value to display
;------------------------------------
;Ret	: -
;Note	: Imm must be in valid format
;------------------------------------
align 8
prnhex:
	push	rdi
	push	rax
	push	rcx
	push	rbx
	sub	rsp,32
	mov	rcx,rax
	test	rax,rax
	jns	.ok
	neg	rax
.ok:	mov	rbx,rax
	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	xor	rax,rax
.begin: shrd	rax,rbx,4
	shr	rax,60
	add	al,'0'
	shr	rbx,4
	cmp	al,'9'
	jbe	.go
	add	al,7	
.go:	sub	rdi,1
	mov	[rdi],al
	xor	al,al
	test	rbx,rbx
	jnz	.begin
	test	rcx,rcx
	jns	.done
	dec	rdi
	mov	byte[rdi],'-'
.done:	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rbx
	pop	rcx
	pop	rax
	pop	rdi
	ret
;-------------------------------------
;prnhexu(1)
;Display 64-bit Unsigned Hexadecimal
;-------------------------------------
;RAX	: Value to display
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;-------------------------------------
align 8
prnhexu:
	push	rdi
	push	rax
	push	rbx
	sub	rsp,32
	mov	rbx,rax
	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	xor	rax,rax
.begin: shrd	rax,rbx,4
	shr	rax,60
	add	al,'0'
	shr	rbx,4
	cmp	al,'9'
	jbe	.go
	add	al,7	
.go:	sub	rdi,1
	mov	[rdi],al
	xor	al,al
	test	rbx,rbx
	jnz	.begin
	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rbx
	pop	rax
	pop	rdi
	ret
;-------------------------------------
;prnoct(1)
;Display 64-bit Octal (signed)
;-------------------------------------
;RAX	: Value to display
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;-------------------------------------
align 8
prnoct:
	push	rax
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	sub	rsp,32
	mov	rsi,rax
	test	rax,rax
	jns	.nop
	neg	rax
.nop:	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,8
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	dec	rdi
	mov	[rdi],dl
	test	rax,rax
	jnz	.go
	test	rsi,rsi
	jns	.done
	dec	rdi
	mov	byte[rdi],'-'
.done:	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------------
;prnoctu(1)
;Display 64-bit Octal (unsigned)
;-------------------------------------
;RAX	: Value to display.
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;-------------------------------------
align 8
prnoctu:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	sub	rsp,32
	mov	rdi,rsp
	add	rdi,31
	mov	byte[rdi],0
	mov	rcx,8
.go:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	sub	rdi,1
	mov	[rdi],dl
	test	rax,rax
	jnz	.go
	mov	rax,rdi
	call	prnstrz
	add	rsp,32
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------------
;prnbin(1)
;Convert to & Display Signed Binary
;-------------------------------------
;RAX	: Value to display.
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;-------------------------------------
align 8
prnbin:
	push	rax
	push	rcx			
	push	rdx
	push	rdi 
	sub	rsp,80
	mov	rdx,rax
	xor	rcx,rcx
	cld
	mov	rdi,rsp
	test	rdx,rdx
	jnz	.ok
	mov	al,'0'
	stosb
	jmp	.done
.ok:	test	rax,rax
	jns	.ok2
	mov	al,'-'
	stosb
	neg	rdx
.ok2:	bsr	rcx,rdx
.start: mov	al,'0'
	bt	rdx,rcx
	jnc	.uno
	mov	al,'1'
.uno:	stosb
	sub	rcx,1
	jns	.start
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,80
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------------
;prnbinu(1)
;Convert to & Display unsigned Binary
;-------------------------------------
;RAX	: Value to display
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;-------------------------------------
align 8
prnbinu:
	push	rax
	push	rcx			
	push	rbx			
	push	rdx		
	push	rdi 
	sub	rsp,64
	mov	rdx,rax
	cld
	mov	rdi,rsp
	test	rax,rax
	jnz	.ok
	mov	al,'0'
	stosb
	mov	ebx,1
	jmp	.done
.ok:	bsr	rcx,rdx
	xor	rbx,rbx ;index
.start: mov	al,'0'
	bt	rdx,rcx
	jnc	.uno
	mov	al,'1'
.uno:	stosb
	add	rbx,1
	sub	rcx,1
	jns	.start
.done:	mov	rax,rsp
	call	prnstr
	add	rsp,64
	pop	rdi
	pop	rdx
	pop	rbx 
	pop	rcx 
	pop	rax
	ret
;------------------------------------
;prnbinf(3)
;Convert to & display Unsigned Binary
;with formatting options
;------------------------------------
;RCX	: Separator. 1-with, 0-without
;RBX	: Trim. 1-trim. 0-not trimmed
;RAX	: Value to display
;------------------------------------
;Ret	: -
;Note	: Imm must be in valid format
;------------------------------------
align 8
prnbinf:
	push	rax
	push	rcx
	push	rbx
	push	rdx
	push	rdi 
	push	rsi 
	sub	rsp,16*5
	mov	rdx,rax 	
	cld
	mov	rdi,rsp 	
	mov	esi,63
	cmp	rbx,1	;trim
	jne	.start
	test	rax,rax
	jnz	.ok
	mov	al,'0'
	stosb
	mov	ebx,1
	jmp	.done
.ok:	bsr	rsi,rdx
.start: xor	rbx,rbx
.nxt:	mov	al,'0'
	bt	rdx,rsi
	jnc	.uno
	mov	al,'1'
.uno:	stosb
	add	rbx,1
	sub	rsi,1
	js	.done
	cmp	rcx,1	;separator
	jne	.nxt
.space: cmp	rsi,47
	je	.spc
	cmp	rsi,31
	je	.spc
	cmp	rsi,15
	je	.spc
	jmp	.nxt
.spc:	mov	al,' '
	stosb	
	add	rbx,1
	jmp	.nxt
.done:	mov	rax,rsp
	call	prnstr
	add	rsp,16*5
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rbx 
	pop	rcx 
	pop	rax
	ret
;-------------------------------------
;prnbinb(1)
;Convert to & Display unsigned Binary
;-------------------------------------
;RAX	: Value to display
;-------------------------------------
;Ret	: -
;Note	: Imm. must be in valid format
;	; Uses 8-bit separators
;-------------------------------------
align 8
prnbinb:
	push	rax
	push	rbx
	push	rdx		
	push	rdi 
	sub	rsp,86
	xor	rbx,rbx
	mov	rdx,rax
	cld
	mov	rdi,rsp
	test	rax,rax
	jnz	.start
	mov	al,'0'
	stosb
	mov	rbx,1
	jmp	.done
.start: mov	al,'0'
	shl	rdx,1
	jnc	.uno
	mov	al,'1'
.uno:	stosb
	cmp	rbx,7
	je	.nxt
	cmp	rbx,15
	je	.nxt
	cmp	rbx,23
	je	.nxt
	cmp	rbx,31
	je	.nxt
	cmp	rbx,39
	je	.nxt
	cmp	rbx,47
	je	.nxt
	cmp	rbx,55
	je	.nxt
	jmp	.ok2
.nxt:	mov	al,' '
	stosb
.ok2:	add	rbx,1
	cmp	rbx,71
	jnz	.start
.done:	mov	rax,rsp
	call	prnstr
	add	rsp,86
	pop	rdi
	pop	rdx
	pop	rbx 
	pop	rax
	ret
;------------------------------------
;fpbin(1)
;Display 64-bit Floating Point Binary
;------------------------------------
;RAX	: FP value to display
;------------------------------------
;Ret	: -
;Note	: -
;------------------------------------
align 8
fpbin:
	push	rdi
	push	rdx 
	push	rcx 
	push	rax
	push	rbx
	sub	rsp,16*5
	mov	rdx,rax
	cld
	mov	rdi,rsp
	mov	ecx,63
.prb0:	mov	al,'0'
	shl	rdx,1
	jnc	.tmp0
	mov	al,'1'
.tmp0:	stosb
	test	rcx,rcx
	jz	.prb1
	sub	rcx,1
	cmp	rcx,62
	je	.dot
	cmp	rcx,51
	je	.dot
	cmp	rcx,31
	je	.sep
	jmp	.prb0
.dot:	mov	al,'.'
	stosb
	jmp	.prb0
.sep:	mov	al,'-'
	stosb
	jmp	.prb0
.prb1:	mov	ebx,67
	mov	rax,rsp
	call	prnstr
	add	rsp,16*5
	pop	rbx
	pop	rax
	pop	rcx
	pop	rdx 
	pop	rdi
	ret
;------------------------------------
;fpbind(1)
;Display 32-bit Floating Point Binary
;------------------------------------
;EAX	: FP Value to display
;------------------------------------
;Ret	: -
;Note	: -
;------------------------------------
align 8
fpbind:
	push	rdi
	push	rdx 
	push	rcx 
	push	rax
	push	rbx
	sub	rsp,16*3
	mov	edx,eax
	cld
	mov	rdi,rsp
	mov	ecx,31
.prb0:	mov	al,'0'
	shl	edx,1
	jnc	.tmp0
	mov	al,'1'
.tmp0:	stosb
	test	ecx,ecx
	jz	.prb1
	sub	ecx,1
	cmp	ecx,30
	je	.dot
	cmp	ecx,22
	je	.dot
	jmp	.prb0
.dot:	mov	al,'.'
	stosb
	jmp	.prb0
.sep:	mov	al,'-'
	stosb
	jmp	.prb0
.prb1:	mov	ebx,34
	mov	rax,rsp
	call	prnstr
	add	rsp,16*3
	pop	rbx
	pop	rax
	pop	rcx
	pop	rdx 
	pop	rdi
	ret
;---------------------------------
;prndbl(1)
;Display unrounded REAL8 precision
;---------------------------------
;RAX	: Double value to display
;---------------------------------
;Ret	: -
;Note	: Use DQ for vars
;---------------------------------
align 8
prndbl:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,32
	mov	rcx,0x3ff0000000000000
	mov	rbx,0x3FB999999999999A
	mov	rdx,0x4024000000000000
	movq	xmm4,rcx
	movq	xmm2,rbx
	movq	xmm3,rdx
	xor	rsi,rsi
	cld
	mov	rdi,rsp
	bt	rax,63
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	rax,63
;----------------------
.zero:	mov	rbx,rax
	test	rax,rax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	rbx,52
	mov	rcx,1023
	cmp	rbx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	rbx,rcx
	test	rbx,rbx
	js	.small
	cmp	rbx,49
	ja	.big
;----------------------
.begin: movq	xmm0,rax
	movq	xmm1,rax
	mov	rax,0
	call	sse_round
	roundsd xmm0,xmm0,3
	subsd	xmm1,xmm0
	xor	rcx,rcx
	xor	rbx,rbx
	jmp	.int
;----------------------
.small: movq	xmm0,rax
	mov	rsi,rax
	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.c2:	mulsd	xmm0,xmm3
	add	edx,1
	comisd	xmm0,xmm4
	jc	.c2
	cmp	edx,16
	jb	.nope
	movq	rax,xmm0
	mov	rsi,-1
	jmp	.begin
.nope:	mov	rax,rsi
	xor	rsi,rsi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	rdx,rdx
	movq	xmm0,rax
	mov	rax,1
	call	sse_round
.c1:	mulsd	xmm0,xmm2
	add	edx,1
	comisd	xmm0,xmm3
	jnc	.c1
	movq	rax,xmm0
	jmp	.begin
;----------------------
.int:	mulsd	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3  ;10.0
	cvtsd2si rax,xmm0
	add	rcx,1
	add	rbx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4  ;1.0
	jnc	.int
.save:	pop	rax
	stosb
	sub	rcx,1
	jnz	.save
	cmp	rsi,-2
	je	.done
	mov	al,'.'
	stosb
	comisd	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	rbx,1
	jmp	.enote
;----------------------
.nxt:	test	rsi,rsi
	jns	.frac
	add	rbx,1
.frac:	mulsd	xmm1,xmm3
	movq	xmm0,xmm1
	roundsd xmm0,xmm0,3
	subsd	xmm1,xmm0
	cvtsd2si rax,xmm0
	add	al,30h
	stosb
	add	rbx,1
	cmp	rbx,16
	jne	.frac
;----------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.enote
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
;----------------------
.enote: test	rsi,rsi
	jz	.done
	mov	ax,'E+'
	test	rsi,rsi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2sd xmm0,rdx
	mov	rsi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,32
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;prndblr(1)
;Display rounded REAL8 precision
;---------------------------------
;RAX	: Double value to display
;---------------------------------
;Ret	: -
;Note	: Use DQ for vars
;---------------------------------
align 8
prndblr:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,32
	mov	rcx,0x3ff0000000000000
	mov	rbx,0x3FB999999999999A
	mov	rdx,0x4024000000000000
	movq	xmm4,rcx
	movq	xmm2,rbx
	movq	xmm3,rdx
	xor	rsi,rsi
	cld
	mov	rdi,rsp
	bt	rax,63
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	rax,63
;----------------------
.zero:	mov	rbx,rax
	test	rax,rax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	rbx,52
	mov	rcx,1023
	cmp	rbx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	rbx,rcx
	test	rbx,rbx
	js	.small
	cmp	rbx,49
	ja	.big
;----------------------
.begin: movq	xmm0,rax
	movq	xmm1,rax
	mov	rax,0
	call	sse_round
	roundsd xmm0,xmm0,3
	subsd	xmm1,xmm0
	xor	rcx,rcx
	xor	rbx,rbx
	jmp	.int
;----------------------
.small: movq	xmm0,rax
	mov	rsi,rax
	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.c2:	mulsd	xmm0,xmm3
	add	edx,1
	comisd	xmm0,xmm4
	jc	.c2
	cmp	edx,16
	jb	.nope
	movq	rax,xmm0
	mov	rsi,-1
	jmp	.begin
.nope:	mov	rax,rsi
	xor	rsi,rsi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	rdx,rdx
	movq	xmm0,rax
	mov	rax,1
	call	sse_round
.c1:	mulsd	xmm0,xmm2
	add	edx,1
	comisd	xmm0,xmm3
	jnc	.c1
	movq	rax,xmm0
	jmp	.begin
;----------------------
.int:	mulsd	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3  ;10.0
	cvtsd2si rax,xmm0
	add	rcx,1
	add	rbx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4  ;1.0
	jnc	.int
.save:	pop	rax
	stosb
	sub	rcx,1
	jnz	.save
	cmp	rsi,-2
	je	.done
	mov	al,'.'
	stosb
	comisd	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	rbx,1
	jmp	.enote
;----------------------
.nxt:	push	rdx
	test	rsi,rsi
	jns	 .n1
	add	rbx,1
.n1:	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.frac:	mulsd	xmm1,xmm3
	comisd	xmm1,xmm4
	jnc	.no
	add	rdx,1
	movq	xmm5,xmm1
	mulsd	xmm5,xmm3
	roundsd xmm5,xmm5,0
	comisd	xmm5,xmm3
	jnz	.no
	sub	rdx,1
.no:	add	rbx,1
	cmp	rbx,16
	jne	.frac
	xor	rcx,rcx
	movq	xmm0,xmm1
	roundsd xmm0,xmm0,0
.int2:	mulsd	xmm0,xmm2
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3
	cvtsd2si rax,xmm0
	add	rcx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4
	jnc	.int2
	test	rdx,rdx
	jz	.save2
.looop: push	'0'
	add	rcx,1
	sub	rdx,1
	jnz	.looop
.save2: pop	rax
	stosb
	sub	rcx,1
	jnz	.save2
	pop	rdx
;----------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.enote
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
;----------------------
.enote: test	rsi,rsi
	jz	.done
	mov	ax,'E+'
	test	rsi,rsi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2sd xmm0,rdx
	mov	rsi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,32
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;prnflt(1)
;Display unrounded REAL4 precision
;---------------------------------
;EAX	: Single value to display
;---------------------------------
;Ret	: -
;Note	: Use DD for vars
;---------------------------------
align 8
prnflt:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,16
	mov	ecx,0x3f800000
	mov	ebx,0x3DCCCCCD
	mov	edx,0x41200000
	movd	xmm4,ecx
	movd	xmm2,ebx
	movd	xmm3,edx
	xor	rsi,rsi
	cld
	mov	rdi,rsp
	bt	eax,31
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	eax,31
;----------------------
.zero:	mov	ebx,eax
	test	eax,eax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	ebx,23
	mov	ecx,127
	cmp	ebx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	ebx,ecx
	test	ebx,ebx
	js	.small
	cmp	ebx,19
	ja	.big
;----------------------
.begin: movd	xmm0,eax
	movd	xmm1,eax
	;mov	 eax,0
	;call	 sse_round
	roundss xmm0,xmm0,3
	subss	xmm1,xmm0
	xor	ecx,ecx
	xor	ebx,ebx
	jmp	.int
;----------------------
.small: movd	xmm0,eax
	mov	esi,eax
	xor	edx,edx
	mov	eax,0
	call	sse_round
.c2:	mulss	xmm0,xmm3
	add	edx,1
	comiss	xmm0,xmm4
	jc	.c2
	cmp	edx,7
	jb	.nope
	movd	eax,xmm0
	mov	esi,-1
	jmp	.begin
.nope:	mov	eax,esi
	xor	esi,esi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	edx,edx
	movd	xmm0,eax
	mov	eax,1
	call	sse_round
.c1:	mulss	xmm0,xmm2
	add	edx,1
	comiss	xmm0,xmm3
	jnc	.c1
	movd	eax,xmm0
	jmp	.begin
;----------------------
.int:	mov	eax,0
	call	sse_round
.i:	mulss	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundss xmm5,xmm5,3
	subss	xmm0,xmm5
	mulss	xmm0,xmm3  ;10.0
	cvtss2si eax,xmm0
	add	ecx,1
	add	ebx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comiss	xmm0,xmm4  ;1.0
	jnc	.i
.save:	pop	rax
	stosb
	sub	ecx,1
	jnz	.save
	cmp	esi,-2
	je	.done
	mov	al,'.'
	stosb
	comiss	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	ebx,1
	jmp	.enote
;----------------------
.nxt:	mov	eax,2
	call	sse_round
.frac:	mulss	xmm1,xmm3
	movq	xmm0,xmm1
	roundss xmm0,xmm0,3
	subss	xmm1,xmm0
	cvtss2si eax,xmm0
	add	al,30h
	stosb
	add	ebx,1
	cmp	ebx,7
	jne	.frac
;----------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.enote
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
;----------------------
.enote: test	esi,esi
	jz	.done
	mov	ax,'E+'
	test	esi,esi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2ss xmm0,edx
	mov	esi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,16
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;prnfltr(1)
;Display rounded REAL4 precision
;---------------------------------
;EAX	: Single value to display
;---------------------------------
;Ret	: -
;Note	: Use DD for vars
;---------------------------------
align 8
prnfltr:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,16
	mov	ecx,0x3f800000
	mov	ebx,0x3DCCCCCD
	mov	edx,0x41200000
	movd	xmm4,ecx
	movd	xmm2,ebx
	movd	xmm3,edx
	xor	rsi,rsi
	cld
	mov	rdi,rsp
	bt	eax,31
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	eax,31
;----------------------
.zero:	mov	ebx,eax
	test	eax,eax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	ebx,23
	mov	ecx,127
	cmp	ebx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	ebx,ecx
	test	ebx,ebx
	js	.small
	cmp	ebx,19
	ja	.big
;----------------------
.begin: movd	xmm0,eax
	movd	xmm1,eax
	roundss xmm0,xmm0,3
	subss	xmm1,xmm0
	xor	ecx,ecx
	xor	ebx,ebx
	jmp	.int
;----------------------
.small: movd	xmm0,eax
	mov	esi,eax
	xor	edx,edx
	mov	eax,0
	call	sse_round
.c2:	mulss	xmm0,xmm3
	add	edx,1
	comiss	xmm0,xmm4
	jc	.c2
	cmp	edx,7
	jb	.nope
	movd	eax,xmm0
	mov	esi,-1
	jmp	.begin
.nope:	mov	eax,esi
	xor	esi,esi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	edx,edx
	movd	xmm0,eax
	mov	eax,1
	call	sse_round
.c1:	mulss	xmm0,xmm2
	add	edx,1
	comiss	xmm0,xmm3
	jnc	.c1
	movd	eax,xmm0
	jmp	.begin
;----------------------
.int:	mov	eax,0
	call	sse_round
.i:	mulss	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundss xmm5,xmm5,3
	subss	xmm0,xmm5
	mulss	xmm0,xmm3  ;10.0
	cvtss2si eax,xmm0
	add	ecx,1
	add	ebx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comiss	xmm0,xmm4  ;1.0
	jnc	.i
.save:	pop	rax
	stosb
	sub	ecx,1
	jnz	.save
	cmp	esi,-2
	je	.done
	mov	al,'.'
	stosb
	comiss	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	ebx,1
	jmp	.enote
;----------------------
.nxt:	push	rdx
	xor	edx,edx
	mov	rax,0
	call	sse_round
.frac:	mulss	xmm1,xmm3
	comiss	xmm1,xmm4
	jnc	.no
	add	edx,1
	movq	xmm5,xmm1
	mulss	xmm5,xmm3
	roundss xmm5,xmm5,0
	comiss	xmm5,xmm3
	jnz	.no
	sub	edx,1
.no:	add	ebx,1
	cmp	ebx,7
	jne	.frac
	xor	ecx,ecx
	movq	xmm0,xmm1
	roundss xmm0,xmm0,0
.int2:	mulss	xmm0,xmm2
	movq	xmm5,xmm0
	roundss xmm5,xmm5,3
	subss	xmm0,xmm5
	mulss	xmm0,xmm3
	cvtss2si eax,xmm0
	add	ecx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comiss	xmm0,xmm4
	jnc	.int2
	test	edx,edx
	jz	.save2
.looop: push	'0'
	add	ecx,1
	sub	edx,1
	jnz	.looop
.save2: pop	rax
	stosb
	sub	ecx,1
	jnz	.save2
	pop	rdx
;----------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.enote
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
;----------------------
.enote: test	esi,esi
	jz	.done
	mov	ax,'E+'
	test	esi,esi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2ss xmm0,edx
	mov	esi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,16
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;prndble(2)
;Display REAL8 with decimal places
;---------------------------------
;RBX	: Decimal places.
;RAX	: Double value to display
;---------------------------------
;Ret	: -
;Note	: RBX must within reasonable range
;	: RBX cannot be 0 or negative
;	: Double is valid up to 16 digits
;	: Rounding used = nearest
;---------------------------------
align 8
prndble:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	push	rbp
	sub	rsp,64
	mov	rbp,rbx
	mov	rcx,0x3ff0000000000000
	mov	rbx,0x3FB999999999999A
	mov	rdx,0x4024000000000000
	movq	xmm4,rcx
	movq	xmm2,rbx
	movq	xmm3,rdx
	xor	rsi,rsi
	cld
	mov	rdi,rsp
	bt	rax,63
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	rax,63
;----------------------
.zero:	mov	rbx,rax
	test	rax,rax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	rbx,52
	mov	rcx,1023
	cmp	rbx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	rbx,rcx
	test	rbx,rbx
	js	.small
	cmp	rbx,49
	ja	.big
;----------------------
.begin: movq	xmm0,rax
	movq	xmm1,rax
	mov	rax,0
	call	sse_round
	roundsd xmm0,xmm0,3
	subsd	xmm1,xmm0
	xor	rcx,rcx
	xor	rbx,rbx
	jmp	.int
;----------------------
.small: movq	xmm0,rax
	mov	rsi,rax
	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.c2:	mulsd	xmm0,xmm3
	add	edx,1
	comisd	xmm0,xmm4
	jc	.c2
	cmp	edx,16
	jb	.nope
	movq	rax,xmm0
	mov	rsi,-1
	jmp	.begin
.nope:	mov	rax,rsi
	xor	rsi,rsi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	rdx,rdx
	movq	xmm0,rax
	mov	rax,1
	call	sse_round
.c1:	mulsd	xmm0,xmm2
	add	edx,1
	comisd	xmm0,xmm3
	jnc	.c1
	movq	rax,xmm0
	jmp	.begin
;----------------------
.int:	mulsd	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3  ;10.0
	cvtsd2si rax,xmm0
	add	rcx,1
	add	rbx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4  ;1.0
	jnc	.int
.save:	pop	rax
	stosb
	sub	rcx,1
	jnz	.save
	cmp	rsi,-2
	je	.done
	mov	al,'.'
	stosb
	comisd	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	rbx,1
	jmp	.enote
;----------------------
.nxt:	push	rdx
	test	rsi,rsi
	jns	.n1
	add	rbx,1
.n1:	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.frac:	mulsd	xmm1,xmm3
	comisd	xmm1,xmm4
	jnc	.no
	add	rdx,1
	movq	xmm5,xmm1
	mulsd	xmm5,xmm3
	roundsd xmm5,xmm5,0
	comisd	xmm5,xmm3
	jnz	.no
	sub	rdx,1
.no:	sub	rbp,1
	jnz	.frac
	xor	rcx,rcx
	movq	xmm0,xmm1
	roundsd xmm0,xmm0,0
.int2:	mulsd	xmm0,xmm2
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3
	cvtsd2si rax,xmm0
	add	rcx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4
	jnc	.int2
	test	rdx,rdx
	jz	.save2
.looop: push	'0'
	add	rcx,1
	sub	rdx,1
	jnz	.looop
.save2: pop	rax
	stosb
	sub	rcx,1
	jnz	.save2
	pop	rdx
;----------------------
.enote: test	rsi,rsi
	jz	.done
	mov	ax,'E+'
	test	rsi,rsi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2sd xmm0,rdx
	mov	rsi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,64
	pop	rbp
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------------------
;prndblx(1)
;Display extended precision (REAL10)
;----------------------------------------
;RAX	: The address of a DT in memory
;----------------------------------------
;Ret	: -
;Note	: Var should be initd to FP (0.0)
;	: Variable must be of type DT.
;	: Displays unrounded precision
;----------------------------------------
;Stack partitioning
;val	dt 0.0	  ;rbp-10
;v1	dt 0.0	  ;rbp-20
;v2	dt 0.0	  ;rbp-30
;exp	dq 0	  ;rbp-38
;ten	dq 10.0   ;rbp-46
;digit	dd 0	  ;rbp-50
;fstr	rb 30	  ;rbp-80
;save	rb 512	  ;rbp-592
;----------------------
align 8
prndblx:
	push	rbp
	mov	rbp,rsp
	sub	rsp,592
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rdx,0x4024000000000000
	mov	[rbp-46],rdx
	mov	qword[rbp-38],0
	fninit
	push	rax
	mov	rax,1
	call	fpu_precision
	pop	rax
	fldz
	fst	qword[rbp-10]
	fst	qword[rbp-20]
	fst	qword[rbp-30]
	fistp	dword[rbp-50]
	xor	rdx,rdx 	;index
	cld
	lea	rdi,[rbp-80]
	mov	rbx,rax
	mov	rax,[rbx]
	mov	[rbp-10],rax
	mov	ax,[rbx+8]
	mov	[rbp-2],ax
	xor	rbx,rbx
;--------------------------
.check: fld	tword[rbp-10]
	xor	rax,rax
	fxam
	fnstsw	ax
	and	eax,4500h
	cmp	eax,500h
	je	.err
	cmp	eax,100h
	je	.err
	cmp	eax,0
	je	.err
	bt	word[rbp-2],15
	jnc	.plus
	mov	al,'-'
	stosb
	btr	word[rbp-2],15
	fstp	st0
	fld	tword[rbp-10]
.plus:	fldz
	fcomip	st1
	jnz	.norm
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;--------------------------
.norm:	fxtract
	fstp	st0
	fistp	qword[rbp-38]
	mov	rax,[rbp-38]
	test	rax,rax
	js	.small
	cmp	rax,60
	jae	.big
;--------------------------
.next:	mov	rcx,19		   ;digit count
	mov	rax,3
	call	fpu_round
	fld	tword[rbp-10]
	fld	st0
	frndint
	fsub	st1,st0
	fstp	tword[rbp-20]	   ;integer
	fstp	tword[rbp-30]	   ;fraction
;--------------------------
.temp1: xor	rsi,rsi
	fld	tword[rbp-20]
	jmp	.int
;--------------------------
.big:	mov	bl,1
	fld	qword[rbp-46]
	fld	tword[rbp-10]
.nxt:	fdiv	st0,st1
	inc	rdx
	fcomi	st1
	jnc	.nxt
	fstp	tword[rbp-10]
	fstp	st0
	jmp	.next
;--------------------------
.small: fld	qword[rbp-46]
	fld	tword[rbp-10]
.nxt2:	fmul	st0,st1
	inc	rdx
	fld1
	fcomip	st1
	jnc	.nxt2
	cmp	rdx,19
	jb	.nope
	fstp	tword[rbp-10]
	fstp	st0
	mov	bl,2
	jmp	.next
.nope:	fstp	st0
	xor	rdx,rdx
	fstp	st0
	jmp	.next
;--------------------------
.int:	fdiv	qword[rbp-46]
	fld	st0
	mov	rax,3
	call	fpu_round
	frndint
	fsub	st1,st0
	fxch
	fmul	qword[rbp-46]
	mov	rax,0
	call	fpu_round
	frndint
	fistp	dword[rbp-50]
	mov	al,[rbp-50]
	push	rax
	inc	rsi
	fld1
	fcomip	st1
	jbe	.int
.get:	pop	rax
	add	al,30h
	stosb
	sub	rcx,1
	sub	rsi,1
	jnz	.get
;--------------------------
.temp2: mov	al,'.'
	stosb
	fstp	st0
	fld	tword[rbp-30]
	mov	rax,1
	call	fpu_round
;--------------------------
.frac:	fmul	qword[rbp-46]
	fld	st0
	frndint
	fist	dword[rbp-50]
	mov	al,[rbp-50]
	add	al,30h
	stosb
	fsubp	st1,st0
	sub	rcx,1
	jnz	.frac
;--------------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.done
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
	jmp	.done
;--------------------------
.err:	mov	al,'#'
	stosb
	jmp	.ok
;--------------------------
.done:	cmp	rdx,0
	je	.ok
	mov	ax,'e+'
	cmp	bl,1
	je	.yes
	mov	ax,'e-'
.yes:	stosw
	mov	rax,rdx
	mov	rcx,10
	xor	rsi,rsi
.div:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	push	rdx
	inc	rsi
	test	rax,rax
	jnz	.div
.again: pop	rax
	stosb
	sub	rsi,1
	jnz	.again
;--------------------------
.ok:	xor	al,al
	stosb
	lea	rax,[rbp-80]
	call	prnstrz
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;------------------------------------
;dblsplit(1)/2
;Split a double into parts
;------------------------------------
;RAX	: The FP value to split
;------------------------------------
;Ret	: Integral part in RAX
;	: Fraction part in RBX
;Note	: Value in should in FP format
;	: Deals normal FP value only
;------------------------------------
align 8
dblsplit:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	finit
	push	rax
	mov	rax,3
	call	fpu_round
	fld	qword[rsp]
	fld	st0
	frndint
	fsub	st1,st0
	fstp	qword[rsp]
	mov	rax,[rsp]
	fabs
	fstp	qword[rsp]
	pop	rbx
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;fpdinfo(1)
;Display Double FP information
;-----------------------------
;RAX	: FP value to analyze
;-----------------------------
;Note	: -
;Ret	: -
;-----------------------------
align 8
fpdinfo:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rdx
	push	rcx
	call	prnhexu
	call	prnline
	call	fpbin
	call	prnline
	push	rax
	fninit
	fld	qword[rsp]
	fxtract
	fstp	qword[rsp]
	mov	rdx,[rsp]
	fistp	qword[rsp]
	pop	rcx
	mov	rax,'SIGN: '
	call	prnstreg
	mov	eax,0x0a30
	bt	rdx,63
	jnc	.nope
	mov	eax,0x0a31
.nope:	call	prnstreg
	mov	rax,'EXP : '
	call	prnstreg
	mov	rax,rcx
	call	prnint
	call	prnline
	mov	rax,'MANT: '
	call	prnstreg
	mov	rax,rdx
	btr	rax,63
	call	prndbl
	pop	rcx
	pop	rdx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------
;fpfinfo(1)
;Display Float FP information
;----------------------------
;EAX	: FP value to analyze
;----------------------------
;Ret	: -
;Note	: -
;----------------------------
align 8
fpfinfo:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rdx
	push	rcx
	push	rbx
	call	prnhexu
	call	prnline
	call	fpbind
	call	prnline
	push	rax
	fninit
	fld	dword[rsp]
	fxtract
	fstp	dword[rsp]
	mov	rdx,[rsp]
	fistp	dword[rsp]
	pop	rcx
	mov	rax,'SIGN: '
	call	prnstreg
	mov	al,'0'
	bt	edx,31
	jnc	.nope
	mov	al,'1'
.nope:	call	prnchr
	call	prnline
	mov	rax,'EXP : '
	call	prnstreg
	mov	rax,rcx
	mov	rbx,1
	call	prnintd
	call	prnline
	mov	rbx,6
	mov	rax,'MANT: '
	call	prnstreg
	mov	eax,edx
	btr	eax,31
	call	prnflt
	pop	rbx
	pop	rcx
	pop	rdx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------
;dec2str(2)
;Convert signed int to
;0-ended dec string
;---------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;---------------------------
;Ret	: String in buffer
;Note	: Buffer must be large enough
;---------------------------
align 8
dec2str:
	push	rax
	push	rdx
	push	rcx
	push	rsi
	push	rdi
	cld
	mov	rdi,rbx
	xor	rsi,rsi
	mov	rcx,10
	test	rax,rax
	jns	.more
	mov	byte[rdi],'-'
	neg	rax
	inc	rdi
.more:	xor	rdx,rdx
	div	rcx
	push	rdx
	inc	rsi
	test	rax,rax
	jnz	.more
.get:	pop	rax
	add	al,30h
	stosb
	sub	rsi,1
	jnz	.get
	xor	al,al
	stosb
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rdx
	pop	rax
	ret
;---------------------------
;dec2stru(2)
;Convert unsigned int to
;0-ended dec string
;---------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;---------------------------
;Ret	: String in buffer
;Note	: Buffer must be large enough
;---------------------------
align 8
dec2stru:
	push	rax
	push	rdx
	push	rcx
	push	rsi
	push	rdi
	cld
	mov	rdi,rbx
	xor	rsi,rsi
	mov	rcx,10
.more:	xor	rdx,rdx
	div	rcx
	push	rdx
	inc	rsi
	test	rax,rax
	jnz	.more
.get:	pop	rax
	add	al,30h
	stosb
	sub	rsi,1
	jnz	.get
	xor	al,al
	stosb
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rdx
	pop	rax
	ret
;---------------------------
;hex2str(2)
;Convert signed int to
;0-ended hex string
;---------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;---------------------------
;Ret	: String in buffer
;Note	: Buffer must be large enough
;---------------------------
align 8
hex2str:
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	cld
	mov	rdi,rbx
	test	rax,rax
	jns	.plus
	mov	byte[rdi],'-'
	neg	rax
	inc	rdi
.plus:	mov	rbx,rax
	xor	rsi,rsi
.more:	xor	eax,eax
	shrd	rax,rbx,4
	shr	rax,60
	add	al,30h
	cmp	al,'9'
	jbe	.digit
	add	al,7
.digit: push	rax
	inc	rsi
	shr	rbx,4
	jnz	.more
.get:	pop	rax
	stosb
	sub	rsi,1
	jnz	.get
	xor	al,al
	stosb
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax
	ret
;---------------------------
;hex2stru(2)
;Convert unsigned int to
;0-ended hex string
;---------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;---------------------------
;Ret	: String in buffer
;Note	: Buffer must be large enough
;---------------------------
align 8
hex2stru:
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	cld
	mov	rdi,rbx
	mov	rbx,rax
	xor	rsi,rsi
.more:	xor	eax,eax
	shrd	rax,rbx,4
	shr	rax,60
	add	al,30h
	cmp	al,'9'
	jbe	.digit
	add	al,7
.digit: push	rax
	inc	rsi
	shr	rbx,4
	jnz	.more
.get:	pop	rax
	stosb
	sub	rsi,1
	jnz	.get
	xor	al,al
	stosb
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax
	ret
;-------------------------------
;bin2str(2)
;Convert signed bin to
;0-ended string
;-------------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;-------------------------------
;Ret	: String in buffer
;Note	: Buffer > 66 bytes
;-------------------------------
align 8
bin2str:
	push	rdi
	push	rax
	push	rcx
	push	rdx
	cld
	mov	rdi,rbx
	test	rax,rax
	jnz	.norm
	mov	al,'0'
	stosb
	jmp	.done
.norm:	mov	rdx,rax
	bsr	rcx,rax
	test	rax,rax
	jns	.plus
	neg	rax
	mov	byte[rdi],'-'
	inc	rdi
.plus:	mov	rdx,rax
	bsr	rcx,rax
.next:	mov	al,'0'
	bt	rdx,rcx
	jnc	.zero
	mov	al,'1'
.zero:	stosb
	sub	rcx,1
	jns	.next
.done:	xor	al,al
	stosb
	pop	rdx
	pop	rcx
	pop	rax
	pop	rdi
	ret
;-------------------------------
;bin2stru(2)
;Convert unsigned bin to
;0-ended string
;-------------------------------
;RBX	: Buffer's address
;RAX	: Integer to convert
;-------------------------------
;Ret	: String in buffer
;Note	: Buffer > 64 bytes
;-------------------------------
align 8
bin2stru:
	push	rdi
	push	rax
	push	rcx
	push	rdx
	cld
	mov	rdi,rbx
	test	rax,rax
	jnz	.norm
	mov	al,'0'
	stosb
	jmp	.done
.norm:	mov	rdx,rax
	bsr	rcx,rax
.next:	mov	al,'0'
	bt	rdx,rcx
	jnc	.zero
	mov	al,'1'
.zero:	stosb
	sub	rcx,1
	jns	.next
.done:	xor	al,al
	stosb
	pop	rdx
	pop	rcx
	pop	rax
	pop	rdi
	ret
;---------------------------------
;flt2str(2)
;Convert float to 0-ended string
;---------------------------------
;RBX	: Address of buffer
;EAX	: Single value to convert
;---------------------------------
;Ret	: -
;Note	: Use DD for vars
;	: Buffer size > 15
;---------------------------------
align 8
flt2str:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	cld
	mov	edi,ebx
	mov	ecx,__float32__(1.0)
	mov	ebx,__float32__(0.1)
	mov	edx,__float32__(10.0)
	movd	xmm4,ecx
	movd	xmm2,ebx
	movd	xmm3,edx
	xor	rsi,rsi
	bt	eax,31
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	eax,31
;----------------------
.zero:	mov	ebx,eax
	test	eax,eax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	ebx,23
	mov	ecx,127
	cmp	ebx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	ebx,ecx
	test	ebx,ebx
	js	.small
	cmp	ebx,19
	ja	.big
;----------------------
.begin: movd	xmm0,eax
	movd	xmm1,eax
	;mov	 eax,0
	;call	 sse_round
	roundss xmm0,xmm0,3
	subss	xmm1,xmm0
	xor	ecx,ecx
	xor	ebx,ebx
	jmp	.int
;----------------------
.small: movd	xmm0,eax
	mov	esi,eax
	xor	edx,edx
	mov	eax,0
	call	sse_round
.c2:	mulss	xmm0,xmm3
	add	edx,1
	comiss	xmm0,xmm4
	jc	.c2
	cmp	edx,7
	jb	.nope
	movd	eax,xmm0
	mov	esi,-1
	jmp	.begin
.nope:	mov	eax,esi
	xor	esi,esi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	edx,edx
	movd	xmm0,eax
	mov	eax,1
	call	sse_round
.c1:	mulss	xmm0,xmm2
	add	edx,1
	comiss	xmm0,xmm3
	jnc	.c1
	movd	eax,xmm0
	jmp	.begin
;----------------------
.int:	mov	eax,0
	call	sse_round
.i:	mulss	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundss xmm5,xmm5,3
	subss	xmm0,xmm5
	mulss	xmm0,xmm3  ;10.0
	cvtss2si eax,xmm0
	add	ecx,1
	add	ebx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comiss	xmm0,xmm4  ;1.0
	jnc	.i
.save:	pop	rax
	stosb
	sub	ecx,1
	jnz	.save
	cmp	esi,-2
	je	.done
	mov	al,'.'
	stosb
	comiss	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	ebx,1
	jmp	.enote
;----------------------
.nxt:	push	rdx
	xor	edx,edx
	mov	rax,0
	call	sse_round
.frac:	mulss	xmm1,xmm3
	comiss	xmm1,xmm4
	jnc	.no
	add	edx,1
	movq	xmm5,xmm1
	mulss	xmm5,xmm3
	roundss xmm5,xmm5,0
	comiss	xmm5,xmm3
	jnz	.no
	sub	edx,1
.no:	add	ebx,1
	cmp	ebx,7
	jne	.frac
	xor	ecx,ecx
	movq	xmm0,xmm1
	roundss xmm0,xmm0,0
.int2:	mulss	xmm0,xmm2
	movq	xmm5,xmm0
	roundss xmm5,xmm5,3
	subss	xmm0,xmm5
	mulss	xmm0,xmm3
	cvtss2si eax,xmm0
	add	ecx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comiss	xmm0,xmm4
	jnc	.int2
	test	edx,edx
	jz	.save2
.looop: push	'0'
	add	ecx,1
	sub	edx,1
	jnz	.looop
.save2: pop	rax
	stosb
	sub	ecx,1
	jnz	.save2
	pop	rdx
;----------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.enote
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
;----------------------
.enote: test	esi,esi
	jz	.done
	mov	ax,'E+'
	test	esi,esi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2ss xmm0,edx
	mov	esi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;dbl2str(3)
;Convert double to 0-ended string
;with decimal places
;---------------------------------
;RCX	: Address of buffer
;RBX	: Decimal places
;RAX	: Double value to display
;---------------------------------
;Ret	: -
;Note	: RBX must within reasonable range
;	: RBX cannot be 0 or negative
;	: Normals are valid up to 16 digits
;	: Rounding used = nearest
;	: Buffer > 24
;---------------------------------
align 8
dbl2str:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16*6
	and	rsp,-16
	movdqa	[rsp   ],xmm0
	movdqa	[rsp+16],xmm1
	movdqa	[rsp+32],xmm2
	movdqa	[rsp+48],xmm3
	movdqa	[rsp+64],xmm4
	movdqa	[rsp+80],xmm5
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	push	rbp
	cld
	mov	rdi,rcx
	mov	rbp,rbx
	mov	rcx,0x3ff0000000000000
	mov	rbx,0x3FB999999999999A
	mov	rdx,0x4024000000000000
	movq	xmm4,rcx
	movq	xmm2,rbx
	movq	xmm3,rdx
	xor	rsi,rsi
	bt	rax,63
	jnc	.zero
	mov	byte[rdi],'-'
	add	rdi,1
	btr	rax,63
;----------------------
.zero:	mov	rbx,rax
	test	rax,rax
	jnz	.inv
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;----------------------
.inv:	shr	rbx,52
	mov	rcx,1023
	cmp	rbx,0x7ff
	jne	.norm
	mov	al,'#'
	stosb
	jmp	.done
;----------------------
.norm:	sub	rbx,rcx
	test	rbx,rbx
	js	.small
	cmp	rbx,49
	ja	.big
;----------------------
.begin: movq	xmm0,rax
	movq	xmm1,rax
	mov	rax,0
	call	sse_round
	roundsd xmm0,xmm0,3
	subsd	xmm1,xmm0
	xor	rcx,rcx
	xor	rbx,rbx
	jmp	.int
;----------------------
.small: movq	xmm0,rax
	mov	rsi,rax
	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.c2:	mulsd	xmm0,xmm3
	add	edx,1
	comisd	xmm0,xmm4
	jc	.c2
	cmp	edx,16
	jb	.nope
	movq	rax,xmm0
	mov	rsi,-1
	jmp	.begin
.nope:	mov	rax,rsi
	xor	rsi,rsi
	jmp	.begin
;----------------------
.big:	mov	esi,1
	xor	rdx,rdx
	movq	xmm0,rax
	mov	rax,1
	call	sse_round
.c1:	mulsd	xmm0,xmm2
	add	edx,1
	comisd	xmm0,xmm3
	jnc	.c1
	movq	rax,xmm0
	jmp	.begin
;----------------------
.int:	mulsd	xmm0,xmm2  ;0.1
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3  ;10.0
	cvtsd2si rax,xmm0
	add	rcx,1
	add	rbx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4  ;1.0
	jnc	.int
.save:	pop	rax
	stosb
	sub	rcx,1
	jnz	.save
	cmp	rsi,-2
	je	.done
	mov	al,'.'
	stosb
	comisd	xmm1,xmm5
	jnz	.nxt
	mov	al,'0'
	stosb
	add	rbx,1
	jmp	.enote
;----------------------
.nxt:	push	rdx
	test	rsi,rsi
	jns	.n1
	add	rbx,1
.n1:	xor	rdx,rdx
	mov	rax,0
	call	sse_round
.frac:	mulsd	xmm1,xmm3
	comisd	xmm1,xmm4
	jnc	.no
	add	rdx,1
	movq	xmm5,xmm1
	mulsd	xmm5,xmm3
	roundsd xmm5,xmm5,0
	comisd	xmm5,xmm3
	jnz	.no
	sub	rdx,1
.no:	sub	rbp,1
	jnz	.frac
	xor	rcx,rcx
	movq	xmm0,xmm1
	roundsd xmm0,xmm0,0
.int2:	mulsd	xmm0,xmm2
	movq	xmm5,xmm0
	roundsd xmm5,xmm5,3
	subsd	xmm0,xmm5
	mulsd	xmm0,xmm3
	cvtsd2si rax,xmm0
	add	rcx,1
	add	al,30h
	movq	xmm0,xmm5
	push	rax
	comisd	xmm0,xmm4
	jnc	.int2
	test	rdx,rdx
	jz	.save2
.looop: push	'0'
	add	rcx,1
	sub	rdx,1
	jnz	.looop
.save2: pop	rax
	stosb
	sub	rcx,1
	jnz	.save2
	pop	rdx
;----------------------
.enote: test	rsi,rsi
	jz	.done
	mov	ax,'E+'
	test	rsi,rsi
	jns	.plus
	mov	ax,'E-'
.plus:	stosw
	cvtsi2sd xmm0,rdx
	mov	rsi,-2
	jmp	.int
;----------------------
.done:	xor	al,al
	stosb
	pop	rbp
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	movdqa	xmm0,[rsp   ]
	movdqa	xmm1,[rsp+16]
	movdqa	xmm2,[rsp+32]
	movdqa	xmm3,[rsp+48]
	movdqa	xmm4,[rsp+64]
	movdqa	xmm5,[rsp+80]
	mov	rsp,rbp
	pop	rbp
	ret
;------------------------------------
;dblx2str(2)
;Convert REAL10 to 0-ended string
;------------------------------------
;RBX	: Address of buffer ( > 27 )
;RAX	: Address of a DT in memory
;------------------------------------
;Ret	: -
;Note	: Variable must be of type DT
;	: Unrounded precision
;------------------------------------
;Stack partitioning
;val	dt 0.0	  ;10
;v1	dt 0.0	  ;20
;v2	dt 0.0	  ;30
;exp	dq 0	  ;38
;ten	dq 10.0   ;46
;digit	dd 0	  ;50
;save	rb 512	  ;562
;----------------------
align 8
dblx2str:
	push	rbp
	mov	rbp,rsp
	sub	rsp,562
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rdx,__float64__(10.0)
	mov	[rbp-46],rdx
	mov	qword[rbp-38],0
	fninit
	push	rax
	mov	rax,1
	call	fpu_precision
	pop	rax
	fldz
	fst	qword[rbp-10]
	fst	qword[rbp-20]
	fst	qword[rbp-30]
	fistp	dword[rbp-50]
	xor	rdx,rdx    ;index
	cld
	mov	rdi,rbx
	mov	rbx,rax
	mov	rax,[rbx]
	mov	[rbp-10],rax
	mov	ax,[rbx+8]
	mov	[rbp-2],ax
	xor	rbx,rbx
;--------------------------
.check: fld	tword[rbp-10]
	xor	rax,rax
	fxam
	fnstsw	ax
	and	eax,4500h
	cmp	eax,500h
	je	.err
	cmp	eax,100h
	je	.err
	cmp	eax,0
	je	.err
	bt	word[rbp-2],15
	jnc	.plus
	mov	al,'-'
	stosb
	btr	word[rbp-2],15
	fstp	st0
	fld	tword[rbp-10]
.plus:	fldz
	fcomip	st1
	jnz	.norm
	mov	eax,'0.0'
	stosd
	sub	rdi,1
	jmp	.done
;--------------------------
.norm:	fxtract
	fstp	st0
	fistp	qword[rbp-38]
	mov	rax,[rbp-38]
	test	rax,rax
	js	.small
	cmp	rax,60
	jae	.big
;--------------------------
.next:	mov	rcx,19		   ;digit count
	mov	rax,3
	call	fpu_round
	fld	tword[rbp-10]
	fld	st0
	frndint
	fsub	st1,st0
	fstp	tword[rbp-20]	   ;integer
	fstp	tword[rbp-30]	   ;fraction
;--------------------------
.temp1: xor	rsi,rsi
	fld	tword[rbp-20]
	jmp	.int
;--------------------------
.big:	mov	bl,1
	fld	qword[rbp-46]
	fld	tword[rbp-10]
.nxt:	fdiv	st0,st1
	inc	rdx
	fcomi	st1
	jnc	.nxt
	fstp	tword[rbp-10]
	fstp	st0
	jmp	.next
;--------------------------
.small: fld	qword[rbp-46]
	fld	tword[rbp-10]
.nxt2:	fmul	st0,st1
	inc	rdx
	fld1
	fcomip	st1
	jnc	.nxt2
	cmp	rdx,19
	jb	.nope
	fstp	tword[rbp-10]
	fstp	st0
	mov	bl,2
	jmp	.next
.nope:	fstp	st0
	xor	rdx,rdx
	fstp	st0
	jmp	.next
;--------------------------
.int:	fdiv	qword[rbp-46]
	fld	st0
	mov	rax,3
	call	fpu_round
	frndint
	fsub	st1,st0
	fxch
	fmul	qword[rbp-46]
	mov	rax,0
	call	fpu_round
	frndint
	fistp	dword[rbp-50]
	mov	al,[rbp-50]
	push	rax
	inc	rsi
	fld1
	fcomip	st1
	jbe	.int
.get:	pop	rax
	add	al,30h
	stosb
	sub	rcx,1
	sub	rsi,1
	jnz	.get
;--------------------------
.temp2: mov	al,'.'
	stosb
	fstp	st0
	fld	tword[rbp-30]
	mov	rax,1
	call	fpu_round
;--------------------------
.frac:	fmul	qword[rbp-46]
	fld	st0
	frndint
	fist	dword[rbp-50]
	mov	al,[rbp-50]
	add	al,30h
	stosb
	fsubp	st1,st0
	sub	rcx,1
	jnz	.frac
;--------------------------
.cutz:	cmp	byte[rdi-1],'0'
	jne	.done
	sub	rdi,1
	cmp	byte[rdi-1],'.'
	jnz	.cutz
	add	rdi,1
	jmp	.done
;--------------------------
.err:	mov	al,'#'
	stosb
	jmp	.ok
;--------------------------
.done:	cmp	rdx,0
	je	.ok
	mov	ax,'e+'
	cmp	bl,1
	je	.yes
	mov	ax,'e-'
.yes:	stosw
	mov	rax,rdx
	mov	rcx,10
	xor	rsi,rsi
.div:	xor	rdx,rdx
	div	rcx
	add	dl,30h
	push	rdx
	inc	rsi
	test	rax,rax
	jnz	.div
.again: pop	rax
	stosb
	sub	rsi,1
	jnz	.again
;--------------------------
.ok:	xor	al,al
	stosb
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;-------------------------------------------
;readint/1
;Get multi suffix integer from keyboard
;-------------------------------------------
;Arg	: -
;-------------------------------------------
;Ret	: Integer in RAX
;Note	: Expected Suffix- b(binary), d(dec)
;	: h(hex), o,q(octal). d is optional
;	: Variable must be of type DQ
;	: Digits must be in valid format
;-------------------------------------------
align 8
readint:
	sub	rsp,80
	mov	rax,rsp
	call	readstr
	cmp	rax,-1
	je	.err
	mov	rax,rsp
	call	str2int
	jmp	.done
.err:	mov	rax,0
.done:	add	rsp,80
	ret
;-------------------------------------
;readdbl/1
;Get double-precision from stdin
;-------------------------------------
;Arg	: -
;-------------------------------------
;Ret	: Double precision in RAX
;Note	: Var must be initd to fp (0.0)
;	: Var must be of type DQ
;	: Doesn't take E format
;	: Must use fp format for input
;-------------------------------------
align 8
readdbl:
	sub	rsp,64
	mov	rax,rsp
	call	readstr
	cmp	rax,-1
	je	.err
	mov	rax,rsp
	call	str2dbl
	jmp	.done
.err:	mov	rax,0
.done:	add	rsp,64
	ret
;-------------------------------------
;readflt/1
;Get single-precision from stdin
;-------------------------------------
;Arg	: -
;-------------------------------------
;Ret	: Single precision in EAX
;Note	: Var must be init to fp (0.0)
;	: Doesn't take E format
;	: Must use fp format for input
;-------------------------------------
align 8
readflt:
	sub	rsp,64
	mov	rax,rsp
	call	readstr
	cmp	rax,-1
	je	.err
	mov	rax,rsp
	call	str2flt
	jmp	.done
.err:	mov	eax,0
.done:	add	rsp,64
	ret
;------------------------
;fpu_stack
;Display FPU stack
;------------------------
;Arg	: - 
;------------------------
;Ret	: -
;Note	: Display is real10
;------------------------
align 8
fpu_stack:
	push	rdi
	push	rdx
	push	rbx
	push	rax 
	sub	rsp,32
	xor	rdx,rdx
	mov	rdi,rsp
	cld
	mov	ax,'ST'
	stosw
.again: mov	al,dl
	add	al,30h
	stosb
	mov	ax,': '
	stosw
	xor	rax,rax
	fxam
	fnstsw	ax
	and	eax,4500h    ;Mask C3, C2 & C0
	cmp	eax,4100h    ;Empty
	jne	.ok
	mov	eax,'...'
	stosd
	sub	rdi,1
	mov	rax,rsp
	mov	rbx,8
	call	prnstr
	jmp	.ok2
.ok:	mov	rax,rsp
	mov	rbx,5
	call	prnstr
	fstp	tword[rsp+20]
	fld	tword[rsp+20]
	fclex
	lea	rax,[rsp+20]
	call	prndblx
.ok2:	cmp	rdx,7
	je	.out
	fincstp 	     ;rotate stack
	add	rdx,1
	mov	rdi,rsp
	call	prnline
	add	rdi,2
	jmp	.again
.out:	fincstp
	call	prnline
	add	rsp,32
	pop	rax
	pop	rbx
	pop	rdx
	pop	rdi
	ret
;-----------------------
;fpu_sflag
;Display FPU Status Flag
;-----------------------
;Arg	: - 
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
fpu_sflag:
	push	rax
	push	rdx 
	push	rcx
	push	rdi
	push	rsi
	sub	rsp,16*4
	mov	rdi,rsp
	mov	rax,'B C3 TP '
	stosq
	mov	rax,'TP TP C2'
	stosq
	mov	rax,' C1 C0 I'
	stosq
	mov	rax,'R SF  P '
	stosq
	mov	rax,' U  O  Z'
	stosq
	mov	rax,'  D  I  '
	stosq
	mov	ax,0x000a
	stosw
	mov	rax,rsp
	call	prnstrz
	xor	rax,rax
	fnstsw	ax
	mov	dx,ax
	mov	rsi,rax
	mov	rcx,15
	mov	rdi,rsp
.go1:	mov	eax,'0  '
	shl	dx,1
	jnc	.y
	mov	eax,'1  '
.y:	stosd
	sub	rdi,1
	sub	rcx,1
	jns	.go1
.out:	sub	rdi,1
	mov	ax,0x003d
	stosw
	mov	rax,rsp
	call	prnstrz
	mov	rax,rsi
	call	prnhexu
	call	prnline
	add	rsp,16*4
	pop	rsi
	pop	rdi
	pop	rcx 
	pop	rdx
	pop	rax 
	ret
;------------------------
;fpu_cflag
;Display FPU Control Flag
;------------------------
;Arg	: - 
;------------------------
;Ret	: -
;Note	: -
;------------------------
align 8
fpu_cflag:
	push	rax
	push	rdx
	push	rcx
	push	rdi
	push	rsi
	sub	rsp,16*4
	mov	rax,'        '
	mov	rdx,'IC RC RC'
	mov	rcx,' PC PC I'
	mov	rdi,'EM   PM '
	mov	rsi,'UM OM ZM'
	mov	[rsp   ],rax
	mov	[rsp+8 ],rdx
	mov	[rsp+16],rcx
	mov	[rsp+24],rdi
	mov	[rsp+32],rsi
	mov	rdx,' DM IM  '
	mov	[rsp+40],rdx
	mov	eax,0x0a
	xor	rdx,rdx
	mov	[rsp+48],ax
	mov	rax,rsp
	call	prnstrz
	fnstcw	[rsp]
	mov	rcx,15
	mov	dx,[rsp]
	mov	rsi,rdx
	cld
	mov	rdi,rsp
.go1:	mov	eax,'0  '
	shl	dx,1
	jnc	.y
	mov	eax,'1  '
.y:	stosd
	sub	rdi,1
	sub	rcx,1
	jns	.go1
.out:	sub	rdi,1
	mov	ax,0x003d
	stosw
	mov	rax,rsp
	call	prnstrz
	mov	rax,rsi
	call	prnhexu
	call	prnline
	add	rsp,16*4
	pop	rsi
	pop	rdi
	pop	rcx
	pop	rdx 
	pop	rax
	ret
;------------------------
;fpu_tag
;Display FPU Tag Register
;------------------------
;Arg	: -
;------------------------
;Ret	: -
;Note	: 00 = valid
;	: 01 = zero
;	: 10 = invalid
;	: 11 = empty
;------------------------
align 8
fpu_tag:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	sub	rsp,32
	xor	rcx,rcx
	xor	rdx,rdx
	mov	rdi,rsp
	mov	rax,'T7 T6 T5'
	stosq
	mov	rax,' T4 T3 T'
	stosq
	mov	rax,'2 T1 T0 '
	stosq
	sub	rdi,1
	mov	ax,0x000a
	stosw
	mov	rax,rsp
	call	prnstrz
	fstenv	[rsp]
	mov	dx,[rsp+8]
	push	rdx
	mov	cx,8
.again: mov	al,'0'
	shl	dx,1
	jnc	.nop
	mov	al,'1'
.nop:	call	prnchr
	mov	al,'0'
	shl	dx,1
	jnc	.nop2
	mov	al,'1'
.nop2:	call	prnchr
	sub	cx,1
	jz	.done
	call	prnspace
	jmp	.again
.done:	mov	al,'='
	call	prnchr
	pop	rax
	call	prnhexu
	call	prnline
	add	rsp,32
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;---------------------------------
;fpu_reg(1)
;Display one FPU stack register
;---------------------------------
;RAX	: Stack # to display (0-7)
;---------------------------------
;Ret	: -
;Note	: Special values show nothing
;	: fld tword[x+16*2] ;st0
;---------------------------------
align 8
fpu_reg:
	push	rcx
	push	rax
	xor	rcx,rcx
	test	rax,rax
	js	.done
	cmp	rax,7
	ja	.done
.again: cmp	rcx,rax
	je	.ok
	fincstp
	add	rcx,1
	cmp	rcx,7
	jne	.again
.ok:	fst	qword[rsp]
	fxam
	fnstsw	ax
	and	eax,4500h
	cmp	eax,4000h
	jne	.next
	mov	qword[rsp],0
	jmp	.nxt
.next:	cmp	eax,4100h
	je	.done
	cmp	eax,500h
	je	.done
	cmp	eax,100h
	je	.done
	cmp	eax,0
	je	.done
.nxt:	mov	rax,[rsp]
	call	prndbl
.done:	pop	rax
	pop	rcx
	ret
;------------------------------
;fpu_copy(1)/1
;Copy a FPU register
;------------------------------
;RAX	: Stack # to copy (0-7)
;------------------------------
;Ret	: Copied value in RAX
;Note	: -
;------------------------------
align 8
fpu_copy:
	push	rdi
	push	rax
	mov	rdi,rax
	xor	eax,eax
.go:	cmp	rax,rdi
	jne	.a
	fst	qword[rsp]
.a:	fincstp
	add	rax,1
	cmp	rax,8
	jne	.go
.done:	mov	rax,[rsp]
	add	rsp,8
	pop	rdi
	ret
;---------------------------------
;fpu_precision(1)
;Set FPU precision control
;---------------------------------
;RAX	: Rounding mode;
;	  0 = real8
;	  1 = real10
;	  2 = real4
;---------------------------------
;Ret	: -
;Note	: FSAVE/FINIT will reset it
;---------------------------------
align 8
fpu_precision:
	sub	rsp,8
	fnstcw	[rsp]
	cmp	rax,1
	je	.r10
	cmp	rax,2
	je	.r4
.r8:	bts	word[rsp],9
	btr	word[rsp],8
	jmp	.done
.r10:	bts	word[rsp],9
	bts	word[rsp],8
	jmp	.done
.r4:	btr	word[rsp],9
	btr	word[rsp],8
.done:	fldcw	[rsp]
	add	rsp,8
	ret
;---------------------------------
;fpu_round(1)
;Set FPU rounding control
;---------------------------------
;RAX	: Rounding mode;
;	  0 = near
;	  1 = down
;	  2 = up
;	  3 = zero
;---------------------------------
;Ret	: -
;Note	: FSAVE/FINIT will reset it
;---------------------------------
align 8
fpu_round:
	push	rbx
	sub	rsp,8
	fnstcw	[rsp]
	mov	bx,[rsp]
	cmp	rax,1
	je	.down
	cmp	rax,2
	je	.up
	cmp	rax,3
	je	.zero
.near:	and	bx,0xf3ff
	jmp	.done
.down:	and	bx,0xf7ff
	or	bx,0x400
	jmp	.done
.up:	or	bx,0x800
	and	bx,0xfbff
	jmp	.done
.zero:	or	bx,0xc00
.done:	mov	[rsp],bx
	fldcw	[rsp]
	add	rsp,8
	pop	rbx
	ret
;---------------------------
;sse_round(1)
;Set SSE rounding control
;---------------------------
;RAX	: Rounding mode;
;	  0 = near
;	  1 = down
;	  2 = up
;	  3 = zero
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
sse_round:
	push	rbx
	sub	rsp,8
	stmxcsr [rsp]
	mov	ebx,[rsp]
	cmp	rax,1
	je	.down
	cmp	rax,2
	je	.up
	cmp	rax,3
	je	.zero
.near:	and	ebx,0xffff9fff
	jmp	.done
.down:	and	ebx,0xffffbfff
	or	ebx,0x2000
	jmp	.done
.up:	or	ebx,0x4000
	and	ebx,0xffffdfff
	jmp	.done
.zero:	or	ebx,0x6000
.done:	mov	[rsp],ebx
	ldmxcsr [rsp]
	add	rsp,8
	pop	rbx
	ret
;---------------------------------
;sse_flags
;Display MXCSR register
;---------------------------------
;Arg	: -
;---------------------------------
;Ret	: -
;Note	: -
;---------------------------------
align 8
sse_flags:
	push	rax
	push	rdx
	push	rcx
	push	rdi
	push	rsi
	sub	rsp,64
	stmxcsr [rsp]
	mov	edx,[rsp]
	mov	esi,[rsp]
	cld
	mov	rdi,rsp
	mov	rax,'FZ RC RC'
	stosq
	mov	rax,' PM UM O'
	stosq
	mov	rax,'M ZM DM '
	stosq
	mov	rax,'IM DZ PE'
	stosq
	mov	rax,' UE OE Z'
	stosq
	mov	rax,'E DE IE '
	stosq
	sub	rdi,1
	mov	eax,0x0a
	stosw
	mov	rax,rsp
	call	prnstrz
	mov	ecx,15
	mov	rdi,rsp
.again: mov	eax,'0  '
	shl	dx,1
	jnc	.ok
	mov	eax,'1  '
.ok:	stosd
	sub	rdi,1
	sub	ecx,1
	jns	.again
	sub	rdi,1
	mov	ax,0x003d
	stosw
	mov	rax,rsp
	call	prnstrz
	mov	eax,esi
	call	prnhexu
	call	prnline
	add	rsp,64
	pop	rsi
	pop	rdi
	pop	rcx
	pop	rdx
	pop	rax
	ret
;-----------------------------
;prnmmx(2)
;Display MMX register
;-----------------------------
;RBX	: Type of display:
;	  0 - unsigned byte
;	  1 - signed byte
;	  2 - unsigned word
;	  3 - signed word
;	  4 - unsigned dword
;	  5 - signed dword
;RAX	: Register number(0-7)
;-----------------------------
;Ret	: -
;Note:	: -
;-----------------------------
align 8
prnmmx:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rdi
	push	rcx
	sub	rsp,8
	mov	rcx,8
	mov	edi,ebx
	cmp	rax,0
	je	.mm0
	cmp	rax,1
	je	.mm1
	cmp	rax,2
	je	.mm2
	cmp	rax,3
	je	.mm3
	cmp	rax,4
	je	.mm4
	cmp	rax,5
	je	.mm5
	cmp	rax,6
	je	.mm6
	cmp	rax,7
	je	.mm7
	jmp	.done
.mm0:	movq	[rsp],mm0
	jmp	.nxt
.mm1:	movq	[rsp],mm1
	jmp	.nxt
.mm2:	movq	[rsp],mm2
	jmp	.nxt
.mm3:	movq	[rsp],mm3
	jmp	.nxt
.mm4:	movq	[rsp],mm4
	jmp	.nxt
.mm5:	movq	[rsp],mm5
	jmp	.nxt
.mm6:	movq	[rsp],mm6
	jmp	.nxt
.mm7:	movq	[rsp],mm7
.nxt:	cmp	edi,0
	je	.unsigned
	cmp	edi,2
	je	.unsigned
	cmp	edi,4
	je	.unsigned
	jmp	.signed
.unsigned:
	mov	edi,0
	cmp	ebx,0
	je	.ubyte
	cmp	ebx,2
	je	.uword
	cmp	ebx,4
	je	.udword
	jmp	.done
.signed:
	mov	edi,1
	cmp	ebx,1
	je	.sbyte
	cmp	ebx,3
	je	.sword
	cmp	ebx,5
	je	.sdword
	jmp	.done
.ubyte: mov	ebx,edi
.l1:	mov	eax,[rsp+rcx-1]
	and	eax,0xff
	call	prnintb
	call	prnspace
	sub	rcx,1
	jnz	.l1
	jmp	.done
.uword: mov	ebx,edi
.l3:	mov	eax,[rsp+rcx-2]
	and	eax,0xffff
	call	prnintw
	call	prnspace
	sub	rcx,2
	jnz	.l3
	jmp	.done
.udword:
	mov	ebx,edi
.l5:	mov	eax,[rsp+rcx-4]
	call	prnintd
	call	prnspace
	sub	rcx,4
	jnz	.l5
	jmp	.done
.sbyte: mov	ebx,edi
.l2:	mov	eax,[rsp+rcx-1]
	and	eax,0xff
	call	prnintb
	call	prnspace
	sub	rcx,1
	jnz	.l2
	jmp	.done
.sword: mov	ebx,edi
.l4:	mov	eax,[rsp+rcx-2]
	and	eax,0xffff
	call	prnintw
	call	prnspace
	sub	rcx,2
	jnz	.l4
	jmp	.done
.sdword:
	mov	ebx,edi
.l6:	mov	eax,[rsp+rcx-4]
	call	prnintd
	call	prnspace
	sub	rcx,4
	jnz	.l6
.done:	add	rsp,8
	pop	rcx
	pop	rdi
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------------
;dumpmmx(1)
;Dump MMX registers
;----------------------------------
;RAX	: Type of display:
;	  0 - Unsigned integer BYTE
;	  1 - Signed integer BYTE
;	  2 - Unsigned integer WORD
;	  3 - Signed integer WORD
;	  4 - Unsigned integer DWORD
;	  5 - Signed integer DWORD
;----------------------------------
;Ret	: -
;Note	: -
;----------------------------------
align 8
dumpmmx:
	push	rax
	push	rcx
	push	rbx
	push	rdx
	mov	rcx,rax
	cmp	rcx,5
	ja	.done
	xor	rdx,rdx
.again: mov	eax,'mm'
	call	prnstreg
	mov	rax,rdx
	call	prnintu
	mov	eax,': '
	call	prnstreg
	mov	rax,rdx
	mov	rbx,rcx
	call	prnmmx
	add	rdx,1
	cmp	rdx,8
	jz	.done
	call	prnline
	jmp	.again
.done:	call	prnline
	pop	rdx
	pop	rbx
	pop	rcx
	pop	rax
	ret
;-------------------------------------
;prnxmm(2)
;Display XMM register
;-------------------------------------
;RBX	: Type of display:
;	  0 - Signed integer BYTE
;	  1 - Unsigned integer BYTE
;	  2 - Signed integer WORD
;	  3 - Unsigned integer WORD
;	  4 - Signed integer DWORD
;	  5 - Unsigned integer DWORD
;	  6 - Signed integer QWORD
;	  7 - Unsigned integer QWORD
;	  8 - Singles
;	  9 - Doubles
;	  10- Unsigned hex
;	  11- Signed hex
;RAX	: Register number to display
;-------------------------------------
;Ret	: -
;Note	: -
;-------------------------------------
align 8
prnxmm:
	push	rax
	push	rbx
	sub	rsp,16
	cmp	eax,0
	jz	.xmm0
	cmp	eax,1
	jz	.xmm1
	cmp	eax,2
	jz	.xmm2
	cmp	eax,3
	jz	.xmm3
	cmp	eax,4
	jz	.xmm4
	cmp	eax,5
	jz	.xmm5
	cmp	eax,6
	jz	.xmm6
	cmp	eax,7
	jz	.xmm7
	cmp	eax,8
	jz	.xmm8
	cmp	eax,9
	jz	.xmm9
	cmp	eax,10
	jz	.xmm10
	cmp	eax,11
	jz	.xmm11
	cmp	eax,12
	jz	.xmm12
	cmp	eax,13
	jz	.xmm13
	cmp	eax,14
	jz	.xmm14
	cmp	eax,15
	jz	.xmm15
	jmp	.err
.xmm0:	movdqu	[rsp],xmm0
	jmp	.disp
.xmm1:	movdqu	[rsp],xmm1
	jmp	.disp
.xmm2:	movdqu	[rsp],xmm2
	jmp	.disp
.xmm3:	movdqu	[rsp],xmm3
	jmp	.disp
.xmm4:	movdqu	[rsp],xmm4
	jmp	.disp
.xmm5:	movdqu	[rsp],xmm5
	jmp	.disp
.xmm6:	movdqu	[rsp],xmm6
	jmp	.disp
.xmm7:	movdqu	[rsp],xmm7
	jmp	.disp
.xmm8:	movdqu	[rsp],xmm8
	jmp	.disp
.xmm9:	movdqu	[rsp],xmm9
	jmp	.disp
.xmm10: movdqu	[rsp],xmm10
	jmp	.disp
.xmm11: movdqu	[rsp],xmm11
	jmp	.disp
.xmm12: movdqu	[rsp],xmm12
	jmp	.disp
.xmm13: movdqu	[rsp],xmm13
	jmp	.disp
.xmm14: movdqu	[rsp],xmm14
	jmp	.disp
.xmm15: movdqu	[rsp],xmm15
.disp:	cmp	ebx,0
	je	.byte_unsigned
	cmp	ebx,1
	je	.byte_signed
	cmp	ebx,2
	je	.word_unsigned
	cmp	ebx,3
	je	.word_signed
	cmp	ebx,4
	je	.dword_unsigned
	cmp	ebx,5
	je	.dword_signed
	cmp	ebx,6
	je	.qword_unsigned
	cmp	ebx,7
	je	.qword_signed
	cmp	ebx,8
	je	.singles
	cmp	ebx,9
	je	.doubles
	cmp	ebx,10
	je	.hexu
	cmp	ebx,11
	je	.hex
	jmp	.err
.byte_signed:
	mov	ebx,1
	jmp	.byte
.byte_unsigned:
	mov	ebx,0
.byte:	mov	al,[rsp+15]
	call	prnintb
	call	prnspace
	mov	al,[rsp+14]
	call	prnintb
	call	prnspace
	mov	al,[rsp+13]
	call	prnintb
	call	prnspace
	mov	al,[rsp+12]
	call	prnintb
	call	prnspace
	mov	al,[rsp+11]
	call	prnintb
	call	prnspace
	mov	al,[rsp+10]
	call	prnintb
	call	prnspace
	mov	al,[rsp+9]
	call	prnintb
	call	prnspace
	mov	al,[rsp+8]
	call	prnintb
	call	prnspace
	mov	al,[rsp+7]
	call	prnintb
	call	prnspace
	mov	al,[rsp+6]
	call	prnintb
	call	prnspace
	mov	al,[rsp+5]
	call	prnintb
	call	prnspace
	mov	al,[rsp+4]
	call	prnintb
	call	prnspace
	mov	al,[rsp+3]
	call	prnintb
	call	prnspace
	mov	al,[rsp+2]
	call	prnintb
	call	prnspace
	mov	al,[rsp+1]
	call	prnintb
	call	prnspace
	mov	al,[rsp]
	call	prnintb
	jmp	.done
.word_signed:
	mov	ebx,1
	jmp	.word
.word_unsigned:
	mov	ebx,0
.word:	mov	ax,[rsp+14]
	call	prnintw
	call	prnspace
	mov	ax,[rsp+12]
	call	prnintw
	call	prnspace
	mov	ax,[rsp+10]
	call	prnintw
	call	prnspace
	mov	ax,[rsp+8]
	call	prnintw
	call	prnspace
	mov	al,'|'
	call	prnchr
	call	prnspace
	mov	ax,[rsp+6]
	call	prnintw
	call	prnspace
	mov	ax,[rsp+4]
	call	prnintw
	call	prnspace
	mov	ax,[rsp+2]
	call	prnintw
	call	prnspace
	mov	ax,[rsp]
	call	prnintw
	jmp	.done
.dword_signed:
	mov	ebx,1
	jmp	.dword
.dword_unsigned:
	mov	ebx,0
.dword: mov	eax,[rsp+12]
	call	prnintd
	call	prnspace
	mov	eax,[rsp+8]
	call	prnintd
	mov	al,'|'
	call	prnchr
	mov	eax,[rsp+4]
	call	prnintd
	call	prnspace
	mov	eax,[rsp]
	call	prnintd
	jmp	.done
.qword_unsigned:
	mov	rax,[rsp+8]
	call	prnintu
	mov	al,'|'
	call	prnchr
	mov	rax,[rsp]
	call	prnintu
	jmp	.done
.qword_signed:
	mov	rax,[rsp+8]
	call	prnint
	mov	al,'|'
	call	prnchr
	mov	rax,[rsp]
	call	prnint
	jmp	.done
.singles:
	mov	eax,[rsp+12]
	call	prnfltr
	mov	al,'|'
	call	prnchr
	mov	eax,[rsp+8]
	call	prnfltr
	mov	al,'|'
	call	prnchr
	mov	eax,[rsp+4]
	call	prnfltr
	mov	al,'|'
	call	prnchr
	mov	eax,[rsp]
	call	prnfltr
	jmp	.done
.doubles:	
	mov	rax,[rsp+8]
	call	prndblr
	mov	al,'|'
	call	prnchr
	mov	rax,[rsp]
	call	prndblr
	jmp	.done
.hex:	mov	rax,[rsp+8]
	call	prnhex
	mov	al,'|'
	call	prnchr
	mov	rax,[rsp]
	call	prnhex
	jmp	.done
.hexu:	mov	rax,[rsp+8]
	call	prnhexu
	mov	al,'|'
	call	prnchr
	mov	rax,[rsp]
	call	prnhexu
	jmp	.done
.err:	mov	al,'#'
	call	prnchr
.done:	add	rsp,16
	pop	rbx
	pop	rax
	ret
;----------------------------------
;dumpxmm(1)
;Dump XMM registers
;----------------------------------
;RAX	: Type of display:
;	  0 - Unsigned integer BYTE
;	  1 - Signed integer BYTE
;	  2 - Unsigned integer WORD
;	  3 - Signed integer WORD
;	  4 - Unsigned integer DWORD
;	  5 - Signed integer DWORD
;	  6 - Unsigned integer QWORD
;	  7 - Signed integer QWORD
;	  8 - Singles
;	  9 - Doubles
;	  10 - Unsigned hex QWORD
;	  11 - Signed hex QWORD
;----------------------------------
;Ret	: -
;Note	: -
;----------------------------------
align 8
dumpxmm:
	push	rax
	push	rcx
	push	rbx
	push	rdx
	mov	rcx,rax
	cmp	rcx,11
	ja	.done
	xor	rdx,rdx
.again: mov	rax,'XMM'
	call	prnstreg
	mov	rax,rdx
	call	prnintu
	cmp	rdx,9
	ja	.nope
	call	prnspace
.nope:	mov	rax,': '
	call	prnstreg
	mov	rax,rdx
	mov	rbx,rcx
	call	prnxmm
	add	rdx,1
	cmp	rdx,16
	jz	.done
	call	prnline
	jmp	.again
.done:	call	prnline
	pop	rdx
	pop	rbx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;clearxmm
;Clear all xmm registers
;-------------------------------
;Arg	: -
;-------------------------------
;Ret	: -
;Note	: -
;-------------------------------
align 8
clearxmm:
	pxor	xmm0,xmm0
	pxor	xmm1,xmm1
	pxor	xmm2,xmm2
	pxor	xmm3,xmm3
	pxor	xmm4,xmm4
	pxor	xmm5,xmm5
	pxor	xmm6,xmm6
	pxor	xmm7,xmm7
	pxor	xmm8,xmm8
	pxor	xmm9,xmm9
	pxor	xmm10,xmm10
	pxor	xmm11,xmm11
	pxor	xmm12,xmm12
	pxor	xmm13,xmm13
	pxor	xmm14,xmm14
	pxor	xmm15,xmm15
	ret
;---------------------------------
;prnymm(2)
;Display YMM register
;---------------------------------
;RBX	: Display as;
;	  0 - Floats
;	  1 - Doubles
;RAX	: Register number
;---------------------------------
;Ret	: -
;Note	: Needs AVX CPU
;	: Use qqword for transfers
;---------------------------------
align 8
prnymm:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,32
	mov	rdi,rax
	mov	rsi,rbx
	mov	eax,1
	cpuid
	bt	ecx,28
	jc	.avx
	mov	rax,'avx#'
	call	prnstreg
	jmp	.done
.avx:	mov	rbx,rsi
	mov	rax,rdi
	cmp	rax,0
	je	.ymm0
	cmp	rax,1
	je	.ymm1
	cmp	rax,2
	je	.ymm2
	cmp	rax,3
	je	.ymm3
	cmp	rax,4
	je	.ymm4
	cmp	rax,5
	je	.ymm5
	cmp	rax,6
	je	.ymm6
	cmp	rax,7
	je	.ymm7
	cmp	rax,8
	je	.ymm8
	cmp	rax,9
	je	.ymm9
	cmp	rax,10
	je	.ymm10
	cmp	rax,11
	je	.ymm11
	cmp	rax,12
	je	.ymm12
	cmp	rax,13
	je	.ymm13
	cmp	rax,14
	je	.ymm14
	cmp	rax,15
	je	.ymm15
	jmp	.done
.ymm0:	vmovdqu [rsp],ymm0
	jmp	.next
.ymm1:	vmovdqu [rsp],ymm1
	jmp	.next
.ymm2:	vmovdqu [rsp],ymm2
	jmp	.next
.ymm3:	vmovdqu [rsp],ymm3
	jmp	.next
.ymm4:	vmovdqu [rsp],ymm4
	jmp	.next
.ymm5:	vmovdqu [rsp],ymm5
	jmp	.next
.ymm6:	vmovdqu [rsp],ymm6
	jmp	.next
.ymm7:	vmovdqu [rsp],ymm7
	jmp	.next
.ymm8:	vmovdqu [rsp],ymm8
	jmp	.next
.ymm9:	vmovdqu [rsp],ymm9
	jmp	.next
.ymm10: vmovdqu [rsp],ymm10
	jmp	.next
.ymm11: vmovdqu [rsp],ymm11
	jmp	.next
.ymm12: vmovdqu [rsp],ymm12
	jmp	.next
.ymm13: vmovdqu [rsp],ymm13
	jmp	.next
.ymm14: vmovdqu [rsp],ymm14
	jmp	.next
.ymm15: vmovdqu [rsp],ymm15
.next:	cmp	rbx,0
	je	.float
	mov	rax,[rsp+24]
	call	prndblr
	push	'|'
	call	prnchrs
	mov	rax,[rsp+16]
	call	prndblr
	push	'|'
	call	prnchrs
	mov	rax,[rsp+8]
	call	prndblr
	push	'|'
	call	prnchrs
	mov	rax,[rsp]
	call	prndblr
	jmp	.done
.float: mov	eax,[rsp+28]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+24]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+20]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+16]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+12]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+8]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp+4]
	call	prnfltr
	push	'|'
	call	prnchrs
	mov	eax,[rsp]
	call	prnfltr
.done:	add	rsp,32
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret
;----------------------------------
;dumpymm(1)
;Dump YMM registers
;----------------------------------
;RAX	: Type of display:
;	  0 - Floats
;	  1 - Doubles
;----------------------------------
;Ret	: -
;Note	: Needs AVX CPU
;----------------------------------
align 8
dumpymm:
	push	rax
	push	rcx
	push	rbx
	push	rdx
	push	rax
	mov	eax,1
	cpuid
	bt	ecx,28
	jc	.avx
	mov	rax,'avx#'
	call	prnstreg
	pop	rax
	jmp	.done
.avx:	pop	rcx
	cmp	rcx,1
	ja	.done
	xor	rdx,rdx
.again: mov	rax,'YMM'
	call	prnstreg
	mov	rax,rdx
	call	prnintu
	cmp	rdx,9
	ja	.nope
	call	prnspace
.nope:	mov	rax,': '
	call	prnstreg
	mov	rax,rdx
	mov	rbx,rcx
	call	prnymm
	add	rdx,1
	cmp	rdx,16
	jz	.done
	call	prnline
	jmp	.again
.done:	call	prnline
	pop	rdx
	pop	rbx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;clearymm
;Clear all ymm registers
;-------------------------------
;Arg	: -
;-------------------------------
;Ret	: -
;Note	: Needs AVX CPU
;-------------------------------
align 8
clearymm:
	push	rax
	push	rcx
	push	rdx
	push	rbx
	mov	eax,1
	cpuid
	bt	ecx,28
	jc	.avx
	mov	rax,'avx#'
	call	prnstreg
	jmp	.done
.avx:	vzeroall
.done:	pop	rbx
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;prnintd(2)
;Display 32-bit Decimal
;-------------------------------
;RBX	: 0-unsigned. 1-signed
;EAX	: Value to display.
;-------------------------------
;Ret	: -
;Note	: Internal use
;-------------------------------
align 8
prnintd:
	push	rax
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	sub	rsp,16
	xor	rsi,rsi
	test	bl,bl
	jz	.nop
	test	eax,eax
	jns	.nop
	neg	eax
	mov	rsi,1
.nop:	mov	rdi,rsp
	add	rdi,15
	mov	byte[rdi],0
	dec	rdi
	mov	ecx,10
.go:	xor	rdx,rdx
	div	ecx
	add	dl,30h
	mov	[rdi],dl
	dec	rdi
	test	eax,eax
	jnz	.go
	test	bl,bl
	jz	.done
	test	rsi,rsi
	jz	.done
	mov	byte[rdi],'-'
	dec	rdi
.done:	mov	rax,rdi
	add	rax,1
	call	prnstrz
	add	rsp,16
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;prnintw(2)
;Display 16-bit Decimal
;-------------------------------
;RBX	: 0-unsigned. 1-signed
;AX	: Value to display.
;-------------------------------
;Ret	: -
;Note	: Internal use
;-------------------------------
align 8
prnintw:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	sub	rsp,16
	xor	rsi,rsi
	test	bl,bl
	jz	.nop
	test	ax,ax
	jns	.nop
	neg	ax
	mov	rsi,1
.nop:	mov	rdi,rsp
	add	rdi,15
	mov	byte[rdi],0
	dec	rdi
	mov	cx,10
.go:	xor	rdx,rdx
	div	cx
	add	dl,30h
	mov	[rdi],dl
	sub	rdi,1
	test	ax,ax
	jnz	.go
	test	bl,bl
	jz	.nope
	test	rsi,rsi
	jz	.nope
	mov	byte[rdi],'-'
	dec	rdi
.nope:	mov	rax,rdi
	add	rax,1
	call	prnstrz
	add	rsp,16
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret
;-------------------------------
;prnintb(2)
;Display Byte Decimal
;-------------------------------
;RBX	: 0-unsigned. 1-signed
;AL	: Value to display.
;-------------------------------
;Ret	: -
;Note	: Internal use
;-------------------------------
align 8
prnintb:
	push	rax
	push	rdx
	push	rcx
	push	rbx
	push	rdi
	push	rsi
	sub	rsp,16
	cld
	mov	rdi,rsp
	mov	cl,10
	xor	rsi,rsi
	mov	dl,bl
	xor	rbx,rbx
	test	dl,dl
	jz	.nope
	test	al,al
	jns	.nope
	mov	byte[rdi],'-'
	add	rdi,1
	neg	al
.nope:	xor	ah,ah
	div	cl
	mov	bl,ah
	push	rbx
	add	rsi,1
	test	al,al
	jnz	.nope
.ok:	pop	rax
	add	al,30h
	stosb
	sub	rsi,1
	jnz	.ok
	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,16
	pop	rsi
	pop	rdi
	pop	rbx
	pop	rcx
	pop	rdx
	pop	rax
	ret
;---------------------------------------
;int2str(4)
;Convert int to string
;---------------------------------------
;RDX	: Signness. 0=unsigned. 1=signed
;RCX	: Target base (2, 8, 10 or 16)
;RBX	: Buffers address
;RAX	: Value
;---------------------------------------
;Ret	: String in the sent buffer
;Note	: Buffer size must reflect # of digits
;	: String will be 0-ended
;---------------------------------------
align 8
int2str:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	cld
	mov	rdi,rbx
	test	rax,rax
	jnz	.ok
	mov	al,'0'
	stosb
	jmp	.done
.ok:	test	rdx,rdx
	jz	.uns
	test	rax,rax
	jns	.uns
	neg	rax
	mov	byte[rdi],'-'
	add	rdi,1
.uns:	cmp	rcx,2
	je	.bin
	cmp	rcx,8
	je	.oct
	cmp	rcx,10
	je	.dec
	cmp	rcx,16
	je	.hex
	mov	al,'#'
	call	prnchr
	jmp	.done
.bin:	mov	rdx,rax
	bsr	rcx,rax
.next:	mov	al,'0'
	bt	rdx,rcx
	jnc	.zero
	mov	al,'1'
.zero:	stosb
	sub	rcx,1
	jns	.next
	jmp	.done
.dec:
.oct:	xor	rbx,rbx
.nxt:	xor	rdx,rdx
	div	rcx
	push	rdx
	inc	rbx
	test	rax,rax
	jnz	.nxt
.get:	pop	rax
	add	al,30h
	stosb
	sub	rbx,1
	jnz	.get
	jmp	.done
.hex:	mov	rbx,rax
.leadz: xor	rax,rax
	shld	rax,rbx,4
	test	al,al
	jnz	.more
	shl	rbx,4
	jmp	.leadz
.more:	xor	rax,rax
	shld	rax,rbx,4
	add	al,30h
	cmp	al,'9'
	jbe	.low
	add	al,7
.low:	stosb
.skip:	shl	rbx,4
	jnz	.more
.done:	xor	al,al
	stosb
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret
;-----------------------------------------
;str2int(1)/1
;Convert 0-ended string to integer
;-----------------------------------------
;RAX	: Address of the 0-ended string
;-----------------------------------------
;Ret	: Integer in RAX
;Note	: Expected Suffix- b(bin), d(dec)
;	: h(hex), o,q(octal). 'd' is optional
;	: String must be of type DB
;	: Digits string must be valid
;-----------------------------------------
align 8
str2int:
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	r8
	mov	rsi,rax
	xor	rdi,rdi
	xor	r8,r8
	call	str_toupper
	call	str_length
	mov	rcx,rax
	mov	rbx,rax
	mov	al,[rsi]
	add	rsi,1
	cmp	al,'-'
	jne	.nope
	sub	rbx,1
	mov	r8b,1
	jmp	.pen
.get1:	mov	al,[rsi]
	add	rsi,1
.nope:	push	rax
.pen:	sub	rcx,1
	jnz	.get1
	sub	rbx,1
	pop	rax
	cmp	al,'H'
	je	.hex
	cmp	al,'O'
	je	.oct
	cmp	al,'Q'
	je	.oct
	cmp	al,'B'
	je	.bin
	cmp	al,'D'
	je	.dec
	push	rax
	add	rbx,1
.dec:	mov	rcx,rbx
	mov	rbx,1
	mov	rsi,10
.loopd: pop	rax
	cmp	al,0x27
	je	.skipd
	cmp	al,'_'
	je	.skipd
	sub	al,30h
	mul	rbx
	add	rdi,rax
	mov	rax,rsi
	mul	rbx
	mov	rbx,rax
.skipd: sub	rcx,1
	jnz	.loopd
	jmp	.done
.oct:	mov	rcx,rbx
	mov	rbx,1
	mov	rsi,8
.loopo: pop	rax
	cmp	al,0x27
	je	.skipo
	cmp	al,'_'
	je	.skipo
	sub	al,30h
	mul	rbx
	add	rdi,rax
	mov	rax,rsi
	mul	rbx
	mov	rbx,rax
.skipo: sub	rcx,1
	jnz	.loopo
	jmp	.done
.bin:	mov	rcx,rbx
	xor	rsi,rsi
.loopb: pop	rax
	cmp	al,0x27
	je	.skipb
	cmp	al,'_'
	je	.skipb
	cmp	al,'1'
	jne	.zero
	bts	rdi,rsi
.zero:	add	rsi,1
.skipb: sub	rcx,1
	jnz	.loopb
	jmp	.done
.hex:	mov	rcx,rbx
	mov	rbx,1
	mov	rsi,16
.looph: pop	rax
	cmp	al,0x27
	je	.skiph
	cmp	al,'_'
	je	.skiph
	cmp	al,'9'
	jbe	.norm
	sub	al,7h
.norm:	sub	al,30h
	mul	rbx
	add	rdi,rax
	mov	rax,rsi
	mul	rbx
	mov	rbx,rax
.skiph: sub	rcx,1
	jnz	.looph
	jmp	.done
.done:	test	r8,r8
	jz	.ok
	neg	rdi
.ok:	mov	rax,rdi
	pop	r8
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;------------------------------------
;str2dbl(1)/1
;Convert string to double
;------------------------------------
;RAX	: Address of a 0-ended string
;------------------------------------
;Ret	: Double-precision in RAX
;Note	: -
;------------------------------------
align 8
str2dbl:
	push	rbp
	mov	rbp,rsp
	sub	rsp,544
	and	rsp,-16
	fxsave	[rsp]
	push	rcx
	push	rbx 
	push	rdx 
	push	rsi
	push	rdi
	mov	rcx,0x3ff0000000000000
	mov	[rbp-12],rcx
	mov	ebx,0x41200000
	mov	[rbp-4],ebx
	mov	rsi,rax
	xor	rax,rax
	xor	rdi,rdi
	mov	al,[rsi]
	xor	rbx,rbx
	cmp	al,'-'
	jne	.ok
	mov	rdi,1
.again: add	rsi,1
	mov	al,[rsi]
.ok:	cmp	al,0
	je	.done
	cmp	al,'.'
	jne	.point
	mov	rdx,rbx
	jmp	.again
.point: sub	al,30h
	push	rax
	add	rbx,1
	jmp	.again
.done:	pop	qword[rbp-28]
	fninit
	fild	qword[rbp-28]
	fstp	qword[rbp-20]	
	mov	rcx,rbx
	sub	rcx,1
.rr:	fld	qword[rbp-12]
	fmul	dword[rbp-4]
	fst	qword[rbp-12]
	pop	qword[rbp-28]	
	fild	qword[rbp-28]	
	fmul	st0,st1
	fld	qword[rbp-20]	
	fadd	st0,st1 		 
	fstp	qword[rbp-20]	
	fstp	st0
	fstp	st0
	sub	rcx,1
	jnz	.rr
	mov	rcx,rbx
	sub	rcx,rdx
	fld	qword[rbp-20]
.d:	fdiv	dword[rbp-4]
	sub	rcx,1
	jnz	.d
.quit:	fstp	qword[rbp-20]
	mov	rax,[rbp-20]
	cmp	rdi,1
	jne	.out
	bts	rax,63
.out:	pop	rdi
	pop	rsi
	pop	rdx
	pop	rbx 
	pop	rcx 
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;------------------------------------
;str2flt(1)/1
;Convert string to float
;------------------------------------
;RAX	: Address of a 0-ended string
;------------------------------------
;Ret	: Single-precision in EAX
;Note	: -
;------------------------------------
align 8
str2flt:
	push	rbp
	mov	rbp,rsp
	sub	rsp,544
	and	rsp,-16
	fxsave	[rsp]
	push	rcx
	push	rbx 
	push	rdx 
	push	rsi
	push	rdi
	mov	dword[rbp-12],0x3f800000
	mov	dword[rbp-4],0x41200000
	xor	rbx,rbx
	mov	rsi,rax
	xor	rax,rax
	xor	rdi,rdi
	mov	al,[rsi]
	cmp	al,'-'
	jne	.ok
	mov	rdi,1
.again: add	rsi,1
	mov	al,[rsi]
.ok:	cmp	al,0
	je	.done
	cmp	al,'.'
	jne	.point
	mov	rdx,rbx
	jmp	.again
.point: sub	al,30h
	push	rax
	add	rbx,1
	jmp	.again
.done:	pop	qword[rbp-28]
	fninit
	fild	dword[rbp-28]
	fstp	dword[rbp-20]
	mov	rcx,rbx
	sub	rcx,1
.rr:	fld	dword[rbp-12]
	fmul	dword[rbp-4]
	fst	dword[rbp-12]
	pop	qword[rbp-28]
	fild	dword[rbp-28]
	fmul	st0,st1
	fld	dword[rbp-20]
	fadd	st0,st1 		 
	fstp	dword[rbp-20]
	fstp	st0
	fstp	st0
	sub	rcx,1
	jnz	.rr
	mov	rcx,rbx
	sub	rcx,rdx
	fld	dword[rbp-20]
.d:	fdiv	dword[rbp-4]
	sub	rcx,1
	jnz	.d
.quit:	fstp	dword[rbp-20]
	mov	eax,[rbp-20]
	cmp	rdi,1
	jne	.out
	bts	rax,31
.out:	pop	rdi
	pop	rsi
	pop	rdx
	pop	rbx 
	pop	rcx 
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;------------------------------------
;dbl2int(1)/1
;Convert real to integer
;------------------------------------
;RAX	: FP value to convert
;------------------------------------
;Ret	: Integer in RAX
;Note	: Precision will be truncated
;	: Input must be in FP format
;	: Use sse_round for rounding
;------------------------------------
align 8
dbl2int:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16
	and	rsp,-16
	movdqa	[rsp],xmm0
	movq	xmm0,rax
	cvtsd2si rax,xmm0
	movdqa	xmm0,[rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;--------------------------------
;int2dbl(1)/1
;Convert integer to real
;--------------------------------
;RAX	: Integer value to convert
;--------------------------------
;Ret	: Real in RAX
;Note	: -
;--------------------------------
align 8
int2dbl:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16
	and	rsp,-16
	movdqa	[rsp],xmm0
	cvtsi2sd xmm0,rax
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------
;isint(1)/1
;Check if a double is a qualified integer
;----------------------------
;RAX	: FP value to check
;----------------------------
;Ret	: 0-no,1-yes
;Note	: Test normal FP values only
;----------------------------
align 8
isint:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rcx
	push	rax
	finit
	fld	qword[rsp]
	fxtract
	fstp	st0
	fistp	qword[rsp]
	pop	rcx
	add	rcx,12
	shl	rax,cl
	jz	.done
	mov	rax,-1
.done:	pop	rcx
	add	rax,1
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;------------------------------
;rndint/1
;Generate 1 random integer
;------------------------------
;RAX	: -
;------------------------------
;Ret	: Random integer in RAX
;Note	: 0x8088405 is Delphi's magic number
;------------------------------
align 8
rndint:
	push	rbx
	push	rdx
	rdtsc
	mov	rbx,rax
	mov	rax,0x8088405
	mul	rbx
	ror	rax,8
	pop	rdx
	pop	rbx
	ret
;-------------------------------
;rand(1)/1
;Get 1 random unsigned int
;-------------------------------
;RAX	: Max value (range, 0 to Max)
;-------------------------------
;Ret	: Random int in RAX
;Note	: 0 - MAX inclusive
;	: 0x8088405 is Delphi's magic number
;-------------------------------
align 8
rand:
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	mov	rbx,rax
	bsr	rcx,rax
	xor	rax,rax
	add	rcx,1
	bts	rax,rcx
	sub	rax,1
	mov	rcx,rax
	rdtsc
	mov	esi,0x8088405
	mul	rsi
	ror	rax,8
	and	rax,rcx
	cmp	rax,rbx
	jbe	.done
	shr	rax,1
.done:	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;-------------------------------
;randq(2)
;Generate unique random integers
;from 0 to MAX-1 and save in array
;-------------------------------
;RBX	: Addr. of array initialized to -1
;RAX	: MAX value
;-------------------------------
;Ret	: Random elements in array
;Note	: Example: MAX = 50
;	  elems TIMES 50 dq -1
;-------------------------------
align 8
randq:
	push	rax
	push	rbx
	push	rcx
	push	rdi
	mov	rcx,0
	mov	rdi,rax
.go:	mov	rax,rdi
	call	rand
	cmp	qword[rbx+rax*8],-1
	jne	.go
	mov	qword[rbx+rax*8],rcx
	add	rcx,1
	cmp	rcx,rdi
	jne	.go
	pop	rdi
	pop	rcx
	pop	rbx
	pop	rax
	ret
;----------------------------
;factorial(1)/1
;Get factorial
;----------------------------
;RAX	: +Value
;----------------------------
;Ret	: Factorial in RAX
;Note	: Limit to 20! only
;----------------------------
align 8
factorial:
	push	rbx
	push	rcx
	push	rdx
	cmp	rax,20
	jbe	.nxt1
	xor	rdx,rdx
	jmp	.done
.nxt1:	cmp	rax,1
	ja	.nxt
	mov	edx,1
	jmp	.done
.nxt:	xor	rdx,rdx
	mov	rcx,rax
	sub	rcx,1
	mov	rbx,rax
	sub	rbx,1
.go:	mul	rbx
	add	rdx,rax
	sub	rbx,1
	sub	rcx,1
	jnz	.go
.done:	mov	rax,rdx
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;---------------------------------
;powint(2)/1
;Calculate 64-bit integral power
;---------------------------------
;RBX	: +Exponent/power (int)
;RAX	: Base (int)
;---------------------------------
;Ret	: Result in RAX
;	: # if overflow
;Note	: Var must be of type DQ
;	: Takes +exponent only
;---------------------------------
align 8
powint:
	push	rdx
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	xor	rsi,rsi
	test	rax,rax
	jns	.ok
	neg	rax
	mov	rsi,1
.ok:	mov	rcx,rax
	cmp	rax,2
	je	.base2
	cmp	rbx,1
	jz	.done
	cmp	rbx,0
	jnz	.nxt
	mov	rax,1
	jmp	.done
.nxt:	test	rbx,rbx
	jnz	.again
	mov	rax,1
	jmp	.done
.again: mul	rcx
	jo	.overflow
	sub	rbx,1
	cmp	rbx,1
	je	.done
	jmp	.again
.base2: mov	rax,1
	mov	rcx,rbx
	shl	rax,cl
	jnz	.done
.overflow:
	mov	al,'#'
	call	prnchr
	xor	rax,rax
	jmp	.ok2
.done:	test	rsi,rsi
	jz	.ok2
	neg	rax
.ok2:	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rdx
	ret
;-------------------------------
;pow2(1)/1
;Calculate 2^n
;-------------------------------
;RAX	: +pow (int). Max=63
;-------------------------------
;Ret	: raised integer
;Note	: RAX must be integer
;-------------------------------
align 8
pow2:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	cmp	rax,63
	jbe	.ok
	push	'#'
	call	prnchrs
	jmp	.done
.ok:	push	rax
	finit
	fild	qword[rsp]
	fld1
	fscale
	fistp	qword[rsp]
	pop	rax
.done:	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;--------------------------------
;iseven(1)/1
;Check if even number
;--------------------------------
;RAX	: Number to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	:
;--------------------------------
align 8
iseven:
	shr	ax,1
	jnc	.yes
	mov	eax,0
	ret
.yes:	mov	eax,1
	ret
;--------------------------------
;isodd(1)/1
;Check if odd number
;--------------------------------
;RAX	: Integer to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	:
;--------------------------------
align 8
isodd:
	shr	ax,1
	jc	.yes
	mov	eax,0
	ret
.yes:	mov	eax,1
	ret
;--------------------------------------
;bconv(2)
;Convert and display integer
;--------------------------------------
;RBX	: Display base to use (2 to 36)
;RAX	: Integer to convert
;--------------------------------------
;Ret	: -
;Note	: Imm value is limited to 32-bit
;--------------------------------------
align 8
bconv:
	push	rdx 
	push	rax 
	push	rcx
	push	rbx
	xor	rcx,rcx
.start: xor	rdx,rdx
	div	rbx
	push	rdx
	add	rcx,1
	test	rax,rax
	jnz	.start
.fine:	pop	rax
	add	al,0x30
	cmp	rax,0x39
	jbe	.num
	add	al,7
.num:	call	prnchr
	sub	rcx,1
	jnz	.fine
.done:	pop	rbx
	pop	rcx
	pop	rax 
	pop	rdx 
	ret
;-------------------------------------
;bitfield(3)
;Display a bitfield from a 64-bit data
;-------------------------------------
;RCX	: lower bit
;RBX	: higher bit
;RAX	: Value to be extracted from
;-------------------------------------
;Ret	: -
;Note	: Display bit range
;-------------------------------------
align 8
bitfield:
	push	rbx
	push	rdi 
	push	rsi
	push	rax
	sub	rsp,72
	mov	rdi,rsp
	mov	rsi,rax
.no:	mov	al,'0'
	bt	rsi,rbx
	jnc	.zero
	mov	al,'1'
.zero:	stosb
	cmp	rbx,rcx
	je	.done
	sub	rbx,1
	jmp	.no
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	add	rsp,72
	pop	rax
	pop	rsi
	pop	rdi 
	pop	rbx 
	ret
;-----------------------------
;addf(2)/1
;Floating Point ADD
;-----------------------------
;RBX	: Value 2 in FP format
;RAX	: Value 1 in FP format
;-----------------------------
;Ret	: Value in RAX
;Note	: RAX=RAX+RBX
;-----------------------------
align 8
addf:
	push	rbp				
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0		
	movdqa	[rsp+16],xmm1	
	movq	xmm0,rax
	movq	xmm1,rbx
	addsd	xmm0,xmm1		
	movq	rax,xmm0		
	movdqa	xmm0,[rsp]		
	movdqa	xmm1,[rsp+16]	
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;subf(2)/1
;Floating Point SUB
;-----------------------------
;RBX	: Value 2 in FP format
;RAX	: Value 1 in FP format
;-----------------------------
;Ret	: Value in RAX
;Note	: RAX=RAX-RBX
;-----------------------------
align 8
subf:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	movq	xmm0,rax
	movq	xmm1,rbx
	subsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;mulf(2)/1
;Floating Point MUL
;-----------------------------
;RBX	: Value 2 in FP format
;RAX	: Value 1 in FP format
;-----------------------------
;Ret	: Value in RAX
;Note	: RAX=RAX*RBX
;-----------------------------
align 8
mulf:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	movq	xmm0,rax
	movq	xmm1,rbx
	mulsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;divf(2)/1
;Floating Point DIV
;-----------------------------
;RBX	: Divisor in FP format
;RAX	: Dividend in FP format
;-----------------------------
;Ret	: Value in RAX
;Note	: RAX=RAX/RBX
;-----------------------------
align 8
divf:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	movq	xmm0,rax
	movq	xmm1,rbx
	divsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------
;pow(2)/1
;Calculate x^n
;---------------------------------
;RBX	: pow (fp)
;RAX	: +base (fp)
;---------------------------------
;Ret	: raised value (double)
;Note	: Args. must be in doubles
;	: base must be positive
;---------------------------------
align 8
pow:
	push	 rbp
	mov	 rbp,rsp
	sub	 rsp,512
	and	 rsp,-16
	fxsave	 [rsp]
	push	 rbx
	push	 rax
	finit
	fld	 qword[rsp+8]
	fld	 qword[rsp]
	fyl2x	 ;n*log2(x)
	fld	 st0
	frndint
	fxch
	fsub	 st0,st1
	f2xm1
	fld1
	faddp	 st1,st0
	fscale
	fstp	 qword[rsp]
	pop	 rax
	pop	 rbx
	fxrstor  [rsp]
	mov	 rsp,rbp
	pop	 rbp
	ret
;--------------------------
;log10(1)/1
;Find Common Log of Base 10
;--------------------------
;RAX	: +Real value in FP
;--------------------------
;Ret	: Value in RAX
;Note	: -
;--------------------------
align 8
log10:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	finit
	fldlg2
	fld	qword[rsp]
	fyl2x
	fstp	qword[rsp]
	mov	rax,[rsp]
	add	rsp,8
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;--------------------------
;ln10(1)/1
;Find Natural Log
;--------------------------
;RAX	: +Real value in FP
;--------------------------
;Ret	: Value in RAX
;Note	: -
;--------------------------
align 8
ln10:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	finit
	fldln2
	fld	qword[rsp]
	fyl2x
	fstp	qword[rsp]
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;sqroot(1)/1
;Get square root of a given value
;---------------------------------------
;RAX	: +FP double to be squared
;---------------------------------------
;Ret	: Square root value in RAX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
sqroot:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	btr	rax,63
	movq	xmm1,rax
	sqrtsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;fcalc(3)/1
;Two-Operands FP Calculator
;RAX = RAX op RBX
;-----------------------------
;RCX	: Operations:
;	  0 = +
;	  1 = -
;	  2 = *
;	  3 = /
;	  4 = ^
;RBX	: Value 2 in FP format
;RAX	: Value 1 in FP format
;-----------------------------
;Ret	: Value in RAX
;Note	: -
;-----------------------------
align 8
fcalc:
	push	rbp				
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	finit
	movq	xmm0,rax
	movq	xmm1,rbx
	cmp	ecx,0
	je	.add
	cmp	ecx,1
	je	.sub
	cmp	ecx,2
	je	.mul
	cmp	ecx,3
	je	.div
	cmp	ecx,4
	je	.pow
	push	'#'
	call	prnchrs
	jmp	.err
.add:	addsd	xmm0,xmm1
	jmp	.done
.sub:	subsd	xmm0,xmm1
	jmp	.done
.mul:	mulsd	xmm0,xmm1
	jmp	.done
.div:	divsd	xmm0,xmm1
	jmp	.done
.pow:	push	rbx
	push	rax
	fld	qword[rsp+8]
	fld	qword[rsp]
	fyl2x
	fld	st0
	frndint
	fxch
	fsub	st0,st1
	f2xm1
	fld1
	faddp	st1,st0
	fscale
	fstp	qword[rsp]
	pop	rax
	pop	rbx
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
.done:	movq	rax,xmm0
.err:	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;rad2deg(1)/1
;Convert Radian to Degree
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: DEGREE value in RAX
;Note	: Var should be init as FP (0.0)
;	: degree sym = 0xf8
;	: 57.295779513
;---------------------------------------
align 8
rad2deg:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	movq	xmm0,rax
	mov	rax,0x404CA5DC1A6394B6
	movq	xmm1,rax
	mulsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;deg2rad(1)/1
;Convert Degree to Radian
;---------------------------------------
;RAX	: FP value in DEGREE
;---------------------------------------
;Ret	: RADIAN value in RAX
;Note	: Var should be init as FP (0.0)
;	: 0.0174532925
;---------------------------------------
align 8
deg2rad:
	push	rbp
	mov	rbp,rsp
	sub	rsp,32
	and	rsp,-16
	movdqa	[rsp],xmm0
	movdqa	[rsp+16],xmm1
	movq	xmm0,rax
	mov	rax,0x3F91DF46A1FAE711
	movq	xmm1,rax
	mulsd	xmm0,xmm1
	movq	rax,xmm0
	movdqa	xmm0,[rsp]
	movdqa	xmm1,[rsp+16]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;sine(1)/1
;Get sine value
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: Sine value in RAX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
sine:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	finit
	push	rax
	fld	qword[rsp]
	fsin
	fstp	qword[rsp]
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;tangent(1)/1
;Get tangent
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: Tangent value in RAX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
tangent:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	finit
	push	rax
	fld	qword[rsp]
	fptan
	fxch
	fstp	qword[rsp]
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;cosine(1)/1
;Get cosine value
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: Cosine value in RAX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
cosine:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	finit
	push	rax
	fld	qword[rsp]
	fcos
	fstp	qword[rsp]
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;sincos(1)/2
;Get Sine and Cosine
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: Sine in RAX
;	: Cosine in RBX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
sincos:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rbx
	push	rax
	finit
	fld	qword[rsp]
	fsincos
	fstp	qword[rsp]
	pop	rbx
	fstp	qword[rsp]
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;---------------------------------------
;atangent(1)/1
;Get arc-tangent
;---------------------------------------
;RAX	: FP value in RADIAN
;---------------------------------------
;Ret	: arc Tangent value in RAX
;Note	: Var should be init as FP (0.0)
;---------------------------------------
align 8
atangent:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	finit
	fld	qword[rsp]
	fld1
	fpatan
	fstp	qword[rsp]
	mov	rax,[rsp]
	add	rsp,8
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;--------------------------------
;chr_isdigit(1)/1
;Check if alphanumeric digit
;--------------------------------
;AL	: Char to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	: Digit '0' to '9' only.
;--------------------------------
align 8
chr_isdigit:
	cmp	al,'9'
	ja	.nope
	cmp	al,'0'
	jb	.nope
	mov	eax,1
	ret
.nope:	xor	eax,eax
	ret
;--------------------------------
;chr_isalpha(1)/1
;Check if alphabet 
;--------------------------------
;AL	: Char to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	: 'A'-'Z' and 'a'-'z'
;--------------------------------
align 8
chr_isalpha:
	and	al,0xdf
	cmp	al,'A'
	jb	.nope
	cmp	al,'Z'
	ja	.nope
	mov	eax,1
	ret
.nope:	xor	eax,eax
	ret
;--------------------------------
;chr_islower(1)/1
;Check if lowercase
;--------------------------------
;AL	: Character to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	:
;--------------------------------
align 8
chr_islower:
	bt	ax,5
	jc	.yes
	xor	eax,eax
	ret
.yes:	mov	eax,1
	ret
;--------------------------------
;chr_isupper(1)/1
;Check if uppercase
;--------------------------------
;AL	: Character to check
;--------------------------------
;Ret	: RAX - 0 if no. 1 if yes
;Note	:
;--------------------------------
align 8
chr_isupper:
	bt	ax,5
	jnc	.yes
	xor	eax,eax
	ret
.yes:	mov	eax,1
	ret
;---------------------------------
;chr_change(3)
;Change characters from a 0-ended string
;to a char in CL
;---------------------------------
;CL	: Char substitute
;BL	: The char to change
;RAX	: Source address
;---------------------------------
;Ret	: -
;Note	: String is modified
;---------------------------------
align 8
chr_change:
	push	rax
	push	rdx
	push	rdi
	push	rsi
	mov	rsi,rax
	call	str_length
	mov	rdi,rax
.more:	mov	dl,[rsi]
	cmp	bl,dl
	jnz	.nope
	mov	[rsi],cl
.nope:	inc	rsi
	sub	rdi,1
	jnz	.more
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rax
	ret
;----------------------------
;chr_chcase(1)/1
;Alternate character case
;----------------------------
;AL	: Character to change
;----------------------------
;Ret	: RAX. Modified char
;Note	:
;----------------------------
align 8
chr_chcase:
	btc	eax,5
	ret
;-----------------------------
;chr_toupper(1)/1
;Change to uppercase
;-----------------------------
;AL	: Character to change
;-----------------------------
;Ret	: RAX. Modified char
;Note	:
;-----------------------------
align 8
chr_toupper:
	and	al,0xdf
	ret
;-----------------------------
;chr_tolower(1)/1
;Change to lowercase
;-----------------------------
;AL	: Character to change
;-----------------------------
;Ret	: RAX. Modified char
;Note	:
;-----------------------------
align 8
chr_tolower:
	or	al,0x20
	ret
;----------------------------------------
;chr_find(2)/1
;Find byte from a 0-ended string
;----------------------------------------
;RBX	: String address to look from
;RAX	: Character to find
;----------------------------------------
;Ret	: Position in RAX. 0 if not found
;Note	: Will stop at first one found
;----------------------------------------
align 8
chr_find:
	push	rdi
	push	rbx
	mov	rdi,rbx
	xor	rbx,rbx
	cld
.again: scasb
	jz	.found
	cmp	byte[rdi],0
	jz	.nada
	add	rbx,1
	jmp	.again
.nada:	mov	rbx,-1
.found: mov	rax,rbx
	add	rax,1
	pop	rbx
	pop	rdi
	ret
;----------------------------------
;chr_count(2)/1
;Count a char from a 0-ended string
;----------------------------------
;RBX	: String's address
;RAX	: Character to count
;----------------------------------
;Ret	: Count in RAX. 0 if none
;Note	: -
;----------------------------------
align 8
chr_count:
	push	rdi
	push	rbx
	mov	rdi,rbx
	xor	rbx,rbx
	cld
.again: scasb
	jz	.found
.next:	cmp	byte[rdi],0
	jz	.ends
	jmp	.again
.found: add	rbx,1
	jmp	.next
.ends:	mov	rax,rbx
	pop	rbx
	pop	rdi
	ret
;-----------------------------------
;ascii(1)
;Display ASCII equivalences
;-----------------------------------
;AL	: Char or Hex value to display
;-----------------------------------
;Ret	: -
;Note	: -
;-----------------------------------
align 8
ascii:
	push	rcx
	push	rax
	and	rax,0xff
	mov	rcx,rax
	mov	al,cl
	call	prnchr
	mov	eax,' = '
	call	prnstreg
	mov	rax,rcx
	cmp	rax,15
	ja	.nope
	call	prnspace
	mov	rax,rcx
.nope:	call	prnhexu
	pop	rax
	pop	rcx
	ret
;---------------------------------
;chr_shuffle(1)
;Shuffle a 0-ended string
;---------------------------------
;RAX	: Address of target string
;------------------------------
;Ret	: The same string shuffled
;Note	: -
;---------------------------------
align 8
chr_shuffle:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	push	rbp
	mov	rbp,rsp
	mov	rsi,rax
	mov	rdx,rax
	call	str_length
	mov	rbx,rax
	mov	rcx,rax
	sub	rsp,rax
	and	rsp,-16
	mov	rdi,rsp
	mov	al,0
	rep	stosb
	mov	rcx,rbx
	mov	rdi,rsp
	push	rdx
	sub	rbx,1
.go:	mov	dl,[rsi]
.find:	mov	rax,rbx
	call	rand
	mov	dh,[rdi+rax]
	test	dh,dh		;occupied?
	jnz	.find		
	mov	[rdi+rax],dl
	inc	rsi
	sub	rcx,1
	jnz	.go
	mov	rcx,rbx
	pop	rdi
	add	rcx,1
	mov	rsi,rsp
	rep	movsb
	mov	rsp,rbp
	pop	rbp
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret
;-----------------------------------------
;str_copy(3)
;Copy a string to another array
;-----------------------------------------
;RCX	: Size of bytes to copy 
;RBX	: String's source address
;RAX	: String's target address
;-----------------------------------------
;Ret	: Copied string at the sent address
;Note	: Target must fit the size to copy
;	: Arrays should be of type DB/RB
;-----------------------------------------
align 8
str_copy:
	push	rcx
	push	rsi
	push	rdi
	push	rax
	mov	rdi,rax
	mov	rsi,rbx
	rep	movsb
	pop	rax
	pop	rdi
	pop	rsi
	pop	rcx
	ret
;-------------------------------
;str_length(1)/1
;Find length of a 0-ended string
;-------------------------------
;RAX	: String's address
;-------------------------------
;Ret	: size in RAX.
;Note	: -
;-------------------------------
align 8
str_length:
	push	rdi
	push	rcx
	mov	rdi,rax
	mov	rcx,-1
	mov	al,0
	repne	scasb
	mov	rax,-2
	sub	rax,rcx
	pop	rcx
	pop	rdi
	ret
;-------------------------------
;str_length2(1)/1
;Fast string length (aligned)
;-------------------------------
;RAX	: String's address
;-------------------------------
;Ret	: size in RAX.
;Note	: String must be aligned 16
;-------------------------------
align 8
str_length2:
	push	rbp
	mov	rbp,rsp
	sub	rsp,16
	and	rsp,-16
	movdqa	[rsp],xmm0
	push	rsi
	push	rdx
	mov	rsi,rax
	pxor	xmm0,xmm0
	xor	rax,rax
.again: pcmpeqb xmm0,[rsi+rax]
	pmovmskb edx,xmm0
	test	rdx,rdx
	jnz	.zero
	add	rax,16
	jmp	.again
.zero:	bsf	rsi,rdx
	add	rax,rsi
	pop	rdx
	pop	rsi
	movdqa	xmm0,[rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;----------------------------------
;str_cmpz(2)/1
;Compare two 0-ended strings
;----------------------------------
;RBX	: String 1 address
;RAX	: String 2 address
;----------------------------------
;Ret	: RAX - 1 if Equal, 0 if not
;Note	: The two strings mus be 0-ended
;----------------------------------
align 8
str_cmpz:
	push	rdi
	push	rsi
	push	rbx
	push	rdx
	push	rcx
	mov	rsi,rbx
	mov	rdi,rax
	call	str_length
	mov	rbx,rax
	mov	rax,rsi
	call	str_length
	cmp	rax,rbx
	jnz	.nope
	mov	rcx,rax
	rep	cmpsb
	jz	.ok
.nope:	mov	eax,0
	jmp	.out
.ok:	mov	rax,1
.out:	pop	rcx
	pop	rdx
	pop	rbx
	pop	rsi
	pop	rdi
	ret
;---------------------------------
;str_cmp(3)/1
;Compare strings with size
;---------------------------------
;RCX	: Size of bytes to compare
;RBX	: String 1 address
;RAX	: String 2 address
;---------------------------------
;Ret	: RAX - 1 if Equal, 0 if not
;Note	: -
;---------------------------------
align 8
str_cmp:
	push	rdi
	push	rsi
	push	rcx
	add	rcx,1
	mov	rsi,rbx
	mov	rdi,rax
	xor	rax,rax
	repe	cmpsb
	jecxz	.done
	jmp	.out
.done:	mov	eax,1
.out:	pop	rcx
	pop	rsi
	pop	rdi
	ret
;--------------------------------------
;str_toupper(1)
;Change 0-ended string to upper case
;--------------------------------------
;RAX	: Address of the 0-ended string
;--------------------------------------
;Ret	: The same string converted
;Note	: -
;--------------------------------------
align 8
str_toupper:
	push	rsi
	push	rdi
	push	rax
	cld
	mov	rdi,rax
	mov	rsi,rax
.go:	mov	al,[rsi]
	add	rsi,1
	test	al,al
	jz	.done
	cmp	al,'z'
	ja	.nope
	cmp	al,'a'
	jb	.nope
	and	al,0xdf
.nope:	stosb
	jmp	.go
.done:	pop	rax
	pop	rdi
	pop	rsi
	ret
;--------------------------------------
;str_tolower(1)
;Change 0-ended string to lower case
;--------------------------------------
;RAX	: Address of the 0-ended string
;--------------------------------------
;Ret	: The same string converted
;Note	: -
;--------------------------------------
align 8
str_tolower:
	push	rsi
	push	rdi
	push	rax
	cld
	mov	rdi,rax
	mov	rsi,rax
.go:	mov	al,[rsi]
	add	rsi,1
	test	al,al
	jz	.done
	cmp	al,'Z'
	ja	.nope
	cmp	al,'A'
	jb	.nope
	or	al,0x20
.nope:	stosb
	jmp	.go
.done:	pop	rax
	pop	rdi
	pop	rsi
	ret
;-------------------------------------
;str_reverse(1)
;Reverse 0-ended string
;-------------------------------------
;RAX	: Address of the 0-ended string
;-------------------------------------
;Ret	: The same string reversed
;Note	: -
;-------------------------------------
align 8
str_reverse:
	push	rsi
	push	rdi
	push	rax
	push	rcx
	mov	rdi,rax
	mov	rsi,rax
	xor	rcx,rcx
.again: mov	al,[rsi]
	add	rsi,1
	test	al,al
	jz	.copy
	push	rax
	add	rcx,1
	jmp	.again
.copy:	pop	rax
	stosb
	sub	rcx,1
	jnz	.copy
.done:	pop	rcx
	pop	rax
	pop	rdi
	pop	rsi
	ret
;-------------------------------------
;str_trim(2)
;Trim a 0-ended string
;-------------------------------------
;RBX	: # of chars to cut
;RAX	: Address of the 0-ended string
;-------------------------------------
;Ret	: The same string trimmed
;Note	: -
;-------------------------------------
align 8
str_trim:
	push	rax
	push	rbx
	push	rsi
	mov	rsi,rax
	call	str_length
	cmp	rbx,rax
	jae	.done
	add	rsi,rax
.cut:	sub	rsi,1
	mov	byte[rsi],0
	sub	rbx,1
	jnz	.cut
.done:	pop	rsi
	pop	rbx
	pop	rax
	ret
;---------------------------------
;str_wordcnt(1)/1
;Count words of a 0-ended string
;---------------------------------
;RAX	: Address of string
;---------------------------------
;Ret	: Word count
;Note	: Single char is a word
;---------------------------------
align 8
str_wordcnt:
	push	rbx
	push	rsi
	xor	rbx,rbx
	mov	rsi,rax
.rep:	lodsb
	test	al,al
	jz	.back
	cmp	al,20h
	jz	.rep
	cmp	al,09h
	jz	.rep
.nxt:	lodsb
	test	al,al
	jz	.done
	cmp	al,20h
	jne	.nxt1
.bck:	add	rbx,1
	jmp	.rep
.nxt1:	cmp	al,09h
	jne	.nxt
	je	.bck
.back:	sub	rbx,1
.done:	mov	rax,rbx
	inc	rax
	pop	rsi
	pop	rbx
	ret
;------------------------------
;str_token(2)
;Display tokens off a 0-ended string
;------------------------------
;RBX	: Addr of 0-ended delimiter string
;RAX	: Addr of the string
;------------------------------
;Ret	: -
;Note	: eg, delimiter db '? .-',0
;------------------------------
align 8
str_token:
	push	rbp
	push	rdi
	push	rbx
	push	rax
	push	rcx
	push	rdx
	push	rsi
	mov	rbp,rsp
	mov	rsi,rax
	call	str_length
	sub	rsp,rax
	sub	rsp,1
	cld
	mov	rdi,rsp
	mov	rcx,1
.again: lodsb
	cmp	al,0
	jz	.done
	mov	dl,al
	call	chr_find
	test	rax,rax
	jnz	.hit		;delimiter hit
	xor	rcx,rcx
	mov	al,dl
	stosb
	jmp	.again
.hit:	test	rcx,rcx
	jnz	.again
	mov	al,0ah
	stosb
	add	rcx,1
	jmp	.again
.done:	xor	al,al
	stosb
	mov	rax,rsp
	call	prnstrz
	mov	rsp,rbp
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax
	pop	rbx
	pop	rdi
	pop	rbp
	ret
;--------------------------------------
;str_find(3)/1
;Search for a sub-string
;--------------------------------------
;RCX	: Size of source
;RBX	: Addr of 0-ended search string
;RAX	: Addr of source string
;--------------------------------------
;Ret	: Address. -1 -Not found
;Note	: Case-sensitive
;--------------------------------------
align 8
str_find:
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rsi,rax ;source string
	mov	rdi,rbx ;key string
	mov	rdx,rcx ;size
	mov	rax,rbx
	call	str_length
	mov	rcx,rax
	mov	rbx,rdi
.again: mov	rax,rsi
	call	str_cmp
	test	rax,rax
	jnz	.done
	add	rsi,1
	sub	rdx,1
	jnz	.again
	mov	rax,-1
	jmp	.exit
.done:	mov	rax,rsi
.exit:	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;--------------------------------------
;str_findz(2)/1
;Search for a sub-string from a C string
;--------------------------------------
;RBX	: Addr of 0-ended search string
;RAX	: Addr of 0-ended source string
;--------------------------------------
;Ret	: Location. -1 = Not found
;Note	: Case-sensitive
;--------------------------------------
align 8
str_findz:
	push	rbx
	push	rcx
	push	rdi
	push	rsi
	mov	rsi,rax ;source 
	mov	rdi,rbx ;key
	cld
	mov	rax,rdi
	call	str_length
	mov	rcx,rax
	mov	rbx,rdi
.next:	mov	rax,rsi
	call	str_cmp
	test	rax,rax
	jnz	.done
	lodsb
	test	al,al
	jnz	.next
	mov	rsi,-1
.done:	mov	rax,rsi
	pop	rsi
	pop	rdi
	pop	rcx
	pop	rbx
	ret
;-------------------------------------
;str_append(5)/1
;Combine two 0-ended strings with size
;-------------------------------------
;RDI	: # number of bytes to copy
;	  0 or -1 if copy all
;RDX	: Separator byte. 0-if none
;RCX	: Addr of buffer

;RBX	: Addr of second string
;RAX	: Addr of first string
;-------------------------------------
;Ret	: 0-ended combined string
;	: RAX - Combined string length
;Note	: 1st string + 2nd string
;	: Buffer must be large enough
;-------------------------------------
align 8
str_append:
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	push	rcx
	push	rdi
	mov	rsi,rax
	mov	rdi,rcx
	call	str_length
	mov	rcx,rax
	rep	movsb
	test	dl,dl
	jz	.nope
	mov	al,dl
	stosb
.nope:	pop	rcx
	cmp	rcx,0
	jg	.skip
	mov	rax,rbx
	call	str_length
	mov	rcx,rax
.skip:	mov	rsi,rbx
	rep	movsb
	xor	al,al
	stosb
	pop	rax
	call	str_length
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	ret
;-------------------------------------
;str_appendz(4)/1
;Combine two 0-ended strings
;-------------------------------------
;RDX	: Separator byte. 0-if none
;RCX	: Addr of buffer
;RBX	: Addr of second string
;RAX	: Addr of first string
;-------------------------------------
;Ret	: 0-ended combined string
;	: RAX - Combined string length
;Note	: 1st string + 2nd string
;	: Buffer must be large enough
;-------------------------------------
align 8
str_appendz:
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	push	rcx
	mov	rsi,rax
	mov	rdi,rcx
	call	str_length
	mov	rcx,rax
	rep	movsb
	test	dl,dl
	jz	.nope
	mov	al,dl
	stosb
.nope:	mov	rax,rbx
	call	str_length
	mov	rcx,rax
	mov	rsi,rbx
	rep	movsb
	xor	al,al
	stosb
	pop	rax
	call	str_length
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	ret
;-----------------------------
;sort_byte(3)
;Sort char/byte array
;-----------------------------
;RCX	: 0-ascending, 1-descending
;RBX	: Number of array elements
;RAX	: Address of array (DB)
;-----------------------------
;Ret	: Return the sorted array
;Note	: Elements are of type DB
;-----------------------------
align 8
sort_byte:
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rbp
	sub	rbx,1
	mov	rbp,rcx
	mov	rsi,rbx
.outer: mov	rdi,1
	push	rbx
	mov	cl,[rax]
.inner: mov	dl,[rax+rdi]
	test	rbp,rbp
	jnz	.down
	cmp	cl,dl
	jbe	.next
	jmp	.ok
.down:	cmp	cl,dl
	ja	.next
.ok:	mov	[rax+rdi],cl
	mov	[rax+rdi-1],dl
.next:	mov	cl,[rax+rdi]
	add	rdi,1
	sub	rbx,1
	jnz	.inner
	pop	rbx
	sub	rsi,1
	jnz	.outer
	pop	rbp
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;-----------------------------
;sort_int(3)
;Sort array of int
;-----------------------------
;RCX	: 0-ascending, 1-descending
;RBX	: Number of array elements
;RAX	: Address of array (DQ)
;-----------------------------
;Ret	: Return the sorted array
;Note	: Elements are of type DQ
;	: For signed integer
;-----------------------------
align 8
sort_int:
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rbp
	sub	rbx,1
	mov	rsi,rbx
	mov	rbp,rcx
.outer: mov	rdx,8
	push	rbx
	mov	rcx,[rax]
.inner: mov	rdi,[rax+rdx]
	test	rbp,rbp
	jnz	.down
	cmp	rcx,rdi
	jle	.next
	jmp	.ok
.down:	cmp	rcx,rdi
	jg	.next
.ok:	mov	[rax+rdx],rcx
	mov	[rax+rdx-8],rdi
.next:	mov	rcx,[rax+rdx]
	add	rdx,8
	sub	rbx,1
	jnz	.inner
	pop	rbx
	sub	rsi,1
	jnz	.outer
	pop	rbp
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;-----------------------------
;sort_dbl(3)
;Sort array of doubles
;-----------------------------
;RCX	: 0-ascending, 1-descending
;RBX	: Number of array elements
;RAX	: Address of array (DQ)
;-----------------------------
;Ret	: Return the sorted array
;Note	: Elements are of type DQ
;-----------------------------
align 8
sort_dbl:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rdx
	push	rsi
	mov	rsi,rax
	sub	rbx,1
	mov	rdx,rbx
	fninit
.inner: fld	qword[rax+8]
	fld	qword[rax]
	test	rcx,rcx
	jnz	.down
	fcomi	st1
	jb	.nope
	jz	.zero
	jmp	.ok
.down:	fcomi	st1
	ja	.nope
	jz	.zero
.ok:	fstp	qword[rax+8]
	fstp	qword[rax]
	jmp	.nxt
.zero:	test	rcx,rcx
	jnz	.zero1
	bt	qword[rax],63
	jnc	.ok
	fxch
	jmp	.nope
.zero1: bt	qword[rax],63
	jc	.ok
	fxch
.nope:	fstp	st0
	fstp	st0
.nxt:	add	rax,8
	sub	rbx,1
	jnz	.inner
	mov	rbx,rdx
	sub	rdx,1
	jz	.done
	mov	rax,rsi
	jmp	.inner
.done:	pop	rsi
	pop	rdx
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;sort_dblx(3)
;Sort array of extended doubles
;-----------------------------
;RCX	: 0-ascending, 1-descending
;RBX	: Number of array elements
;RAX	: Address of array (DT)
;-----------------------------
;Ret	: Return the sorted array
;Note	: Elements are of type DT
;-----------------------------
align 8
sort_dblx:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rdx
	push	rsi
	mov	rsi,rax
	sub	rbx,1
	mov	rdx,rbx
	fninit
.inner: fld	tword[rax+10]
	fld	tword[rax]
	test	rcx,rcx
	jnz	.down
	fcomi	st1
	jb	.nope
	jz	.zero
	jmp	.ok
.down:	fcomi	st1
	ja	.nope
	jz	.zero
.ok:	fstp	tword[rax+10]
	fstp	tword[rax]
	jmp	.nxt
.zero:	test	rcx,rcx
	jnz	.zero1
	bt	word[rax+8],15
	jnc	.ok
	fxch
	jmp	.nope
.zero1: bt	word[rax+8],15
	jc	.ok
	fxch
.nope:	fstp	st0
	fstp	st0
.nxt:	add	rax,10
	sub	rbx,1
	jnz	.inner
	mov	rbx,rdx
	sub	rdx,1
	jz	.done
	mov	rax,rsi
	jmp	.inner
.done:	pop	rsi
	pop	rdx
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;sort_flt(2)
;Sort array of singles
;-----------------------------
;RCX	: 0-ascending, 1-descending
;RBX	: Number of array elements
;RAX	: Address of array (DD)
;-----------------------------
;Ret	: Return the sorted array
;Note	: Elements are of type DD
;-----------------------------
align 8
sort_flt:
	push	rbp
	mov	rbp,rsp
	sub	rsp,512
	and	rsp,-16
	fxsave	[rsp]
	push	rax
	push	rbx
	push	rdx
	push	rsi
	mov	rsi,rax
	sub	rbx,1
	mov	rdx,rbx
	finit
.inner: fld	dword[rax+4]
	fld	dword[rax]
	test	rcx,rcx
	jnz	.down
	fcomi	st1
	jb	.nope
	jz	.zero
	jmp	.ok
.down:	fcomi	st1
	ja	.nope
	jz	.zero
.ok:	fstp	dword[rax+4]
	fstp	dword[rax]
	jmp	.nxt
.zero:	test	rcx,rcx
	jnz	.zero1
	bt	dword[rax],31
	jnc	.ok
	fxch
	jmp	.nope
.zero1: bt	dword[rax],31
	jc	.ok
	fxch
.nope:	fstp	st0
	fstp	st0
.nxt:	add	rax,4
	sub	rbx,1
	jnz	.inner
	mov	rbx,rdx
	sub	rdx,1
	jz	.done
	mov	rax,rsi
	jmp	.inner
.done:	pop	rsi
	pop	rdx
	pop	rbx
	pop	rax
	fxrstor [rsp]
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------------
;digitprob(2)/1
;Probe digit at location (signed)
;-----------------------------------
;RBX	: Digit position (1=MSdigit)
;RAX	: Value
;-----------------------------------
;Ret	: Digit. -1 if error
;Note	: -
;-----------------------------------
align 8
digitprob:
	cmp	rbx,0
	jg	.begin
	mov	rax,-1
	ret
.begin: push	rbx
	push	rcx
	push	rdx
	push	rdi
	mov	rcx,10
	xor	rdi,rdi
	test	rax,rax
	jns	.again
	neg	rax
.again: xor	rdx,rdx
	div	rcx
	push	rdx
	inc	rdi
	test	rax,rax
	jnz	.again
	mov	rcx,8
	cmp	rdi,rbx
	jae	.norm
	mov	rax,rdi
	mul	rcx
	add	rsp,rax
	mov	rax,-1
	jmp	.done
.norm:	mov	rax,rbx
	mul	rcx
	mov	rbx,[rsp+rax-8]
	mov	rax,rdi
	mul	rcx
	add	rsp,rax
	mov	rax,rbx
.done:	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;-----------------------------------
;digitprobu(2)/1
;Probe digit at position (unsigned)
;-----------------------------------
;RBX	: Digit position (1=MSdigit)
;RAX	: Value
;-----------------------------------
;Ret	: Digit. -1 if error
;Note	: -
;-----------------------------------
align 8
digitprobu:
	cmp	rbx,0
	jg	.begin
	mov	rax,-1
	ret
.begin: push	rbx
	push	rcx
	push	rdx
	push	rdi
	mov	rcx,10
	xor	rdi,rdi
.again: xor	rdx,rdx
	div	rcx
	push	rdx
	inc	rdi
	test	rax,rax
	jnz	.again
	mov	rcx,8
	cmp	rdi,rbx
	jae	.norm
	mov	rax,rdi
	mul	rcx
	add	rsp,rax
	mov	rax,-1
	jmp	.done
.norm:	mov	rax,rbx
	mul	rcx
	mov	rbx,[rsp+rax-8]
	mov	rax,rdi
	mul	rcx
	add	rsp,rax
	mov	rax,rbx
.done:	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	ret
;-----------------------------------
;digithprob(2)/1
;Probe a hex digit at a position (signed)
;-----------------------------------
;RBX	: Digit position
;RAX	: Hex value to look from
;-----------------------------------
;Ret	: Digit. -1 if error
;Note	: Posn #1 = Most signitificant
;-----------------------------------
align 8
digithprob:
	cmp	rbx,0
	jg	.begin
	cmp	rbx,16
	jbe	.begin
	mov	rax,-1
	ret
.begin: push	rbx
	push	rdi
	mov	rdi,rax
	test	rdi,rdi
	jns	.skipz
	neg	rdi
.skipz: xor	rax,rax
	shld	rax,rdi,4
	jnz	.more
	shl	rdi,4
	jmp	.skipz
.more:	sub	rbx,1
	jz	.done
	xor	rax,rax
	shl	rdi,4
	jz	.nxt
	shld	rax,rdi,4
	jmp	.more
.nxt:	mov	rax,-1
.done:	pop	rdi
	pop	rbx
	ret
;-----------------------------------
;digithprobu(2)/1
;Probe a hex digit at position (unsigned)
;-----------------------------------
;RBX	: Digit position
;RAX	: Hex value to look from
;-----------------------------------
;Ret	: Digit. -1 if error
;Note	: Posn #1 = Most signitificant
;-----------------------------------
align 8
digithprobu:
	cmp	rbx,0
	jg	.begin
	cmp	rbx,16
	jbe	.begin
	mov	rax,-1
	ret
.begin: push	rbx
	push	rdi
	mov	rdi,rax
.skipz: xor	rax,rax
	shld	rax,rdi,4
	jnz	.more
	shl	rdi,4
	jmp	.skipz
.more:	sub	rbx,1
	jz	.done
	xor	rax,rax
	shl	rdi,4
	jz	.nxt
	shld	rax,rdi,4
	jmp	.more
.nxt:	mov	rax,-1
.done:	pop	rdi
	pop	rbx
	ret
;-----------------------------------
;digitscan(2)/1
;Scan digit from a signed integer
;-----------------------------------
;RBX	: the digit (one digit only)
;RAX	: The source integer (signed)
;-----------------------------------
;Ret	: Digit position. #1 = MSD
;	: -1 = non-existent
;Note	: -
;-----------------------------------
align 8
digitscan:
	push	rbx
	push	rcx
	sub	rsp,64
	test	rax,rax
	jns	.ok
	neg	rax
.ok:	mov	rcx,rbx
	add	rcx,30h
	mov	rbx,rsp
	call	dec2str
	mov	al,cl
	mov	rbx,rsp
	call	chr_find
	test	rax,rax
	jnz	.done
	mov	rax,-1
.done:	add	rsp,64
	pop	rcx
	pop	rbx
	ret
;-----------------------------------
;digitscanu(2)/1
;Find digit from an unsigned integer
;-----------------------------------
;RBX	: the digit (one digit only)
;RAX	: The source integer (unsigned)
;-----------------------------------
;Ret	: Digit position. #1 = MSD
;	: -1 = non-existent
;Note	: -
;-----------------------------------
align 8
digitscanu:
	push	rbx
	push	rcx
	sub	rsp,64
.ok:	mov	rcx,rbx
	add	rcx,30h
	mov	rbx,rsp
	call	dec2stru
	mov	al,cl
	mov	rbx,rsp
	call	chr_find
	test	rax,rax
	jnz	.done
	mov	rax,-1
.done:	add	rsp,64
	pop	rcx
	pop	rbx
	ret
;-----------------------------------
;digithscan(2)/1
;Find digit from a signed hex
;-----------------------------------
;RBX	: Hex digit to find
;RAX	: The source hex (signed)
;-----------------------------------
;Ret	: Digit position. #1 = MSD
;	: -1 = non-existent
;Note	: -
;-----------------------------------
align 8
digithscan:
	push	rbx
	push	rcx
	sub	rsp,64
	test	rax,rax
	jns	.ok
	neg	rax
.ok:	mov	rcx,rbx
	add	rcx,30h
	cmp	rcx,'9'
	jbe	.nop
	add	rcx,7
.nop:	mov	rbx,rsp
	call	hex2str
	mov	al,cl
	mov	rbx,rsp
	call	chr_find
	test	rax,rax
	jnz	.done
	mov	rax,-1
.done:	add	rsp,64
	pop	rcx
	pop	rbx
	ret
;-----------------------------------
;digithscanu(2)/1
;Find digit from an unsigned hex
;-----------------------------------
;RBX	: Hex digit to find
;RAX	: The source hex (unsigned)
;-----------------------------------
;Ret	: Digit position. #1 = MSD
;	: -1 = non-existent
;Note	: -
;-----------------------------------
align 8
digithscanu:
	push	rbx
	push	rcx
	sub	rsp,64
.ok:	mov	rcx,rbx
	add	rcx,30h
	cmp	rcx,'9'
	jbe	.nop
	add	rcx,7
.nop:	mov	rbx,rsp
	call	hex2stru
	mov	al,cl
	mov	rbx,rsp
	call	chr_find
	test	rax,rax
	jnz	.done
	mov	rax,-1
.done:	add	rsp,64
	pop	rcx
	pop	rbx
	ret
;-------------------------------
;digitcount(1)/1
;Count digits of a signed decimal
;-------------------------------
;RAX	: Integer to count
;-------------------------------
;Ret	: Number of digits
;Note	: Signed
;-------------------------------
align 8
digitcount:
	push	rbx
	sub	rsp,32
	push	rax
	mov	rbx,32
	lea	rax,[rsp+8]
	call	mem_reset
	pop	rax
	mov	rbx,rsp
	test	rax,rax
	jns	.p
	neg	rax
	call	dec2str
	jmp	.ok
.p:	call	dec2stru
.ok:	mov	rax,rsp
	call	str_length
	add	rsp,32
	pop	rbx
	ret
;-------------------------------
;digitcountu(1)/1
;Count digits of an unsigned decimal
;-------------------------------
;RAX	: Integer to count
;-------------------------------
;Ret	: Number of digits
;Note	: Unsigned
;-------------------------------
align 8
digitcountu:
	push	rbx
	sub	rsp,32
	push	rax
	mov	rbx,32
	lea	rax,[rsp+8]
	call	mem_reset
	pop	rax
	mov	rbx,rsp
	call	dec2stru
	mov	rax,rsp
	call	str_length
	add	rsp,32
	pop	rbx
	ret
;-------------------------------
;digithcount(1)/1
;Count digits of a signed hex
;-------------------------------
;RAX	: Hex integer to count
;-------------------------------
;Ret	: Number of digits
;Note	: Signed
;-------------------------------
align 8
digithcount:
	push	rbx
	sub	rsp,32
	push	rax
	mov	rbx,32
	lea	rax,[rsp+8]
	call	mem_reset
	pop	rax
	mov	rbx,rsp
	test	rax,rax
	jns	.p
	neg	rax
	call	hex2str
	jmp	.ok
.p:	call	hex2stru
.ok:	mov	rax,rsp
	call	str_length
	add	rsp,32
	pop	rbx
	ret
;-------------------------------
;digithcountu(1)/1
;Count digits of an unsigned hex
;-------------------------------
;RAX	: Hex integer to count
;-------------------------------
;Ret	: Number of digits
;Note	: Unsigned
;-------------------------------
align 8
digithcountu:
	push	rbx
	sub	rsp,32
	push	rax
	mov	rbx,32
	lea	rax,[rsp+8]
	call	mem_reset
	pop	rax
	mov	rbx,rsp
	call	hex2stru
	mov	rax,rsp
	call	str_length
	add	rsp,32
	pop	rbx
	ret
;---------------------------
;aprnint(3)
;Display array of signed int
;---------------------------
;CL	: Separator byte
;RBX	: Number of elements
;RAX	: Address of array
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
aprnint:
	push	rax
	push	rsi
	push	rbx
	mov	rsi,rax
.again: mov	rax,[rsi]
	call	prnint
	mov	al,cl
	call	prnchr
	add	rsi,8
	sub	rbx,1
	jnz	.again
	pop	rbx
	pop	rsi
	pop	rax
	ret
;---------------------------
;aprnintu(3)
;Display array of unsigned int
;---------------------------
;CL	: Separator byte
;RBX	: Number of elements
;RAX	: Address of array
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
aprnintu:
	push	rax
	push	rsi
	push	rbx
	mov	rsi,rax
.again: mov	rax,[rsi]
	call	prnintu
	mov	al,cl
	call	prnchr
	add	rsi,8
	sub	rbx,1
	jnz	.again
	pop	rbx
	pop	rsi
	pop	rax
	ret
;---------------------------
;aprndbl(3)
;Display array of doubles
;---------------------------
;CL	: Separator byte
;RBX	: Number of elements
;RAX	: Address of array
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
aprndbl:
	push	rax
	push	rsi
	push	rbx
	mov	rsi,rax
.again: mov	rax,[rsi]
	call	prndblr
	mov	al,cl
	call	prnchr
	add	rsi,8
	sub	rbx,1
	jnz	.again
	pop	rbx
	pop	rsi
	pop	rax
	ret
;---------------------------
;aprnflt(3)
;Display array of floats
;---------------------------
;CL	: Separator byte
;RBX	: Number of elements
;RAX	: Address of array
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
aprnflt:
	push	rax
	push	rsi
	push	rbx
	mov	rsi,rax
.again: mov	eax,[rsi]
	call	prnfltr
	mov	al,cl
	call	prnchr
	add	rsi,4
	sub	rbx,1
	jnz	.again
	pop	rbx
	pop	rsi
	pop	rax
	ret
;---------------------------
;aprndblx(3)
;Display array of REAL10
;---------------------------
;CL	: Separator byte
;RBX	: Number of elements
;RAX	: Address of array
;---------------------------
;Ret	: -
;Note	: -
;---------------------------
align 8
aprndblx:
	push	rax
	push	rsi
	push	rbx
	mov	rsi,rax
.again: mov	rax,rsi
	call	prndblx
	mov	al,cl
	call	prnchr
	add	rsi,10
	sub	rbx,1
	jnz	.again
	pop	rbx
	pop	rsi
	pop	rax
	ret
;------------------------------
;halt
;Pause screen
;------------------------------
;Arg	: - 
;------------------------------
;Ret	:
;Note	: Hit Enter to continue
;------------------------------
align 8
halt:
	push	rax
	call	readch
	pop	rax
	ret
;-----------------------
;prnspace
;Print a space
;-----------------------
;Arg	: -
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
prnspace:
	push	0x20
	call	prnchrs
	ret
;-----------------------
;prnline
;Print a new line
;-----------------------
;Arg	: -
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
prnline:
	push	rax
	mov	al,0ah
	call	prnchr
	pop	rax
	ret
;-----------------------
;prnspaces(1)
;Print whitespaces
;-----------------------
;arg1	: push Number of spaces
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
prnspaces:
	push	rax
	push	rbx
	push	rcx
	mov	rbx,[rsp+8*4]
	cmp	rbx,0
	jle	.quit
	sub	rsp,rbx
	mov	rax,rsp
	mov	cl,0x20
	call	mem_set
	call	prnstr
	add	rsp,rbx 
.quit:	pop	rcx
	pop	rbx
	pop	rax
	ret	8
;-----------------------
;prnlines(1)
;Print new lines
;-----------------------
;arg1	: push Number of lines
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
prnlines:
	push	rax
	push	rbx
	push	rcx
	mov	rbx,[rsp+8*4]
	cmp	rbx,0
	jle	.quit
	sub	rsp,rbx
	mov	rax,rsp
	mov	cl,0x0A
	call	mem_set
	call	prnstr
	add	rsp,rbx 
.quit:	pop	rcx
	pop	rbx
	pop	rax
	ret	8
;-----------------------
;prnchrp(2)
;Print char pattern
;-----------------------
;arg2	: push Byte value to use
;arg1	: push Number of times
;-----------------------
;Ret	: -
;Note	: -
;-----------------------
align 8
prnchrp:
	push	rbp
	mov	rbp,rsp
	push	rax
	push	rbx
	push	rcx
	mov	rbx,[rbp+16]
	mov	rcx,[rbp+24]
	cmp	rbx,0
	jle	.quit
	sub	rsp,rbx
	mov	rax,rsp
	call	mem_set
	call	prnstr
	add	rsp,rbx
.quit:	pop	rcx
	pop	rbx
	pop	rax
	mov	rsp,rbp
	pop	rbp
	ret	16
;-------------------------------
;prnchrs(1)
;Display character from stack
;-------------------------------
;ARG	: Push the char or [db]
;-------------------------------
;Ret	: -
;Note	: Use QWORD for [db] var
;-------------------------------
align 8
prnchrs:
	push	rax
	mov	al,[rsp+16]
	call	prnchr
	pop	rax
	ret	8
;----------------------------
;prnchar(1)
;Display char variable
;----------------------------
;RAX	: The char's address
;----------------------------
;Ret	: -
;Note	: -
;----------------------------
align 8
prnchar:
	push	rax
	mov	al,[rax]
	call	prnchr
	pop	rax
	ret
;------------------------------
;prnstreg(1)
;Display short string off RAX
;------------------------------
;RAX	: The string
;------------------------------
;Ret	: -
;Note	: -
;------------------------------
align 8
prnstreg:
	push	0
	push	rax
	mov	rax,rsp
	call	prnstrz
	pop	rax
	add	rsp,8
	ret
;--------------------------------
;prnstrd(2)
;Display string with delimiter
;--------------------------------
;BL	: delimiter byte value
;RAX	: Address of the string
;--------------------------------
;Ret	: -
;Note	: -
;--------------------------------
align 8
prnstrd:
	push	rax
	push	rcx
	push	rdi
	push	rsi
	mov	rsi,rax
	mov	rdi,rax
	mov	al,bl
	mov	rcx,-1
	repne	scasb
	mov	rax,-2
	sub	rax,rcx
	mov	byte[rsi+rax],0
	mov	rax,rsi
	call	prnstrz
	pop	rsi
	pop	rdi
	pop	rcx
	pop	rax
	ret
;---------------------------------
;readchr(1)
;Get a char from mem/var
;---------------------------------
;RAX	: Address of the char
;---------------------------------
;Ret	: Char in the sent address
;Note	: Takes single char only
;	: Var is of type DB/RB
;---------------------------------
align 8
readchr:
	push	rax
	push	rcx
	mov	rcx,rax
	call	readch
	mov	[rcx],al
	call	readch
	pop	rcx
	pop	rax
	ret

;------------------------------
;
;	O.S. SPECIFICS
;
;------------------------------

;------------------------------
;prnchr(1)
;Display character in RAX/AL
;------------------------------
;AL	: The char to display
;------------------------------
;Ret	: -
;Note	: -
;------------------------------
align 8
prnchr:
	push	rcx
	push	r11
	push	rdi
	push	rsi
	push	rdx
	push	rax
	mov	edx,1	 ;size
	mov	rsi,rsp  ;address
	mov	edi,1	 ;std_out
	mov	eax,1	 ;write
	syscall
	pop	rax
	pop	rdx
	pop	rsi
	pop	rdi
	pop	r11
	pop	rcx
	ret
;--------------------------------
;prnstr(2)
;Display string with size
;--------------------------------
;RBX	: Size of string in bytes
;RAX	: Address of the string
;--------------------------------
;Ret	: -
;Note	: -
;--------------------------------
align 8
prnstr:
	cmp	rbx,0
	jg	.next
	ret
.next:	push	rdi
	push	rsi
	push	rdx
	push	rax
	push	rcx
	push	rbx
	push	r11
	mov	rdx,rbx ;size
	mov	rsi,rax ;address
	mov	edi,1	;stdout
	mov	eax,1	;write
	syscall
	pop	r11
	pop	rbx
	pop	rcx
	pop	rax
	pop	rdx
	pop	rsi
	pop	rdi
	ret
;------------------------------
;prnstrz(1)
;Display 0-ended string
;------------------------------
;RAX	: Address of the string
;------------------------------
;Ret	: -
;Note	: -
;------------------------------
align 8
prnstrz:
	push	rsi
	push	rdx
	push	rax
	push	rcx
	push	rdi
	push	r11
	mov	rsi,rax
	mov	rdi,rax
	xor	al,al
	mov	rcx,-1
	repne	scasb
	mov	rdx,-2
	sub	rdx,rcx
	cmp	rdx,0
	jle	.done
	mov	edi,1
	mov	eax,edi
	syscall
.done:	pop	r11
	pop	rdi
	pop	rcx
	pop	rax
	pop	rdx
	pop	rsi
	ret
;--------------------------------
;readch/1
;Get a character from keyboard
;--------------------------------
;Arg	: -
;--------------------------------
;Ret	: The key in AL
;Note	: Takes single char only
;	: Used internally
;	: Use halt if needed
;--------------------------------
align 8
readch:
	push	rdx
	push	rdi
	push	rsi
	push	rcx
	push	r11
	sub	rsp,8
	mov	rsi,rsp
	mov	edx,1
	xor	edi,edi
	xor	eax,eax
	syscall
	xor	eax,eax
	mov	al,[rsp]
	add	rsp,8
	pop	r11
	pop	rcx
	pop	rsi
	pop	rdi
	pop	rdx
	ret
;-------------------------------
;readstr(1)/1
;Get string from keyboard
;and 0-ended it
;-------------------------------
;RAX	: Address of the buffer
;-------------------------------
;Ret	: # of bytes entered in RAX
;	: String in buffer
;Note	: Buffer is of type DB/RB
;	: Buffer must be large enough
;	: Ret -1 signals error
;	: String will be 0-ended
;-------------------------------
align 8
readstr:
	push	rdi
	push	rsi
	push	rdx
	push	rbx
	push	rcx
	push	r11
	push	r12
	sub	rsp,8
	mov	rbx,rax
	mov	rsi,rsp
	xor	rdi,rdi
	mov	edx,1
	xor	rax,rax
	xor	r12,r12
.rep:	syscall
	mov	al,[rsp]
	cmp	al,0ah
	je	.done
	mov	[rbx],al
	inc	r12
	add	rbx,1
	xor	rax,rax
	jmp	.rep
.done:	mov	rax,r12
	cmp	rax,0
	ja	.quit
	mov	rax,-1
.quit:	add	rbx,1
	mov	byte[rbx],0
	add	rsp,8
	pop	r12
	pop	r11
	pop	rcx
	pop	rbx
	pop	rdx
	pop	rsi
	pop	rdi
	ret
;------------------------------
;mem_alloc(1)/1
;Request memory of n bytes
;------------------------------
;RAX	: Bytes requested
;------------------------------
;Ret	: Pointer of the mem block
;	  -1 = if none
;Note	: -
;------------------------------
align 8
mem_alloc:
	push	rbx
	push	rdi
	push	rcx
	push	r11
	mov	rbx,rax
	mov	rdi,0
	mov	rax,12	;query breaker
	syscall
	add	rax,rbx
	mov	rdi,rax
	mov	rax,12
	syscall 	;ask memory
	test	rax,rax
	jns	.pass
	mov	rax,-1
	jmp	.quit
.pass:	sub	rax,rbx ;granted. Block ptr
.quit:	pop	r11
	pop	rcx
	pop	rdi
	pop	rbx
	ret
;------------------------------
;mem_free(1)/1
;Free memory allocated by mem_alloc
;------------------------------
;RAX	: Pointer from mem_alloc
;------------------------------
;Ret	: 1 - success
;	 -1 - fail
;Note	: -
;------------------------------
align 8
mem_free:
	test	rax,rax
	jns	.exist
	mov	rax,-1
	ret
.exist: push	rbx
	push	rdi
	push	rcx
	push	r11
	mov	rbx,rax
	mov	rdi,0
	mov	rax,12
	syscall
	mov	rax,1
	pop	r11
	pop	rcx
	pop	rdi
	pop	rbx
	ret
;----------------------
;delay(1)
;Put execution at delay
;----------------------
;RAX	: Milliseconds
;----------------------
;Ret	: -
;Note	: 1000ms = 1s
;----------------------
align 8
delay:
	push	r11
	push	rdi
	push	rsi
	push	rax
	push	rcx
	push	rdx
	cmp	rax,1000
	jb	.nxt
	mov	rdi,1000
	xor	rdx,rdx
	div	rdi
	push	rdx
	push	rax
	jmp	.ok
.nxt:	mov	rdi,1000000
	mul	rdi
	push	rax
	push	0
.ok:	lea	rsi,[rsp+8]
	lea	rdi,[rsp]
	mov	rax,35
	syscall
	add	rsp,16
	pop	rdx
	pop	rcx
	pop	rax
	pop	rsi
	pop	rdi
	pop	r11
	ret
;-------------------------------------
;file_new(1)
;Create a new file
;-------------------------------------
;RAX	: File name path string
;-------------------------------------
;Ret	: -
;Note	: Filename string must be 0-ended
;	: Permission: User read and write
;	: Will not overwrite current file
;-------------------------------------
; S_IRUSR=0x100 ;Read user
; S_IWUSR=0x80	;Write user
; S_IXUSR=0x40	;Execute user
; S_IRGRP=0x20	;Read group
; S_IWGRP=0x10	;Write group
; S_IXGRP=0x8	;Execute group
; S_IROTH=0x4	;Read other
; S_IWOTH=0x2	;Write other
; S_IXOTH=0x1	;Execute other
;O_FLAG
;------------
; O_APPEND= 0x400
; O_TRUNC = 0x200
; O_EXCL  = 0x80
; O_CREAT = 0x40
; O_RDWR  = 0x2
; O_WRONLY= 0x1
; O_RDONLY= 0x0
;--------------
align 8
file_new:
	push	rax
	push	rdx
	push	rsi
	push	rdi
	push	rcx
	push	r11
	;user read and write
	mov	rdx,0x100 | 0x80
	mov	rsi,0x40
	mov	rdi,rax
	mov	rax,2
	syscall
	pop	r11
	pop	rcx
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rax
	ret
;-------------------------------------
;file_open(2)/1
;Open an existing file for reading/writing
;-------------------------------------
;RBX	: Operation;
;	  0-Read
;	  1-Write
;RAX	: File name path string
;-------------------------------------
;Ret	: File descriptor. -1 if error
;Note	: Filename string must be 0-ended
;-------------------------------------
align 8
file_open:
	push	rsi
	push	rbx
	push	rdi
	push	rcx
	push	r11
	mov	rsi,rbx
	mov	rdi,rax
	mov	rax,2
	syscall
	test	rax,rax
	jns	.ok
	mov	rax,'open#'
	push	rax
	mov	rax,rsp
	call	prnstrz
	add	rsp,8
	mov	rax,-1
.ok:	pop	r11
	pop	rcx
	pop	rdi
	pop	rbx
	pop	rsi
	ret
;-------------------------------------
;file_read(3)/1
;Read from an existing opened file
;-------------------------------------
;RCX	: Number of bytes to read
;RBX	: Input buffer
;RAX	: File handle from file_open
;-------------------------------------
;Ret	: Number of actual read
;Note	: Filename string must be 0-ended
;	: RBX must be >= RCX
;-------------------------------------
align 8
file_read:
	test	rax,rax
	jns	.exist
	mov	rax,'read#'
	push	rax
	mov	rax,rsp
	call	prnstrz
	add	rsp,8
	mov	rax,-1
	ret
.exist: push	r11
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rdx,rcx
	mov	rsi,rbx
	mov	rdi,rax
	mov	rax,0
	syscall
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	r11
	ret
;-------------------------------------
;file_write(3)/1
;Write to an existing opened file
;-------------------------------------
;RCX	: Number of bytes to write
;RBX	: Input buffer
;RAX	: File handle from file_open
;-------------------------------------
;Ret	: Number of actual read
;Note	: Filename string must be 0-ended
;	: Do not include 0 as end of string
;	:  of the source (Linux only)
;-------------------------------------
align 8
file_write:
	test	rax,rax
	jns	.exist
	mov	rax,'writ#'
	push	rax
	mov	rax,rsp
	call	prnstrz
	add	rsp,8
	mov	rax,-1
	ret
.exist: push	r11
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rdx,rcx
	mov	rsi,rbx
	mov	rdi,rax
	mov	rax,1
	syscall
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	r11
	ret
;----------------------------
;file_close(1)/1
;Close a file opened by file_open
;----------------------------
;RAX	: FD returned by file_open
;----------------------------
;Ret	: Status. -1 if error
;Note	: -
;----------------------------
align 8
file_close:
	push	rdi
	push	r11
	push	rcx
	mov	rdi,rax
	mov	rax,3
	syscall
	pop	rcx
	pop	r11
	pop	rdi
	ret
;-------------------------------
;file_size(1)/1
;Get filesize of an opened file
;-------------------------------
;RAX	: File handle from file_open
;-------------------------------
;Ret	: Size in bytes
;Note	: -1 says error
;	: May not correct on diff linux
;-------------------------------
align 8
file_size:
	test	rax,rax
	jns	.exist
	mov	rax,-1
	ret
.exist: push	rsi
	push	rdi
	push	rbx
	push	rcx
	push	r11
	sub	rsp,144
	mov	rsi,rsp
	mov	rdi,rax
	mov	rax,5
	syscall
	mov	rax,[rsp+48]
	add	rsp,144
	pop	r11
	pop	rcx
	pop	rbx
	pop	rdi
	pop	rsi
	ret
;------------------------------------
;file_copy(2)
;Copy a file to a new file
;------------------------------------
;RBX	: Address of newfile name
;RAX	: Address of source file name
;------------------------------------
;Ret	: -
;Note	: Both must be 0-ended string
;------------------------------------
align 8
file_copy:
	push	rbp
	mov	rbp,rsp
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	mov	rdi,rax
	mov	rax,rbx
	call	file_new
	mov	rax,rdi
	mov	rdi,rbx
	mov	rbx,0
	call	file_open
	mov	rsi,rax
	call	file_size
	mov	rcx,rax
	call	mem_alloc
	mov	rbx,rax
	mov	rdx,rax
	mov	rax,rsi
	call	file_read
	mov	rax,rsi
	call	file_close
	mov	rbx,1
	mov	rax,rdi
	call	file_open
	mov	rsi,rax
	mov	rbx,rdx
	call	file_write
	mov	rax,rdx
	call	mem_free
	mov	rax,rsi
	call	file_close
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	mov	rsp,rbp
	pop	rbp
	ret
;-----------------------------
;exitp
;Pause screen & exit to system
;-----------------------------
;Arg	: -
;-----------------------------
;Ret	:
;Note	: Put at the end of code
;-----------------------------
align 8
exitp:
	mov	al,0ah
	call	prnchr
	call	readch
	xor	edi,edi
	mov	eax,60
	syscall
	ret
;-------------------------------
;exitx
;Exit to system
;-------------------------------
;Arg	: -
;-------------------------------
;Ret	:
;Note	: Put at the end of code
;-------------------------------
align 8
exitx:
	mov	al,0ah
	call	prnchr
	xor	edi,edi
	mov	eax,60
	syscall
	ret

;******** END OF ROUTINES ********
;report bugs/suggestions to:
;soffianabdulrasad @ gmail . com
