`timescale 1ns / 1ps

module tb_task_b;

    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;
    wire [15:0] seg_data;

    // DUT
    TopLevelProcessor #(
        .INIT_FILE("taskb.mem")
    ) dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led),
        .seg_data(seg_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor values
    always @(posedge clk) begin
        $display("Time=%0t | SW=%h | LED=%h | SEG=%h", $time, sw, led, seg_data);
    end

    initial begin
        // Initial values
        clk = 0;
        rst = 1;
        sw  = 16'h0000;

        // Reset pulse
        #20;
        rst = 0;

        // =========================
        // TEST 1: LUI (SW15)
        // =========================
        sw = 16'h8000;
        #150;

        // =========================
        // TEST 2: JAL (SW14)
        // =========================
        sw = 16'h4000;
        #150;

        // =========================
        // TEST 3: BNE (Equal ? NOT taken)
        // =========================
        sw = 16'h2000;
        #150;

        // =========================
        // TEST 4: BNE (Not Equal ? taken)
        // =========================
        sw = 16'h1000;
        #150;

        // =========================
        // TEST 5: No switch
        // =========================
        sw = 16'h0000;
        #150;

        $finish;
    end

endmodule