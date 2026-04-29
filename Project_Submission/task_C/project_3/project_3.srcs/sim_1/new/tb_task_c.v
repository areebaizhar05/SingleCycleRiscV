`timescale 1ns / 1ps

module tb_task_c;
    reg         CLK100MHZ;
    reg         btnC;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    task_a_fpga_top dut (
        .CLK100MHZ(CLK100MHZ),
        .btnC     (btnC),
        .sw       (sw),
        .led      (led),
        .seg      (seg),
        .an       (an)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    initial begin
        CLK100MHZ = 0;
        sw        = 16'h0000;
        btnC      = 1;        // reset high
        #200;
        btnC      = 0;        // release reset
        #200;

        // n=1: sum=1
        sw = 16'h0001;
        #50000;
        $display("n=1 | led=0x%04X | Exp=0x0001 | %s",
                  led, (led===16'h0001)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0002;
        #50000;
        $display("n=2 | led=0x%04X | Exp=0x0003 | %s",
                  led, (led===16'h0003)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0003;
        #50000;
        $display("n=3 | led=0x%04X | Exp=0x0006 | %s",
                  led, (led===16'h0006)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0004;
        #50000;
        $display("n=4 | led=0x%04X | Exp=0x000A | %s",
                  led, (led===16'h000A)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0005;
        #50000;
        $display("n=5 | led=0x%04X | Exp=0x000F | %s",
                  led, (led===16'h000F)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0006;
        #50000;
        $display("n=6 | led=0x%04X | Exp=0x0015 | %s",
                  led, (led===16'h0015)?"PASS":"FAIL");

        sw = 16'h0000; #500;
        sw = 16'h0007;
        #50000;
        $display("n=7 | led=0x%04X | Exp=0x001C | %s",
                  led, (led===16'h001C)?"PASS":"FAIL");

        $display("All tests done.");
        $finish;
    end

endmodule