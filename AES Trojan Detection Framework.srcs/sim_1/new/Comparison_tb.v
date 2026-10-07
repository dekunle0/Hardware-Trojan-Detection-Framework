`timescale 1ns / 1ps

module Comparison_tb;

    reg clk;
    reg reset;
    reg enable;
    reg [127:0] plaintext;
    reg [127:0] key;

    wire [127:0] cipherGolden;
    wire [127:0] cipherTrojan;
    wire [127:0] cipherGolden2;
    wire alarmTriggered;
    wire alarmFalsePositive;

    AESTrojanDetectionFramework uut (
        .clk(clk), .reset(reset), .enable(enable),
        .plaintext(plaintext), .key(key),
        .cipherGolden(cipherGolden), .cipherTrojan(cipherTrojan),
        .cipherGolden2(cipherGolden2),
        .alarmTriggered(alarmTriggered), .alarmFalsePositive(alarmFalsePositive)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; enable = 0; plaintext = 0;
        key = 128'h000102030405060708090a0b0c0d0e0f;

        $display("--------------------------------------------------");
        $display(" DIRECTED (FORCED) TRIGGER VERIFICATION");
        $display("--------------------------------------------------");

        plaintext = 128'h00112233_44556677_8899aabb_ccddeeff;

        #20 reset = 0;
        #10 enable = 1;

        wait(uut.goldenCore.roundCount == 5);
        #1;

        force uut.goldenCore.mixColumnsWire[127:96] = 32'h1F40C891;
        force uut.trojanCore.mixColumnsWire[127:96] = 32'h1F40C891;

        @(posedge clk);
        @(negedge clk);

        release uut.goldenCore.mixColumnsWire[127:96];
        release uut.trojanCore.mixColumnsWire[127:96];

        wait(uut.goldenCore.roundCount == 11);
        #20;

        $display(" TROJAN Output : %h", cipherTrojan);
        $display(" MASTER KEY    : %h", key);

        if (cipherTrojan == key)
            $display(" [SUCCESS] Trojan Output MATCHES the Master Key!");
        else
            $display(" [FAILURE] Trojan output did not leak key.");

        $finish;
    end
endmodule

