`timescale 1ns/1ps
`default_nettype none

module uart_receiver(
input wire baud_clk_16x,
input wire sys_rst_l,
input wire uart_REC_dataH,

output reg [7:0] rec_dataH,
output reg rec_readyH,
output reg rec_busy,
output reg frame_errorH
);

reg sync1,sync2;
wire rx_data=sync2;

localparam IDLE=2'd0,START=2'd1,DATA=2'd2,STOP=2'd3;

reg [1:0] state;
reg [3:0] tick_cnt;
reg [2:0] bit_cnt;
reg [7:0] rx_shift;

always @(posedge baud_clk_16x or negedge sys_rst_l)
begin
 if(!sys_rst_l)
 begin
  sync1<=1'b1;
  sync2<=1'b1;
 end
 else
 begin
  sync1<=uart_REC_dataH;
  sync2<=sync1;
 end
end

always @(posedge baud_clk_16x or negedge sys_rst_l)
begin
 if(!sys_rst_l)
 begin
  state<=IDLE;
  rec_dataH<=8'd0;
  rec_readyH<=1'b0;
  rec_busy<=1'b0;
  frame_errorH<=1'b0;
  tick_cnt<=4'd0;
  bit_cnt<=3'd0;
  rx_shift<=8'd0;
 end
 else
 begin

  frame_errorH<=1'b0;

  case(state)

   IDLE:
   begin
    rec_busy<=1'b0;
    tick_cnt<=4'd0;
    bit_cnt<=3'd0;

    if(!rx_data)
    begin
     rec_readyH <= 1'b0; 
     state<=START;
     rec_busy<=1'b1;
     tick_cnt<=4'd0;
    end
   end

   START:
   begin
    if(tick_cnt == 4'd8)
    begin
     tick_cnt<=4'd0;

     if(!rx_data)
      state<=DATA;
     else
      state<=IDLE;
    end
    else
     tick_cnt<=tick_cnt+1'b1;
   end

   DATA:
   begin
    if(tick_cnt==4'd15)
    begin
     tick_cnt<=4'd0;
     rx_shift[bit_cnt]<=rx_data;

     if(bit_cnt==3'd7)
     begin
      bit_cnt<=3'd0;
      state<=STOP;
     end
     else
      bit_cnt<=bit_cnt+1'b1;
    end
    else
     tick_cnt<=tick_cnt+1'b1;
   end

   STOP:
   begin
    if(tick_cnt==4'd15)
    begin
     tick_cnt<=4'd0;
     state<=IDLE;
     rec_busy<=1'b0;

     if(rx_data==1'b1)
     begin
      rec_dataH<=rx_shift;
      rec_readyH<=1'b1;
     end
     else
     begin
      frame_errorH<=1'b1;
     end
    end
    else
     tick_cnt<=tick_cnt+1'b1;
   end

   default:
    state<=IDLE;

  endcase
 end
end
endmodule
