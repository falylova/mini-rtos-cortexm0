; =============================================================
; context_switch.s   Mini-RTOS Cortex-M0 / Keil MDK ARMCC V5
;
; Pile d'une tache (adresses croissantes) :
;   [sp+ 0] R4  [sp+ 4] R5  [sp+ 8] R6  [sp+12] R7   <- frame SW
;   [sp+16] R8  [sp+20] R9  [sp+24] R10 [sp+28] R11
;   [sp+32] R0  [sp+36] R1  [sp+40] R2  [sp+44] R3   <- frame HW
;   [sp+48] R12 [sp+52] LR  [sp+56] PC  [sp+60] xPSR
;
; sizeof(TCB) = 516 = 4 * 129
; =============================================================

    PRESERVE8
    AREA |.text|, CODE, READONLY
    THUMB

    IMPORT currentTask
    IMPORT nextTask
    IMPORT tcb

    EXPORT PendSV_Handler
    EXPORT Start_First_Task

; -------------------------------------------------------------
; Start_First_Task : demarre tcb[0] (Task 1) sans jamais revenir
; -------------------------------------------------------------
Start_First_Task

    LDR  R0, =tcb
    LDR  R0, [R0, #0]          ; R0 = tcb[0].sp -> R4 du frame SW

    MOVS R1, #2
    MSR  CONTROL, R1            ; mode Thread utilise PSP
    ISB

    LDMIA R0!, {R4-R7}          ; restaure R4-R7,  R0 += 16

    LDR  R1, [R0, #0]
    LDR  R2, [R0, #4]
    LDR  R3, [R0, #8]
    MOV  R8,  R1
    MOV  R9,  R2
    MOV  R10, R3
    LDR  R1,  [R0, #12]
    MOV  R11, R1
    ADDS R0,  R0, #16           ; R0 pointe sur le frame HW

    MSR  PSP, R0
    LDR  R0, =0xFFFFFFFD
    BX   R0                     ; CPU depile frame HW -> saute dans Task1

; -------------------------------------------------------------
; PendSV_Handler : sauve le contexte courant, charge le suivant
; -------------------------------------------------------------
PendSV_Handler

    CPSID I                     ; IRQ off

    ; -- Sauvegarde frame SW de la tache courante --
    MRS   R0, PSP
    SUBS  R0, R0, #32

    STR   R4,  [R0, #0]
    STR   R5,  [R0, #4]
    STR   R6,  [R0, #8]
    STR   R7,  [R0, #12]

    MOV   R1, R8
    MOV   R2, R9
    MOV   R3, R10
    STR   R1, [R0, #16]
    STR   R2, [R0, #20]
    STR   R3, [R0, #24]
    MOV   R1, R11
    STR   R1, [R0, #28]

    ; -- tcb[currentTask].sp = R0 --
    LDR   R1, =tcb
    LDR   R2, =currentTask
    LDRB  R2, [R2]
    MOVS  R3, #129
    MULS  R3, R2, R3
    LSLS  R3, R3, #2            ; R3 = currentTask * 516
    ADDS  R3, R1, R3
    STR   R0, [R3, #0]

    ; -- currentTask = nextTask --
    LDR   R2, =nextTask
    LDRB  R2, [R2]
    LDR   R3, =currentTask
    STRB  R2, [R3]

    ; -- Charge tcb[nextTask].sp --
    LDR   R1, =tcb
    MOVS  R3, #129
    MULS  R3, R2, R3
    LSLS  R3, R3, #2            ; R3 = nextTask * 516
    ADDS  R3, R1, R3
    LDR   R0, [R3, #0]          ; R0 = tcb[nextTask].sp

    ; -- Restaure frame SW de la nouvelle tache --
    LDR   R4, [R0, #0]
    LDR   R5, [R0, #4]
    LDR   R6, [R0, #8]
    LDR   R7, [R0, #12]

    LDR   R1, [R0, #16]
    LDR   R2, [R0, #20]
    LDR   R3, [R0, #24]
    MOV   R8,  R1
    MOV   R9,  R2
    MOV   R10, R3
    LDR   R1,  [R0, #28]
    MOV   R11, R1

    ADDS  R0, R0, #32           ; R0 pointe sur le frame HW

    MSR   PSP, R0
    CPSIE I                     ; IRQ on

    BX    LR                    ; CPU depile frame HW -> reprend nouvelle tache

    END
	