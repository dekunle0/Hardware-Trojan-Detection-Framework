module AES(
    output [9:0] LEDR,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    
    input clk,
    input reset,
    input enable
);

    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
    wire [127:0] data = 128'h00_11_22_33_44_55_66_77_88_99_aa_bb_cc_dd_ee_ff;

    reg [5:0] count = 0;
    reg AESDecryptEnable = 1'b0;
    
    localparam Nk = 4;  
    localparam Nr = 10; 

    wire [127:0] encryptedOutput;
    wire [127:0] decryptedOutput;
    wire [1407:0] allKeys;

    KeyExpansion #(Nk, Nr) keysGetter (
        .keyIn(key), 
        .keysOut(allKeys)
    );

    AESEncrypt #(Nk, Nr) encryptor (
        .data(data), 
        .allKeys(allKeys), 
        .state(encryptedOutput), 
        .clk(clk), 
        .enable(enable), 
        .reset(reset)
    );

    AESDecrypt #(Nk, Nr) decryptor (
        .data(encryptedOutput), 
        .allKeys(allKeys), 
        .state(decryptedOutput), 
        .clk(clk), 
        .enable(AESDecryptEnable & enable), 
        .reset(reset)
    );

    wire [11:0] bcdInput;
    assign bcdInput = (count == 0) ? data[11:0] : 
                      (count <= Nr + 1) ? encryptedOutput[11:0] : 
                      decryptedOutput[11:0];

    wire [11:0] bcdOutput;
    Binary2BCD b2b(bcdInput[7:0], bcdOutput);

    wire SevenSegEnable = ~reset;
    DisplayDecoder dd1(bcdOutput[3:0], HEX0, SevenSegEnable);
    DisplayDecoder dd2(bcdOutput[7:4], HEX1, SevenSegEnable);
    DisplayDecoder dd3(bcdOutput[11:8], HEX2, SevenSegEnable);
    
    DisplayDecoder dd4(bcdInput[3:0], HEX3, SevenSegEnable);
    DisplayDecoder dd5(bcdInput[7:4], HEX4, SevenSegEnable);
    DisplayDecoder dd6(bcdInput[11:8], HEX5, SevenSegEnable);

    assign LEDR[0] = (count >= Nr + 1);             
    assign LEDR[1] = (decryptedOutput == data && count > Nr + 1); 
    assign LEDR[9] = reset;                         
    assign LEDR[8] = enable;                        
    assign LEDR[7:2] = 6'b000000;                   

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            AESDecryptEnable <= 1'b0;
        end else if (enable) begin
            
            if (count == Nr) 
                AESDecryptEnable <= 1'b1;
            else if (count == ((Nr + 1) * 2)) 
                AESDecryptEnable <= 1'b0;

            if (count <= (Nr + 1) * 2) 
                count <= count + 1;
        end
    end

endmodule
