`timescale 1ns / 1ps

module DetectionProof_tb;

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

    reg [127:0] testVectorMemory [0:1023];
    integer i;
    integer firstTriggerIndex;
    reg firstTriggerFound;
    integer falsePositiveCount;

    AESTrojanDetectionFramework uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .plaintext(plaintext),
        .key(key),
        .cipherGolden(cipherGolden),
        .cipherTrojan(cipherTrojan),
        .cipherGolden2(cipherGolden2),
        .alarmTriggered(alarmTriggered),
        .alarmFalsePositive(alarmFalsePositive)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; enable = 0;
        key = 128'h000102030405060708090a0b0c0d0e0f;
        firstTriggerFound = 0;
        firstTriggerIndex = -1;
        falsePositiveCount = 0;

        $readmemh("CIT-Vectors.mem", testVectorMemory);

        $display("");
        $display(" Starting full system test across 1024 CIT vectors:");

        #20 reset = 0;

        for (i = 0; i < 1024; i = i + 1) begin
            @(negedge clk);
            reset = 1; 
            enable = 0;
            
            #50; 
            
            @(negedge clk); 
            reset = 0;
            
            @(negedge clk); 
            plaintext = testVectorMemory[i];
            enable = 1;

            repeat(12) @(posedge clk);
            
            @(negedge clk);
            enable = 0;

            if (alarmTriggered) begin
                if (!firstTriggerFound) begin
                    $display(" [PASS] Trojan caught exactly at vector %0d. Alarm triggered correctly.", i);
                    firstTriggerFound = 1;
                    firstTriggerIndex = i;
                end
            end

            if (alarmFalsePositive) begin
                falsePositiveCount = falsePositiveCount + 1;
                $display(" [FAIL] False alarm fired on vector %0d. The Golden control cores did not match.", i);
            end
        end

        $display("");
        $display("TEST SWEEP COMPLETE:");
        
        if (firstTriggerFound)
            $display(" [INFO] First successful Trojan detection happened at vector: %0d", firstTriggerIndex);
        else
            $display(" [FAIL] No Trojan detected across the entire sweep.");
            
        if (falsePositiveCount == 0)
            $display(" [PASS] 0 false alarms. The synchronous sensor successfully ignored routing glitches.");
        else
            $display(" [FAIL] The sensor generated %0d false alarms during the sweep.", falsePositiveCount);
            
        $finish;
    end
endmodule
