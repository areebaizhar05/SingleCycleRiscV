# taskb.s - Task B: Instruction Extension Verification
# Three new instruction types demonstrated via switch input on hardware.
#
# Switch input (read from address 768 = 0x300):
#
#   sw[15] = 1  ->  LUI test
#                   lui x5, 0x12345  ->  x5 = 0x12345000
#                   7-segment shows: 1234
#                   LEDs show:       5000 (hex) = lower 16 bits of x5
# MMIO:
#   Address 512 (0x200): write -> writeData[15:0] = LEDs, writeData[31:16] = 7-seg
#   Address 768 (0x300): read  -> switch values in bits [15:0]

_start:
    addi x30, x0, 512          # x30 = LED/7-seg MMIO address (0x200)
    addi x29, x0, 768          # x29 = Switch MMIO address (0x300)
    sw   x0,  0(x30)           # clear display on startup

poll:
    lw   x28, 0(x29)           # x28 = switch state

    srli x27, x28, 15
    andi x27, x27, 1
    bne  x27, x0, do_lui       # sw[15]=1 -> LUI test

    beq  x0, x0, poll

do_lui:
    lui  x5, 0x12345            # x5 = 0x12345000
    sw   x5, 0(x30)
    beq  x0, x0, poll

