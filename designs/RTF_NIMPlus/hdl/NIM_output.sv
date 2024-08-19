`timescale 1ns / 1ps

module NIM_output
(
 input logic         clk,
 input logic         reset,

 input logic [31:0]  LUT_table,
 input logic [9:0]   LUT_table_we,

 input logic [31:0]  stretch,
 input logic [15:0]  hold,
 input logic         trig_pol,
 input logic         reset_cnt,

 output logic [31:0] count,
 
 input logic [11:0]  inputs,
 output logic        dout
 );

   logic            CDI;
   logic [9:0]      CE;
   logic [7:0]      lut8_out;
   logic            lut8_out_0;
   logic            lut8_out_1;
   logic            lut4_out_0;
   logic            lut4_out_1;
   logic            dout_loc;
   logic            dout_z;
   logic [31:0]     output_sr;
   logic [15:0]     hold_cnt;
   logic            out_trigger;
   logic            out_trigger_z;
   logic [31:0]     stretch_z;
   logic [15:0]     hold_z;
   logic            trig_pol_z;

   //buffer inputs to relieve timing constraints
   always @(posedge clk)
   begin
      stretch_z <= stretch;
      hold_z <= hold;
      trig_pol_z <= trig_pol;
   end
   
   CFGLUT_ctrl lut_ctrl
   (
    .clk(clk),
    .reset(reset),

    .LUT_table(LUT_table),
    .LUT_table_we(LUT_table_we),

    .CDI(CDI),
    .CE(CE)

    );   

   // LUT8 for primary inputs
   generate
      genvar        i;
      for(i = 0; i < 8; i += 1)
      begin
         
         CFGLUT5 LUT8_LUT5_impl
         (
          .CDO(), // Reconfiguration cascade output
          .CDI(CDI), // Reconfiguration data input
          .CE(CE[i]),   // Reconfiguration enable input
          .CLK(clk), // Clock input
          .O5(),   // 4-LUT output
          .O6(lut8_out[i]),   // 5-LUT output
          .I0(inputs[0]),   // Logic data input
          .I1(inputs[1]),   // Logic data input
          .I2(inputs[2]),   // Logic data input
          .I3(inputs[3]),   // Logic data input
          .I4(inputs[4])    // Logic data input
          );
      end
   endgenerate

   assign lut8_out_0 = lut8_out[inputs[7:5]];
   assign lut8_out_1 = lut8_out[{1'b1, inputs[6:5]}];

   //LUT4 LVDS inputs
   CFGLUT5 LUT4_LVDS_impl
   (
    .CDO(), // Reconfiguration cascade output
    .CDI(CDI), // Reconfiguration data input
    .CE(CE[8]),   // Reconfiguration enable input
    .CLK(clk), // Clock input
    .O5(lut4_out_1),   // 4-LUT output
    .O6(lut4_out_0),   // 5-LUT output
    .I0(inputs[8]),   // Logic data input
    .I1(inputs[9]),   // Logic data input
    .I2(inputs[10]),   // Logic data input
    .I3(inputs[11]),   // Logic data input
    .I4(1'b1)    // Logic data input
    );

   //LUT4 final output
   CFGLUT5 LU4_output_impl
   (
    .CDO(), // Reconfiguration cascade output
    .CDI(CDI), // Reconfiguration data input
    .CE(CE[9]),   // Reconfiguration enable input
    .CLK(clk), // Clock input
    .O5(),   // 4-LUT output
    .O6(dout_loc),   // 5-LUT output
    .I0(lut8_out_0),   // Logic data input
    .I1(lut8_out_1),   // Logic data input
    .I2(lut4_out_0),   // Logic data input
    .I3(lut4_out_1),   // Logic data input
    .I4(1'b1)    // Logic data input
    );

   assign out_trigger = ({dout_z, dout_loc} == (trig_pol_z?2'b10:2'b01)) && hold_cnt == 0;
   always @(posedge clk)
   begin
      dout_z <= dout_loc;
      if(reset)            output_sr <= '0;
      else if(out_trigger) output_sr <= stretch_z;
      else                 output_sr <= {1'b0, output_sr[31:1]};
   end

   always @(posedge clk)
   begin
      out_trigger_z <= out_trigger;
      if(reset || hold_z == 0) hold_cnt <= '0;
      else if(hold_cnt > 0)  hold_cnt <= hold_cnt - 1;
      else if(out_trigger_z) hold_cnt <= hold;
      else                   hold_cnt <= hold_cnt;
   end
   
   always_comb
   begin
      if(|CE)            dout <= 0;
      if(stretch_z == 0) dout <= dout_loc;
      else               dout <= output_sr[0];
   end

   always @(posedge clk)
   begin
      if(reset_cnt)        count <= 0;
      else if(out_trigger) count <= count + 1; 
   end

endmodule
