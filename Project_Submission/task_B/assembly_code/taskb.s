# taskb.s
# Final Test Program for Viva (Software Level)

main:
    addi x30, x0, 768    # 0x00: x30 = Switch address
    addi x31, x0, 512    # 0x04: x31 = MMIO address

loop:
    lw x10, 0(x30)       # 0x08: read switches

    # check sw[15] (0x8000)
    lui x11, 8           # 0x0C
    and x12, x10, x11    # 0x10
    bne x12, x0, test_lui # 0x14

    # check sw[14] (0x4000)
    lui x11, 4           # 0x18
    and x12, x10, x11    # 0x1C
    bne x12, x0, test_jal # 0x20

    # check sw[13] (0x2000)
    lui x11, 2           # 0x24
    and x12, x10, x11    # 0x28
    bne x12, x0, t_bne_eq # 0x2C

    # check sw[12] (0x1000)
    lui x11, 1           # 0x30
    and x12, x10, x11    # 0x34
    bne x12, x0, t_bne_neq # 0x38

    # Default: Output 0
    sw x0, 0(x31)        # 0x3C
    jal x0, loop         # 0x40

test_lui:
    # Output 0x12345000 (7-seg=1234, LEDs=5000)
    lui x13, 0x12345     # 0x44
    sw x13, 0(x31)       # 0x48
    jal x0, loop         # 0x4C

test_jal:
    jal ra, jal_targ     # 0x50: jump to jal_targ
    jal x0, loop         # 0x54

t_bne_eq:
    # Test BNE with Equal values (Failure expected)
    addi x14, x0, 4      # 0x58
    addi x15, x0, 4      # 0x5C
    bne x14, x15, bne_f  # 0x60: (should NOT branch)
    # fallthrough (success for EQUAL case)
    sw x0, 0(x31)        # 0x64: output 0000 (False)
    jal x0, loop         # 0x68

t_bne_neq:
    # Test BNE with NOT Equal values (Success expected)
    addi x14, x0, 4      # 0x6C
    addi x15, x0, 5      # 0x70
    bne x14, x15, bne_s  # 0x74: (SHOULD branch)
bne_f:
    sw x0, 0(x31)        # 0x78: branch failed or didn't take branch when it should
    jal x0, loop         # 0x7C

bne_s:
    lui x13, 0x11111     # 0x80: 7-seg = 1111 (True), LED = 1000
    sw x13, 0(x31)       # 0x84
    jal x0, loop         # 0x88

jal_targ:
    lui x13, 0x96250     # 0x8C: 0x96250000. 7-seg=9625, LEDs=0000
    sw x13, 0(x31)       # 0x90
    jalr x0, 0(ra)       # 0x94: return to 0x54
