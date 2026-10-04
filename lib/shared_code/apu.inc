;
; first_nes
; lib/shared_code/apu.inc
;
; Author: Greg M. Krsak <greg.krsak@gmail.com>
; Purpose: Define the NES Audio Processing Unit (APU) memory-mapped register addresses used by
;          first_nes and provide a compact beginner reference for the sound hardware.
;


; The APU is the NES sound hardware built into the Ricoh CPU/APU package. Its channel registers live
; primarily at $4000-$4013, with status/control at $4015 and frame-counter/controller-2 sharing $4017.


; ------+-----+---------------------------------------------------------------
; $4015 | W   | Sound Channel Switch
;       |   0 | Pulse channel 1: 1 = enable
;       |   1 | Pulse channel 2: 1 = enable
;       |   2 | Triangle channel: 1 = enable
;       |   3 | Noise channel: 1 = enable
;       |   4 | DMC channel: 1 = enable
;       | 5-7 | Not channel-enable bits
; ------+-----+---------------------------------------------------------------
_SND_CHN    = $4015


; Pulse-wave channels 1 and 2.
_SQ1_VOL    = $4000                  ; Pulse 1 duty/envelope/volume
_SQ1_SWEEP  = $4001                  ; Pulse 1 sweep unit
_SQ1_LO     = $4002                  ; Pulse 1 timer low byte
_SQ1_HI     = $4003                  ; Pulse 1 timer high / length load
_SQ2_VOL    = $4004                  ; Pulse 2 duty/envelope/volume
_SQ2_SWEEP  = $4005                  ; Pulse 2 sweep unit
_SQ2_LO     = $4006                  ; Pulse 2 timer low byte
_SQ2_HI     = $4007                  ; Pulse 2 timer high / length load


; Triangle-wave channel.
_TRI_LINEAR = $4008                  ; Triangle linear counter
_TRI_LO     = $400a                  ; Triangle timer low byte
_TRI_HI     = $400b                  ; Triangle timer high / length load


; Noise channel.
_NOISE_VOL  = $400c                  ; Noise envelope/volume
_NOISE_LO   = $400e                  ; Noise period/mode
_NOISE_HI   = $400f                  ; Noise length-counter load


; Delta Modulation Channel (DMC).
_DMC_FREQ   = $4010                  ; DMC IRQ/loop/rate control
_DMC_RAW    = $4011                  ; DMC direct output level
_DMC_START  = $4012                  ; DMC sample start address
_DMC_LEN    = $4013                  ; DMC sample length


; APU frame counter. Writes also share this CPU address with controller-2 reads.
_FR_COUNTER = $4017

; End of lib/shared_code/apu.inc
