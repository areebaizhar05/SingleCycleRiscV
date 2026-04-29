# taskc.s
# Summation of arithmetic sequence from switch input N
# Sum = N + (N-1) + ... + 1
# Lower 16 bits -> LEDs
# Upper 16 bits -> 7-Segment Display
# Required instructions: LUI, JAL, BNE

main:
    addi x30, x0, 768          # Switch address (0x300)
    addi x31, x0, 512          # Output address (0x200)

read_input:
    lw x5, 0(x30)              # Read N from switches
    beq x5, x0, read_input     # Wait if N = 0
    add x6, x0, x0             # SUM = 0
    add x7, x0, x5             # COUNTER = N

sum_loop:
    jal ra, add_subroutine     # [JAL] Call subroutine, SUM += COUNTER
    addi x7, x7, -1            # COUNTER--
    bne x7, x0, sum_loop       # [BNE] Loop if COUNTER != 0

display:
    lui x8, 0x00001            # [LUI] x8 = 0x00001000, upper 16 = 0x0000
    add x6, x6, x8             # Merge LUI value with SUM
    sw x6, 0(x31)              # Write to output, lower 16 -> LEDs, upper 16 -> 7-seg
    beq x0, x0, read_input     # Go back, read next input

add_subroutine:
    add x6, x6, x7             # SUM = SUM + COUNTER
    jalr x0, ra, 0             # Return