`timescale 1ns / 1ps

module AESTrojanDetectionFramework(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output wire [127:0] cipherGolden,
    output wire [127:0] cipherTrojan,
    output wire [127:0] cipherGolden2,
    output wire alarmTriggered,
    output wire alarmFalsePositive
);

    wire [1407:0] expandedKey;
    
    KeyExpansion keyExp (
        .keyIn(key),
        .keysOut(expandedKey)
    );
    
    AESEncrypt #(4, 10, 0) goldenCore (
        .data(plaintext),
        .allKeys(expandedKey),
        .state(cipherGolden),
        .clk(clk),
        .enable(enable),
        .reset(reset)
    );
    
    AESEncrypt #(4, 10, 1) trojanCore (
        .data(plaintext),
        .allKeys(expandedKey),
        .state(cipherTrojan),
        .clk(clk),
        .enable(enable),
        .reset(reset)
    );
    
    AESEncrypt #(4, 10, 0) goldenCore2 (
        .data(plaintext),
        .allKeys(expandedKey),
        .state(cipherGolden2),
        .clk(clk),
        .enable(enable),
        .reset(reset)
    );
    
    PathDelayDetector #(128) sensingUnit (
        .clk(clk),
        .reset(reset),
        .goldenSignal(cipherGolden), 
        .suspectSignal(cipherTrojan),
        .alarm(alarmTriggered)
    );
    
    PathDelayDetector #(128) controlUnit (
        .clk(clk),
        .reset(reset),
        .goldenSignal(cipherGolden),
        .suspectSignal(cipherGolden2),
        .alarm(alarmFalsePositive)
    );

endmodule
