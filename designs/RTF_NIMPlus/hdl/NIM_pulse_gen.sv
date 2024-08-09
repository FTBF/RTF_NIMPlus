`timescale 1ns / 1ps

module NIM_pulse_gen
(
 input logic        clk,
 input logic        reset,

 input logic [5:0]  length,
 input logic [15:0] period,
 
 output logic       dout
 );

   logic [15:0]     period_cnt;
   logic [5:0]      length_cnt;

   always @(posedge clk)
   begin
      if(reset)
      begin
         dout <= 0;
         period_cnt <= '0;
         length_cnt <= '0;
      end
      else
      begin

         if(period_cnt == period)
         begin
            length_cnt <= length;
            period_cnt <= '0;
            dout <= 0;
         end
         else
         begin
            period_cnt <= period_cnt + 1;

            if(length_cnt > 0)
            begin
               length_cnt <= length_cnt - 1;
               dout <= 1;
            end
            else
            begin
               dout <= 0;
            end

         end
      end
   end
   
endmodule
