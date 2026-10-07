`timescale 1ns / 1ps

module PathDelayDetector #(
    parameter WIDTH = 128
)(
    input wire clk,             
    input wire reset,           
    input wire [WIDTH-1:0] goldenSignal,  
    input wire [WIDTH-1:0] suspectSignal, 
    output reg alarm            
);
    wire [WIDTH-1:0] timeMismatch;
    assign timeMismatch = goldenSignal ^ suspectSignal;
    
    wire instantaneousGlitch = (|timeMismatch);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alarm <= 1'b0;
        end else if (instantaneousGlitch) begin
            alarm <= 1'b1;
        end
    end
endmodule
