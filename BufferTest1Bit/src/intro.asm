include "defines.asm"
SECTION "Intro", ROMX

Intro::
	;Wait, to allow BIOS to fully initialize
	call SGBDelay

	; Little Sound to indicate SGB Support is working
	ld hl, NintendoSoundPacket
	call SendPackets

	call SGBDelay

	;Turn off LCD
	ld A, $00
	ldh [$40], A
	
	; Manually copy SNES code to GB-VRAM
	ld hl, SNESCode
	ldi A, [hl]
	ld [$8000], A
	ldi A, [hl]
	ld [$8001], A
	ldi A, [hl]
	ld [$8002], A
	ldi A, [hl]
	ld [$8003], A
	ldi A, [hl]
	ld [$8004], A
	ldi A, [hl]
	ld [$8005], A
	ldi A, [hl]
	ld [$8006], A
	ldi A, [hl]
	ld [$8007], A
	ldi A, [hl]
	ld [$8008], A
	ldi A, [hl]
	ld [$8009], A
	ldi A, [hl]
	ld [$800A], A
	ldi A, [hl]
	ld [$800B], A
	ldi A, [hl]
	ld [$800C], A
	ldi A, [hl]
	ld [$800D], A
	
	; Send SNES code to $7F0000 in SNES-WRAM
	call FillScreenWithSGBMap
	ld hl, TransferDataPacket
	call SendPackets
	call SGBDelay

	; Jump SNES PC to $7F0000 to execute code in WRAM
	ld hl, JumpPacket
	call SendPackets
	
; Delay for a bit to allow stuff to settle
call SGBDelay


; Clear out anything that might still be in the packet buffer
ld HL, $FF00 
ld [HL], $00  ; Reset
ld [HL], $30  
ld a, 129
clearLoop:
ld [HL], $20 ;3 0
ld [HL], $30 ;3
dec a
jr z, clearLoop


; Wait some more, just for good measure
call SGBDelay


tickLoop:
ldh a, [tickCounter]
inc a 
ldh [tickCounter], a
and a, $01
jr z, Tick0
jr Tick1

TickEndTransfer:
    ld de, 300 ; Waits like 20 or so scan lines
.waitLoop
    nop
    nop
    nop
    dec de
    ld a, d
    or e
    jr nz, .waitLoop

	jr tickLoop


Tick0:
	ld HL, $FF00 
	ld [HL], $00 ;Reset
	ld [HL], $30 
	ld [HL], $20 ;0
	ld [HL], $30 

	jp TickEndTransfer

Tick1:
	ld HL, $FF00 
	ld [HL], $00 ;Reset
	ld [HL], $30 
	ld [HL], $10 ;1
	ld [HL], $30 
	jr TickEndTransfer

		
NintendoSoundPacket:
    sgb_packet SOUND, 1, $1, $80, $87 ,0,0,0,0,0,0,0,0,0,0,0,0,0

TransferDataPacket:
    sgb_packet DATA_TRN, 1, $00, $00, $7F ,0,0,0,0,0,0,0,0,0,0,0,0,0

JumpPacket:
    sgb_packet JUMP, 1, $00, $00, $7F ,0,0,0,0,0,0,0,0,0,0,0,0,0


SNESCode:
;This will continously read the first bit of $7000, shift it left twice and write it to the screen brightness.

; loop: lda $007000
; and #$01
; asl
; asl
; sta INIDISP
; bra loop
db $AF, $00, $70, $00 ,$29 ,$01 ,$0A, $0A ,$8D ,$00 ,$21 ,$80 ,$F3 


SECTION "HRAM", HRAM


tickCounter:: db