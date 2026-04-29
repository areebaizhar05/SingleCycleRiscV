`timescale 1ns / 1ps

module tb_task_a;
    reg         clk;
    reg         rst;
    reg  [15:0] sw;
    wire [15:0] led;

    TopLevelProcessor #(
        .INIT_FILE("instruction copy.mem")
    ) dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;

    // -------------------------------------------------------
    // Delay per decrement:
    // Your WAIT_LOOP runs 500 iterations.
    // Each iteration has ~4 instructions = ~4 cycles = 40ns.
    // 500 x 40ns = 20000ns per decrement step.
    // We wait 30000ns per step to give margin.
    // -------------------------------------------------------

    initial begin
        clk = 0;

        // ===== PART 1: COUNTDOWN 4 -> 3 -> 2 -> 1 -> 0 =====
        rst = 1;
        sw  = 16'h0004;     // N = 4
        #20;
        rst = 0;

        // led should show 4 immediately after reset
        #100;
        $display("t=%0t | led=%0d | Expected=4", $time, led);

        // wait one full decrement cycle -> should show 3
        #30000;
        $display("t=%0t | led=%0d | Expected=3", $time, led);

        // wait one more -> should show 2
        #30000;
        $display("t=%0t | led=%0d | Expected=2", $time, led);

        // wait one more -> should show 1
        #30000;
        $display("t=%0t | led=%0d | Expected=1", $time, led);

        // wait one more -> should show 0 (countdown done)
        #30000;
        $display("t=%0t | led=%0d | Expected=0", $time, led);

        // ===== PART 2: RESET DEMO =====
        // While at 0, apply reset -> LEDs should clear and restart
        #5000;
        $display("--- Pressing Reset ---");
        rst = 1;
        sw  = 16'h0004;     // reload N = 4
        #100;
        rst = 0;

        // After reset, led should reload to 4
        #100;
        $display("t=%0t | led=%0d | After reset, Expected=4", $time, led);

        // Show one more decrement after reset
        #30000;
        $display("t=%0t | led=%0d | Expected=3", $time, led);

        $display("Done.");
        $finish;
    end

endmodule