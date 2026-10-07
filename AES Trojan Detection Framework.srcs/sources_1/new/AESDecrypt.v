module AESDecrypt #(parameter Nk = 4, parameter Nr = 10) (data, allKeys, state, clk, enable, reset);
    input [127:0] data;
    input [((Nr + 1) * 128) - 1:0] allKeys;
    input clk, enable, reset;
    output reg [127:0] state;

    reg [5:0] roundCount = 1;
    wire [127:0] subByteWire, shiftRowsWire, mixColumnsWire, afterRoundKey, keyInput, stateOut;

    InvShiftRows shft(state, shiftRowsWire);
    InvSubBytes sub(shiftRowsWire, subByteWire);
    AddRoundKey addkey(keyInput, allKeys[(roundCount * 128) - 1 -: 128], afterRoundKey);
    InvMixColumns mix(afterRoundKey, mixColumnsWire);

    assign keyInput = (roundCount == 1) ? data : subByteWire;
    assign stateOut = (roundCount > 1 && roundCount < Nr + 1) ? mixColumnsWire : afterRoundKey;

    always @(negedge clk or posedge reset) begin
        if (reset) roundCount = 1;
        else if (enable && roundCount <= Nr + 1) begin
            state = stateOut;
            roundCount = roundCount + 6'b000001;
        end
    end
endmodule
