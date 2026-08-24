#mouse coords
mx: emb i16t 0
my: emb i16t 0

draw: emb u8t 0
eras: emb u8t 0
thick: emb u8t 0

intro: emb string "Use your mouse to draw pixels. LEFT-CLICK: Draw; RIGHT-CLICK: Erase, MouseWheel: thickness. Have fun"
feedback: emb string "thickness: "


_start: # Runs once when the VM starts.
    mov a0, intro
    syscall SYS_PRINT_STRING
    exit


_update: # Runs at 60 Hz.
    syscall SYS_GET_MOUSE_POSITION
    str i16t, mx, a0
    str i16t, my, a1

    syscall SYS_GET_MOUSE_BUTTON_INPUT
    and t0, a0, MOUSE_BTN_LEFT
    cmp eq, t0, 1
    str u8t, draw, t0

    and t4, a0, MOUSE_BTN_RIGHT
    cmp eq, t4, 2
    str u8t, eras, t4

    lod u8t, t5, thick
    and t6, a0, MOUSE_BTN_WHEEL_UP
    cmp neq, t6, 0
    jfs .noup
    inc t5

    jmp .thickchanged

.noup:
    and t6, a0, MOUSE_BTN_WHEEL_DOWN
    cmp neq, t6, 0
    jfs .nodown
    dec t5
    jmp .thickchanged

.nodown:
    exit



.thickchanged:
    #clamp
    clp t5, t5, 0, 10
    str u8t, thick, t5

    #print output
    mov a0, feedback
    syscall SYS_PRINT_STRING
    mov a0, t5
    syscall SYS_PRINT_LINE_INT
    exit

_draw:
    lod u8t, t0, draw
    lod u8t, t4, eras
    lod u8t, t5, thick

    syscall SYS_PRESERVE_BACK_BUFFER

    lod i16t, t1, mx
    clp t1, t1, 0, (SCREEN_WIDTH-1)
    lod i16t, t2, my
    clp t2, t2, 0, (SCREEN_HEIGHT-1)

    cmp eq, t0, 1
    jtr .paint
    cmp eq, t4, 2
    jtr .erase
    exit

.paint:
    mov t3, 255
    jmp .thicken
    exit

.erase:
    mov t3, 1
    jmp .thicken
    exit


.thicken:
    neg t6, t5
.yloop:
    neg t7, t5
.xloop:
    add t8, t1, t7
    add t9, t2, t6
    clp t8, t8, 0, (SCREEN_WIDTH-1)
    clp t9, t9, 0, (SCREEN_HEIGHT-1)
    sbpx t8, t9, t3

    inc t7
    cmp gt, t7, t5
    jfs .xloop
    inc t6
    cmp gt, t6, t5
    jfs .yloop
    exit


_input:
    exit

_exitstate:
    exit
