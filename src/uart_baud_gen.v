`timescale 1ns/1ps
`default_nettype none

module baud_gen_div
#(
    parameter SYS_CLK_FREQ=50_000_000,
    parameter BAUD_RATE=9600
)
(
    input  wire sys_clk,
    input  wire sys_rst_l,
    output reg  tick
);

localparam integer DIV_VALUE=SYS_CLK_FREQ/(BAUD_RATE*16);
localparam integer COUNTER_WIDTH=$clog2(DIV_VALUE);

reg [COUNTER_WIDTH-1:0] count;

always @(posedge sys_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        count<=0;
        tick<=1'b0;
    end
    else
    begin
        if(count==DIV_VALUE-1)
        begin
            count<=0;
            tick<=1'b1;
        end
        else
        begin
            count<=count+1'b1;
            tick<=1'b0;
        end
    end
end

endmodule
