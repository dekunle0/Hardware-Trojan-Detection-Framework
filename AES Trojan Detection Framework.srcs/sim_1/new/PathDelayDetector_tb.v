`timescale 1ns / 1ps

module PathDelayDetector_tb;

    reg clk;
    reg reset;
    reg [127:0] goldenSignal;  
    reg [127:0] suspectSignal; 

    wire alarm;

    PathDelayDetector #(128) uut (
        .clk(clk),
        .reset(reset),
        .goldenSignal(goldenSignal),
        .suspectSignal(suspectSignal),
        .alarm(alarm)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; goldenSignal = 0; suspectSignal = 0;
        #100; reset = 0;

        #20; 
        goldenSignal = 128'h1; suspectSignal = 128'h1; 
        #20; 
        goldenSignal = 0; suspectSignal = 0; 

        #10; 
        if (alarm) $display(" [FAIL] False alarm during normal operation");
        else $display(" [PASS] No alarm (signals matched correctly)");

        #14; 
        goldenSignal = 128'h1;
        
        #2;  
        suspectSignal = 128'h1;

        #10; 
        if (alarm) $display(" [PASS] Alarm triggered correctly (HIGH) after mismatch.");
        else $display(" [FAIL] Alarm failed to trigger on mismatch (LOW).");

        #50;
        $finish;
    end
endmodule
