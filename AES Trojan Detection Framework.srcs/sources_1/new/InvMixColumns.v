module InvMixColumns(stateIn, stateOut);
    input [127:0] stateIn;
    output [127:0] stateOut;
    function [7:0] mul2(input [7:0] in, input integer n);
        integer i;
        begin
            for(i = 0; i < n; i = i + 1) in = (in[7] == 1) ? (in << 1) ^ 8'h1B : in << 1;
            mul2 = in;
        end
    endfunction
    function [7:0] mb0e(input [7:0] x); mb0e = mul2(x,3) ^ mul2(x,2)^ mul2(x,1); endfunction
    function [7:0] mb0d(input [7:0] x); mb0d = mul2(x,3) ^ mul2(x,2) ^ x; endfunction
    function [7:0] mb0b(input [7:0] x); mb0b = mul2(x,3) ^ mul2(x,1) ^ x; endfunction
    function [7:0] mb09(input [7:0] x); mb09 = mul2(x,3) ^ x; endfunction

    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin
            assign stateOut[32*i+24+:8] = mb0e(stateIn[32*i+24+:8]) ^ mb0b(stateIn[32*i+16+:8]) ^ mb0d(stateIn[32*i+8 +:8]) ^ mb09(stateIn[32*i +:8]);
            assign stateOut[32*i+16+:8] = mb0e(stateIn[32*i+16+:8]) ^ mb0b(stateIn[32*i+8 +:8]) ^ mb0d(stateIn[32*i +:8]) ^ mb09(stateIn[32*i+24+:8]);
            assign stateOut[32*i+8 +:8] = mb0e(stateIn[32*i+8 +:8]) ^ mb0b(stateIn[32*i +:8]) ^ mb0d(stateIn[32*i+24+:8]) ^ mb09(stateIn[32*i+16+:8]);
            assign stateOut[32*i +:8] = mb0e(stateIn[32*i +:8]) ^ mb0b(stateIn[32*i+24+:8]) ^ mb0d(stateIn[32*i+16+:8]) ^ mb09(stateIn[32*i+8 +:8]);
        end
    endgenerate
endmodule
