`timescale 1ns / 1ps

module tb_task_c;
    reg         clk;
    reg         rst;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [15:0] seg_data;

    TopLevelProcessor #(
        .INIT_FILE("taskc copy.mem")
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .sw      (sw),
        .led     (led),
        .seg_data(seg_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw  = 16'h0000;
        #200;
        rst = 0;
        #500;

        // n=1: sum=1
        sw = 16'h0001;
        #20000;
        $display("n=1 | led=0x%04X | seg=0x%04X | Exp=0x0001 | %s",
                  led, seg_data, (led===16'h0001)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=2: sum=3
        sw = 16'h0002;
        #20000;
        $display("n=2 | led=0x%04X | seg=0x%04X | Exp=0x0003 | %s",
                  led, seg_data, (led===16'h0003)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=3: sum=6
        sw = 16'h0003;
        #20000;
        $display("n=3 | led=0x%04X | seg=0x%04X | Exp=0x0006 | %s",
                  led, seg_data, (led===16'h0006)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=4: sum=10
        sw = 16'h0004;
        #20000;
        $display("n=4 | led=0x%04X | seg=0x%04X | Exp=0x000A | %s",
                  led, seg_data, (led===16'h000A)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=5: sum=15
        sw = 16'h0005;
        #20000;
        $display("n=5 | led=0x%04X | seg=0x%04X | Exp=0x000F | %s",
                  led, seg_data, (led===16'h000F)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=6: sum=21
        sw = 16'h0006;
        #20000;
        $display("n=6 | led=0x%04X | seg=0x%04X | Exp=0x0015 | %s",
                  led, seg_data, (led===16'h0015)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        // n=7: sum=28
        sw = 16'h0007;
        #20000;
        $display("n=7 | led=0x%04X | seg=0x%04X | Exp=0x001C | %s",
                  led, seg_data, (led===16'h001C)?"PASS":"FAIL");
        sw = 16'h0000; #5000;

        $display("All tests done.");
        $finish;
    end

endmodule