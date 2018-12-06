;
; first_nes
; lib/sprite/basic_movement.s
;
; Veryt simple sprite movement routines, for demonstration purposes only.
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by Jeremy Chadwick:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;
; Tested with:
;  make
;  nestopia first_nes.nes
;
; Tested on:
;  - Linux with Nestopia UE 1.47
;  - Windows with Nestopia UE 1.48
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


; ==========================================
; Subroutine to move the Luigi sprites right
; ==========================================

.PROC     MoveLuigiRight

    lda     $0203                   ; 
    clc                             ;
    adc     #$01                    ; 
    sta     $0203                   ; Increment the Sprite0 X position

    lda     $0207                   ; 
    clc                             ;
    adc     #$01                    ; 
    sta     $0207                   ; Increment the Sprite1 X position

    lda     $020b                   ; 
    clc                             ;
    adc     #$01                    ; 
    sta     $020b                   ; Increment the Sprite2 X position
    
    lda     $020f                   ; 
    clc                             ;
    adc     #$01                    ; 
    sta     $020f                   ; Increment the Sprite3 X position

    rts

.ENDPROC


; =========================================
; Subroutine to move the Luigi sprites left
; =========================================

.PROC     MoveLuigiLeft

    lda     $0203                   ; 
    sec                             ; 
    sbc     #$01                    ; 
    sta     $0203                   ; Decrement Sprite0 X position

    lda     $0207                   ; 
    sec                             ; 
    sbc     #$01                    ; 
    sta     $0207                   ; Decrement Sprite1 X position

    lda     $020b                   ; 
    sec                             ; 
    sbc     #$01                    ; 
    sta     $020b                   ; Decrement Sprite2 X position

    lda     $020f                   ; 
    sec                             ; 
    sbc     #$01                    ; 
    sta     $020f                   ; Decrement Sprite3 X position

    rts
    
.ENDPROC


; End of lib/sprite/basic_movement.s
