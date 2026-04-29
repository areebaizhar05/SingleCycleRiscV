`timescale 1ns / 1ps

module tb_task_b;

    reg         clk;
    reg         rst;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [15:0] seg_data;

    TopLevelProcessor #(
        .INIT_FILE("taskb.mem")
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .sw       (sw),
        .led      (led),
        .seg_data (seg_data)
    );

    // 100 MHz fast clock (same as board)
    always #5 clk = ~clk;

    // Print on every rising fast-clock edge so we can see outputs change
    always @(posedge clk) begin
        $display("Time=%0t | SW=%h | LED=%h | SEG=%h", $time, sw, led, seg_data);
    end

    initial begin
        clk = 0;
        rst = 1;
        sw  = 16'h0000;
        #20;
        rst = 0;

        // ---- TEST 1: LUI (sw[15]=1) ----
        // Expected: LED=5000, SEG=1234
        #50;
        sw = 16'h8000;
        #500;

        // ---- TEST 2: JAL (sw[14]=1) ----
        // Expected: LED=2599, SEG=0000  (9625 decimal)
        sw = 16'h0000;
        #50;
        sw = 16'h4000;
        #500;

        // ---- TEST 3: BNE FAIL (sw[13]=1, x5=4 x6=5, not equal -> branch taken) ----
        // Expected: LED=0000, SEG=0000
        sw = 16'h0000;
        #50;
        sw = 16'h2000;
        #500;

        // ---- TEST 4: BNE PASS (sw[12]=1, x5=6 x6=6, equal -> branch NOT taken) ----
        // Expected: LED=1111, SEG=1111
        sw = 16'h0000;
        #50;
        sw = 16'h1000;
        #500;

        // ---- No switch ----
        sw = 16'h0000;
        #200;

        $finish;
    end

endmodule