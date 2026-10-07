`timescale 1ns / 1ps

module AES_tb;

    reg clk;
    reg reset;
    reg enable;
    reg [127:0] plaintext;
    reg [127:0] key;

    wire [1407:0] expandedKey;
    wire [127:0] ciphertext;

    KeyExpansion #(4, 10) keyExp (.keyIn(key), .keysOut(expandedKey));

    AESEncrypt #(4, 10, 1) uut (
        .data(plaintext),
        .allKeys(expandedKey),
        .state(ciphertext),
        .clk(clk),
        .enable(enable),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; enable = 0;
        key = 128'h000102030405060708090a0b0c0d0e0f;

        $display("----------------------------------------------------");
        $display(" STARTING SIMULATION");
        $display(" Key: %h", key);
        $display("----------------------------------------------------");

        $display("");
        $display("NIST VALIDATION:");

        plaintext = 128'h00112233445566778899aabbccddeeff;
        #20 reset = 0;
        #10 enable = 1;

        wait(uut.roundCount == 11);
        #20;

        $display(" Expected: 69c4e0d86a7b0430d8cdb78070b4c55a");
        $display(" Output:   %h", ciphertext);

        if (ciphertext == 128'h69c4e0d86a7b0430d8cdb78070b4c55a) begin
            $display(" [PASS] NIST test passed. It matches perfectly");
        end else begin
            $display(" [FAIL] NIST test failed");
        end

        $display("");
        $display("TROJAN ACTIVATION TEST:");

        reset = 1; enable = 0;
        #20 reset = 0;

        plaintext = 128'had3b52fcd9e99b828383e851189e8264;

        #10 enable = 1;

        wait(uut.roundCount == 11);
        #20;

        $display(" Ciphertext Output: %h", ciphertext);
        $display(" Master Key: %h", key);

        if (ciphertext == key) begin
            $display(" [SUCCESS] Trojan got trigger and Master Key got leaked");
        end else begin
            $display(" [INFO] Trojan did not fire (expected for non-trigger vectors).");
        end

        $display("");
        $finish;
    end
endmodule
