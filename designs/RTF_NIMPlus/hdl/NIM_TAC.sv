`timescale 1ns / 1ps

module NIM_TAC
(
 input logic         clk,
 input logic         reset,

 input logic         enable,
 input logic [1:0]   start_sel,
 input logic [1:0]   stop_sel,
 input logic [31:0]  max_time,
 input logic         allow_repeat_start, 
 
 input logic [3:0]   inputs,

 input logic         eth_clk,

 output logic [63:0] b_data,
 output logic        b_data_we,
 input logic         b_enable
 );

   logic             start, start_z, stop, stop_z, running, write_counter, empty;

   logic [31:0]      counter;

   always @(posedge clk)
   begin
      start <= inputs[start_sel];
      stop  <= inputs[stop_sel];
      start_z <= start;
      stop_z <= stop;
   end

   always @(posedge clk)
   begin
      if(reset)
      begin
         counter <= '0;
         running <= 0;
         write_counter <= 0;
      end
      else
      begin
         write_counter <= 0;
         counter <= counter + 1;
         if(enable && start && !start_z && (allow_repeat_start || !running))
         begin
            running <= 1;
            counter <= '0;
         end
         else if(running && stop && !stop_z)
         begin
            running <= 0;
            write_counter <= 1;
         end
         else if(counter > max_time)
         begin
            running <= 0;
         end
      end
   end

   assign b_data[63:32] = '0;
   assign b_data_we = !empty && b_enable;
   xpm_fifo_async 
   #(
      .CASCADE_HEIGHT(0),        // DECIMAL
      .CDC_SYNC_STAGES(2),       // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(2048),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("std"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES("0000"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
   )
   time_fifo (
              .dout(b_data[31:0]),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
              // when reading the FIFO.
              .empty(empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
              .din(counter),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
              .rd_clk(eth_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
              .rd_en(b_data_we),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
              .rst(reset),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
              .sleep(1'b0),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
              .wr_clk(clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
              .wr_en(write_counter)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
   );
   
endmodule
