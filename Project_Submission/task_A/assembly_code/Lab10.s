.text
.globl _start

_start:

    # stack ptr
    addi x2,  x0, 511      # SP = 511 (top of stack area)

    #base addresses
    addi x5,  x0, 768      # x5 = SWITCH_ADD 0x300
    addi x6,  x0, 512      # x6 = LED_ADDR 0x200
    addi x7,  x0, 1024     # x7 = RESET_ADDR 0x400

    #test value
    addi x22, x0, 3        # x22 = test value 3

    #led off
    sw   x0, 0(x6)         # all LEDs off

# ============================================================
# IDLE STATE
# Purpose: Wait for switch input while checking reset button
# Loop continuously until non-zero switch value is detected
# ============================================================

IDLE_STATE:
    # Keep LEDs off while waiting for user input
    sw   x0, 0(x6)         # Write 0x00 to LED address (no LEDs on)

SWITCH_INP:
    # ========== CHECK RESET BUTTON ==========
    # Before reading switches, check if reset button was pressed
    # This allows reset from idle state
    lw   x10, 0(x7)        # Load RESET_ADDR value into x10 (read reset button)
    bne  x10, x0, IDLE_STATE   # If reset != 0, reset was pressed → stay in IDLE

    # ========== READ SWITCH INPUT ==========
    # Reset not pressed, so read the switch peripheral
    # Switches provide the count value for countdown
    lw   x10, 0(x5)        # Load SWITCH_ADDR value into x10 (read switch input)

    # ========== VALIDATE SWITCH INPUT ==========
    # Don't proceed to countdown unless user set a non-zero value
    # If input is 0, loop back and wait for valid input
    beq  x10, x0, SWITCH_INP  # If input == 0, jump back to read switches again

    # ========== PREPARE TO CALL COUNTDOWN ==========
    # At this point: x10 contains the countdown start value (non-zero)
    # Now call the COUNTDOWN subroutine with x10 as the argument

    # Save Return Address on Stack
    # Decrement stack pointer by 4 bytes (1 word) to make room
    addi x2, x2, -4        # Allocate 4 bytes on stack (move SP down)
    sw   x1, 0(x2)         # Push return address (x1) onto stack at [SP]

    # Call Countdown Subroutine
    # JAL: Jump And Link - saves PC+4 to x1, jumps to COUNTDOWN
    # x1 will hold return address after this instruction
    jal  x1, COUNTDOWN     # Call COUNTDOWN subroutine; x1 = PC+4 (return address)

    # ========== RESTORE RETURN ADDRESS ==========
    # Countdown finished (either naturally or via reset)
    # Restore return address from stack
    lw   x1, 0(x2)         # Pop return address from stack into x1
    addi x2, x2, 4         # Deallocate 4 bytes (move SP up)

    # ========== RETURN TO IDLE ==========
    # Countdown complete: go back to IDLE to wait for next input
    beq  x0, x0, IDLE_STATE    # Unconditional jump (always branch) back to IDLE


# ============================================================
# COUNTDOWN SUBROUTINE
# Purpose: Decrement counter from starting value to zero
#          Display counter value on LEDs at each step
#          Implement ~1 second delay between each decrement
#          Check for reset button at every iteration
# 
# Inputs:   x10 = initial count value (from switch input)
# Outputs:  None (modifies LEDs, modifies SP)
# Registers Used: x11 (counter), x12 (delay counter)
#                 x1 (return address), x2 (stack pointer)
# ============================================================

COUNTDOWN:
    # ========== SAVE CALLEE-SAVED REGISTERS ==========
    # RISC-V convention: subroutines must save/restore registers
    # we will use x11 and x12, so we must save them on entry
    
    # Allocate 8 bytes on stack for 2 registers (x11, x12)
    # Each register is 4 bytes wide
    addi x2,  x2,  -8      # Move SP down 8 bytes to make room [SP-8 to SP-4]

    # Save x11 and x12 to stack for restoration on exit
    sw   x11, 4(x2)        # Store x11 at [SP+4] (upper word of allocated space)
    sw   x12, 0(x2)        # Store x12 at [SP]   (lower word of allocated space)

    # ========== INITIALIZE COUNTER REGISTER ==========
    # Copy the input argument (x10) into counter register (x11)
    # x11 will be decremented each loop iteration
    add  x11, x10, x0      # x11 = x10 (copy initial count to x11)

DECREMENT_LOOP:
    # ========== DISPLAY COUNTER ON LEDS ==========
    # Show current counter value using 8 LED bits
    sw   x11, 0(x6)        # Write x11 value to LED address (display counter)

    # ========== CHECK IF COUNTER REACHED ZERO ==========
    # Exit the countdown loop when counter = 0
    beq  x11, x0, EXIT_COUNTER    # If x11 == 0, jump to EXIT_COUNTER

    # ========== TEST VALUE CHECK (OPTIONAL) ==========
    # Special behavior: when counter == 3, turn on extra LEDs
    # Compare counter (x11) with test value (x22 = 3)
    bne  x11, x22, SKIP_TEST      # If x11 != x22, skip special LED behavior
    # If we get here: counter == test value, so light up extra pattern
    sw   x22, 0(x6)               # Write x22 pattern to LEDs (TEST MATCH display)

SKIP_TEST:
    # ========== CHECK FOR RESET BUTTON (CHECK 1) ==========
    # Reset check BEFORE decrementing - catch reset immediately
    lw   x10, 0(x7)        # Load RESET_ADDR value into x10
    bne  x10, x0, RESET_NOW     # If reset != 0, jump to RESET_NOW

    # ========== DECREMENT COUNTER BY 1 ==========
    # Subtract 1 from counter for next iteration
    addi x11, x11, -1      # x11 = x11 - 1 (decrement counter)

    # ========== DELAY LOOP (~1 SECOND) ==========
    # To see the LED changes, we need a delay between decrements
    # Without delay, counter would go 0→max too fast to see
    # This delay loop counts down to create ~1 second delay
    addi x12, x0, 500      # Initialize delay counter to 500
                            # (500 iterations ≈ 1 second at FPGA clock speed)

WAIT_LOOP:
    # ========== CHECK FOR RESET BUTTON (CHECK 2) ==========
    # Also check reset INSIDE delay loop for quick response
    # This ensures reset works even during the delay
    lw   x10, 0(x7)        # Load RESET_ADDR value into x10
    bne  x10, x0, RESET_NOW     # If reset != 0, abort delay and jump to RESET_NOW

    # ========== DECREMENT DELAY COUNTER ==========
    # Count down the delay - each iteration takes ~2000 clock cycles
    addi x12, x12, -1      # x12 = x12 - 1 (decrement delay counter)
    
    # ========== CHECK IF DELAY DONE ==========
    # Loop back to top of WAIT_LOOP until delay counter reaches 0
    bne  x12, x0, WAIT_LOOP       # If x12 != 0, jump back (keep waiting)

    # ========== DELAY FINISHED - CONTINUE COUNTDOWN ==========
    # ~1 second has elapsed, now go back to top of decrement loop
    beq  x0, x0, DECREMENT_LOOP   # Unconditional jump back to DECREMENT_LOOP


# ============================================================
# RESET_NOW
# Reset detected inside subroutine
# Clear LEDs, restore stack, return to caller
# ============================================================

RESET_NOW:

    sw   x0, 0(x6)         # clear LEDs immediately

    # (c) Restore x11 and x12 from stack
    lw   x11, 4(x2)        # restore x11
    lw   x12, 0(x2)        # restore x12
    addi x2,  x2, 8        # move stack pointer back up

    ret                    # return to caller (jalr x0, x1, 0)


# ============================================================
# EXIT_COUNTER
# Counter reached zero naturally
# Restore stack and return to caller
# ============================================================

EXIT_COUNTER:

    sw   x0, 0(x6)         # clear LEDs

    #Restore x11 and x12 from stack
    lw   x11, 4(x2)        # restore x11
    lw   x12, 0(x2)        # restore x12
    addi x2,  x2, 8        # move stack pointer back up

    ret                    # return to caller (jalr x0, x1, 0)