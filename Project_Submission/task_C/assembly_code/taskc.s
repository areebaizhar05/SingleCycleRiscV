# ==========================================
# PART C: VISUAL ACCUMULATOR
# Features: bne, jal, lui, jalr
# ==========================================

main:
    addi x30, x0, 768       # x30 = Switch Address (0x300)
    addi x31, x0, 512       # x31 = LED/7-Seg Address (0x200)

# 1. POLL SWITCHES UNTIL INPUT != 0
poll:
    lw x10, 0(x30)          # x10 = Read switches (this is our 'N')
    addi x11, x0, 0         # x11 = 0
    bne x10, x11, init      # If input != 0, break out of poll loop
    jal x0, poll            # Else, jump back and keep polling

# 2. INITIALIZE ACCUMULATOR
init:
    addi x12, x0, 0         # x12 = Sum Accumulator = 0

# 3. ACCUMULATOR LOOP
calc_loop:
    bne x10, x0, do_add     # If N != 0, continue adding
    jal x0, halt            # If N == 0, we are done! Jump to halt

do_add:
    add x12, x12, x10       # sum = sum + N
    addi x10, x10, -1       # N = N - 1
    
    # Show current running sum on LEDs
    sw x12, 0(x31)
    
    # Call delay subroutine so we can see the addition happening visually!
    jal ra, delay
    
    # Loop back for the next number
    jal x0, calc_loop

# 4. HALT AND FREEZE FINAL ANSWER
halt:
    jal x0, halt            # Infinite loop to freeze the final result on LEDs

# 5. DELAY SUBROUTINE (Uses LUI and BNE)
delay:
    # Use LUI to load a large delay value for a visible pause (~0.5 seconds at 25MHz)
    lui x13, 0x01000        
delay_loop:
    addi x13, x13, -1
    bne x13, x0, delay_loop # Keep decrementing until 0
    
    # Return to caller
    jalr x0, 0(ra)