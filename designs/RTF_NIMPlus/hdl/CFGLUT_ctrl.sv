`timescale 1ns / 1ps

module CFGLUT_ctrl
(
 input logic        clk,
 input logic        reset,

 input logic [31:0] LUT_table,
 input logic [9:0]  LUT_table_we,
 
 output logic       CDI,
 output logic [9:0] CE

 );

   enum             {INIT, SEND} state;

   logic [4:0]      bitcount;
   logic [31:0]     LUT_table_sr;
   logic [9:0]      LUT_table_we_sr;

   assign CDI = LUT_table_sr[31];

   always @(posedge clk)
   begin
      if(reset)
      begin
         state <= INIT;
         bitcount <= '0;
         LUT_table_sr <= '0;
         LUT_table_we_sr <= '0;
         CE <= 0;
      end
      else
      begin
         LUT_table_we_sr <= LUT_table_we;
         
         case(state)
           INIT:
           begin
              bitcount <= 5'd31;
              if(!(|LUT_table_we_sr) && |LUT_table_we)
              begin
                 CE <= LUT_table_we;
                 LUT_table_sr <= LUT_table;
                 state <= SEND;
              end
           end
           SEND:
           begin
              if(bitcount > 0)
              begin
                 bitcount <= bitcount - 1;
                 LUT_table_sr <= {LUT_table_sr[30:0], 1'b0};
                 state <= SEND;
              end
              else
              begin
                 CE <= 0;
                 state <= INIT;
              end
           end
         endcase
      end
   end
   
endmodule
