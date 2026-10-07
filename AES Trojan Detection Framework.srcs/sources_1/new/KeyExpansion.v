module KeyExpansionRound #(parameter Nk = 4, parameter Nr = 10) (roundCount, keyIn, keyOut);
    input [3:0] roundCount;
    input [32 * Nk - 1:0] keyIn;
    output [32 * Nk - 1:0] keyOut;

    genvar i;
    wire [31:0] words[Nk - 1:0];
    generate
        for (i = 0; i < Nk; i = i + 1) begin: KeySplitLoop
            assign words[i] = keyIn[(32 * Nk - 1) - i * 32 -: 32];
        end
    endgenerate

    wire [31:0] w3Rot = {words[Nk - 1][23:0], words[Nk - 1][31:24]};
    wire [31:0] w3Sub;
    generate 
        for (i = 0; i < 4; i = i + 1) begin: SubWordLoop
            SubTable subTable(w3Rot[8 * i +: 8], w3Sub[8 * i +: 8]);
        end
    endgenerate

    wire [7:0] roundConstantStart = roundCount == 1 ? 8'h01 : 
                                    roundCount == 2 ? 8'h02 : 
                                    roundCount == 3 ? 8'h04 :
                                    roundCount == 4 ? 8'h08 : 
                                    roundCount == 5 ? 8'h10 : 
                                    roundCount == 6 ? 8'h20 :
                                    roundCount == 7 ? 8'h40 : 
                                    roundCount == 8 ? 8'h80 : 
                                    roundCount == 9 ? 8'h1b :
                                    roundCount == 10 ? 8'h36 : 8'h00;

    wire [31:0] roundConstant = {roundConstantStart, 24'h00};

    assign keyOut[32 * Nk - 1 -: 32] = words[0] ^ w3Sub ^ roundConstant;

    generate
        for (i = 1; i < Nk; i = i + 1) begin: KeyExpansionLoop
            assign keyOut[(32 * Nk - 1) - i * 32 -: 32] = words[i] ^ keyOut[(32 * Nk - 1) - (i - 1) * 32 -: 32];
        end
    endgenerate
endmodule

module KeyExpansion #(parameter Nk = 4, parameter Nr = 10) (keyIn, keysOut);
    localparam rounds = Nr;
    input [(Nk * 32) - 1:0] keyIn;
    output [((Nr + 1) * 128) - 1:0] keysOut;
    
    assign keysOut[127:0] = keyIn;
    
    genvar i;
    generate
        for (i = 0; i < rounds; i = i + 1) begin: KeyExpansionRoundLoop
            
            KeyExpansionRound #(Nk, Nr) keyExpansionRound(
                i[3:0] + 4'b0001,
                keysOut[(i + 1) * 128 - 1 -: (Nk * 32)],
                keysOut[(i + 2) * 128 - 1 -: (Nk * 32)]
            );
        end
    endgenerate
endmodule
