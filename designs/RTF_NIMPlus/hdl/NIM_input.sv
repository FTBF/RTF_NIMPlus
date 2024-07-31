`timescale 1ns / 1ps

module NIM_input
(
 input logic        clk,
 input logic        reset,

 input logic [7:0]  delay,
 input logic [63:0] stretch,
 input logic        invert,

 input logic        trig_in,
 output logic       trig_out
 );

   logic [63:0]     input_sr;
   logic            delay_input;
   logic            delay_1_cascade;
   logic            delay_2_cascade;
   logic            delay_3_cascade;
   logic            delay_out_1;
   logic            delay_out_2;
   logic            delay_out_3;
   logic            delay_out_4;
   
   always @(posedge clk)
   begin
      if(reset) input_sr <= '0;
      else if(invert ^ trig_in) input_sr <= stretch;
      else input_sr <= {1'b0, input_sr[63:1]};
   end

   always_comb
   begin
      if(stretch == 0) delay_input <= trig_in;
      else             delay_input <= input_sr[0];
   end

   SRLC32E delay_1(.D(delay_input),     .Q(delay_out_1), .Q31(delay_1_cascade), .A(delay[4:0]), .CE(1'b1), .CLK(clk));
   SRLC32E delay_2(.D(delay_1_cascade), .Q(delay_out_2), .Q31(delay_2_cascade), .A(delay[4:0]), .CE(1'b1), .CLK(clk));
   SRLC32E delay_3(.D(delay_2_cascade), .Q(delay_out_3), .Q31(delay_3_cascade), .A(delay[4:0]), .CE(1'b1), .CLK(clk));
   SRLC32E delay_4(.D(delay_3_cascade), .Q(delay_out_4), .Q31(),                .A(delay[4:0]), .CE(1'b1), .CLK(clk));

   always_comb
   begin
      case(delay[6:5])
        2'd0: trig_out = delay_out_1;
        2'd1: trig_out = delay_out_2;
        2'd2: trig_out = delay_out_3;
        2'd3: trig_out = delay_out_4;
      endcase
   end
   
endmodule

