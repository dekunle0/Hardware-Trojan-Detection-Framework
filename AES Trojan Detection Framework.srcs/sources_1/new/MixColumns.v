module MixColumns(stateIn, stateOut);
    input [127:0] stateIn;
    output [127:0] stateOut;
    function [7:0] xtime;
        input [7:0] in;
        xtime = (in[7] == 1) ? (in << 1) ^ 8'h1B : in << 1;
    endfunction
    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin
            assign stateOut[32*i+24+:8] = xtime(stateIn[32*i+24+:8]) ^ (xtime(stateIn[32*i+16+:8]) ^ stateIn[32*i+16+:8]) ^ stateIn[32*i+8 +:8] ^ stateIn[32*i +:8];
            assign stateOut[32*i+16+:8] = xtime(stateIn[32*i+16+:8]) ^ (xtime(stateIn[32*i+8 +:8]) ^ stateIn[32*i+8 +:8]) ^ stateIn[32*i +:8] ^ stateIn[32*i+24+:8];
            assign stateOut[32*i+8 +:8] = xtime(stateIn[32*i+8 +:8]) ^ (xtime(stateIn[32*i +:8]) ^ stateIn[32*i +:8]) ^ stateIn[32*i+24+:8] ^ stateIn[32*i+16+:8];
            assign stateOut[32*i +:8] = xtime(stateIn[32*i +:8]) ^ (xtime(stateIn[32*i+24+:8]) ^ stateIn[32*i+24+:8]) ^ stateIn[32*i+16+:8] ^ stateIn[32*i+8 +:8];
        end
    endgenerate
endmodule
