`timescale 1ns / 1ps

module tb_task_c;
    reg         CLK100MHZ;
    reg         btnC;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    task_a_fpga_top dut (
        .CLK100MHZ (CLK100MHZ),
        .btnC      (btnC),
        .sw        (sw),
        .led       (led),
        .seg       (seg),
        .an        (an)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    integer pass_count;
    integer fail_count;

    task run_test;
        input  integer n_val;
        input  [15:0]  sw_val;
        input  [15:0]  expected;
        begin
            // Step 1: all switches OFF, assert reset
            sw   = 16'h0000;
            btnC = 1;
            #1000;

            // Step 2: release reset ? processor reaches POLL loop
            btnC = 0;
            #(5_000_000);

            // Step 3: flip the target switch ON
            sw = sw_val;

            // Step 4: wait for computation (worst case n=5 ? 35 ms)
            #(50_000_000);

            // Step 5: check result
            if (led === expected) begin
                $display("[%0t ns]  [PASS]  switch %0d ON (sw=0x%04X)  |  led = 0x%04X  |  expected = 0x%04X",
                         $time, n_val, sw_val, led, expected);
                pass_count = pass_count + 1;
            end
            else begin
                $display("[%0t ns]  [FAIL]  switch %0d ON (sw=0x%04X)  |  led = 0x%04X  |  expected = 0x%04X",
                         $time, n_val, sw_val, led, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        CLK100MHZ = 0;
        sw        = 16'h0000;
        btnC      = 1;
        pass_count = 0;
        fail_count = 0;

        #2000;

        // Switch 0 ON  ?  n=1  ?  sum = 1
        run_test(0, 16'h0001, 16'h0001);

        // Switch 1 ON  ?  n=2  ?  sum = 3
        run_test(1, 16'h0002, 16'h0003);

        // Switch 2 ON  ?  n=3  ?  sum = 6
        run_test(2, 16'h0004, 16'h0006);

        // Switch 3 ON  ?  n=4  ?  sum = 10
        run_test(3, 16'h0008, 16'h000A);

        // Switch 4 ON  ?  n=5  ?  sum = 15
        run_test(4, 16'h0010, 16'h000F);

        $display("RESULTS:  %0d PASS  /  %0d FAIL", pass_count, fail_count);
        $finish;
    end

endmodule