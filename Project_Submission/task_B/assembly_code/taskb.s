# taskb.s - Task B: Instruction Extension Verification
# Three new instruction types demonstrated via switch input on hardware.
#
# Switch input (read from address 768 = 0x300):
#
#   sw[15] = 1  ->  LUI test
#                   lui x5, 0x12345  ->  x5 = 0x12345000
#                   7-segment shows: 1234
#                   LEDs show:       5000 (hex) = lower 16 bits of x5
#
#   sw[14] = 1  ->  JAL test
#                   jal to subroutine that builds 9625 (student ID) in x10
#                   7-segment shows: 0000
#                   LEDs show:       2599 (hex) = 9625 decimal
#
#   sw[13] = 1  ->  BNE FAIL case
#                   x5 = 4, x6 = 5 (not equal) -> bne TAKEN -> output 0x00000000
#                   7-segment shows: 0000   LEDs show: 0000
#
#   sw[12] = 1  ->  BNE PASS case
#                   x5 = 6, x6 = 6 (equal) -> bne NOT TAKEN -> fall through
#                   7-segment shows: 1111   LEDs show: 1111 (hex)
#
# MMIO:
#   Address 512 (0x200): write -> writeData[15:0] = LEDs, writeData[31:16] = 7-seg
#   Address 768 (0x300): read  -> switch values in bits [15:0]

_start:
    addi x30, x0, 512          # x30 = LED/7-seg MMIO address
    addi x29, x0, 768          # x29 = Switch MMIO address
    sw   x0,  0(x30)           # clear display on startup

poll:
    lw   x28, 0(x29)           # x28 = switch state

    srli x27, x28, 15
    andi x27, x27, 1
    bne  x27, x0, do_lui       # sw[15]=1 -> LUI test

    srli x27, x28, 14
    andi x27, x27, 1
    bne  x27, x0, do_jal       # sw[14]=1 -> JAL test

    srli x27, x28, 13
    andi x27, x27, 1
    bne  x27, x0, do_bne_fail  # sw[13]=1 -> BNE fail case

    srli x27, x28, 12
    andi x27, x27, 1
    bne  x27, x0, do_bne_pass  # sw[12]=1 -> BNE pass case

    beq  x0, x0, poll

do_lui:
    lui  x5, 0x12345            # x5 = 0x12345000
    sw   x5, 0(x30)
    beq  x0, x0, poll

do_jal:
    sw   x0,  0(x30)
    jal  x1,  sub_jal           # JUMP to subroutine
    sw   x10, 0(x30)            # write 9625 after return
    beq  x0,  x0, poll

do_bne_fail:
    addi x5, x0, 4
    addi x6, x0, 5
    bne  x5, x6, bne_false      # not equal -> branch TAKEN
    beq  x0, x0, bne_true

do_bne_pass:
    addi x5, x0, 6
    addi x6, x0, 6
    bne  x5, x6, bne_false      # equal -> branch NOT TAKEN -> fall through
    beq  x0, x0, bne_true

bne_false:
    sw   x0,  0(x30)
    beq  x0, x0, poll

bne_true:
    lui  x9,  0x11111
    ori  x9,  x9, 0x111         # x9 = 0x11111111
    sw   x9,  0(x30)
    beq  x0, x0, poll

sub_jal:
    lui  x10, 0x2               # x10 = 0x00002000
    addi x10, x10, 0x599        # x10 = 0x00002599 = 9625
    jalr x0,  0(x1)             # return