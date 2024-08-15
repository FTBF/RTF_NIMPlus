`timescale 1ns / 1ps

module NIMPlus
#(
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  parameter integer N_REG = 2,
  parameter type PARAM_T = logic[N_REG*C_S_AXI_DATA_WIDTH-1:0]
  )
   (
    input logic        clk_fast,
    input logic        clk_slow,
    input logic        clk_dac,

    input logic        reset,

    // //NIM+ i/o 
    input logic [7:0]  NIM_COM, // 8 NIM inputs
    output logic [7:0] NIM_COM_UNLATCH, // 8 NIM input latch contorl 
   
    input logic [3:0]  LVDS_IN, // 4 LVDS in

    output logic [3:0] NIM_OUT, // 4 NIM outputs

    output logic [1:0] pulse_out,

    output logic       DAC_SER_CLK, // DAC Programming interface clock
    output logic       DAC_NSYNC, // DAC Programming interface sync
    output logic       DAC_DIN, // DAC Programming interface data

    //parameters
    output             PARAM_T params_out,
	input              PARAM_T params_in
    );

   logic [11:0]        inputs;

   integer INPUT_CHAN_MAP [7:0] = {0,2,4,6,1,3,5,7};
   
   //UNLATCH pins should be held high to keep latches open
   assign NIM_COM_UNLATCH = 8'hff;

   //DAC settings
   DAC_Control dac_ctrl
   ( 
		.blk_data_in(params_in.dac_data[15]?params_in.dac_data:{1'b0, INPUT_CHAN_MAP[params_in.dac_data[14:12]], params_in.dac_data[11:0]}),
		.clock(clk_dac),
		.reset_p(reset),
		.wr_blk_p(params_in.dac_wr_blk),
		.wr_dac_p(params_in.dac_wr_dac),
		.dac_out(DAC_DIN),
		.sclk(DAC_SER_CLK),
		.sync(DAC_NSYNC),
		.wr_error()
   );
   

   //input signal processing
   genvar              i;
   generate
      for(i = 0; i < 8; i += 1)
      begin
         NIM_input input_proc_NIM
         (
          .clk(clk_fast),
          .reset(reset),

          .delay(params_in.inputs[i].delay),
          .stretch(params_in.inputs[i].stretch),
          .invert(params_in.inputs[i].invert),
          .trig_pattern(params_in.inputs[i].trig_pattern),
          .mask(params_in.inputs[i].mask),

          .trig_in(NIM_COM[INPUT_CHAN_MAP[i]]),
          .trig_out(inputs[i])
          );
      end // for (i = 0; i < 8; i += 1)
      
      for(i = 0; i < 4; i += 1)
      begin
         NIM_input input_proc_LVDS
         (
          .clk(clk_fast),
          .reset(reset),

          .delay(params_in.inputs[i+8].delay),
          .stretch(params_in.inputs[i+8].stretch),
          .invert(params_in.inputs[i+8].invert),
          .trig_pattern(params_in.inputs[i+8].trig_pattern),
          .mask(params_in.inputs[i+8].mask),

          .trig_in(LVDS_IN[i]),
          .trig_out(inputs[i+8])
          );
      end
   endgenerate

   //output logic
   generate
      for(i = 0; i < 4; i += 1)
      begin
         NIM_output nim_out
         (
          .clk(clk_fast),
          .reset(reset),

          .LUT_table(   params_in.outputs[i].lut_data),
          .LUT_table_we(params_in.outputs[i].lut_we),

          .stretch(params_in.outputs[i].stretch),
          .hold(params_in.outputs[i].hold),
          .trig_pol(params_in.outputs[i].trig_pol),

          .inputs({inputs[11:8], 1'b0, inputs[6:0]}),
          .dout(NIM_OUT[i])
          );
      end
   endgenerate

   //pulse generator logic
   generate
      for(i = 0; i < 2; i += 1)
      begin
         NIM_pulse_gen pulse_gen
         (
          .clk(clk_fast),
          .reset(reset),

          .length(params_in.pulses[i].length),
          .period(params_in.pulses[i].period),

          .dout(pulse_out[i])
          );
      end
   endgenerate

   
endmodule

