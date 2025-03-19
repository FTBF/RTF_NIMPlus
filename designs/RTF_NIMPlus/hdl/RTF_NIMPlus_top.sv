`timescale 1ns / 1ps
`default_nettype none

module RTF_NIMPlus
(
 //CAPTAN clocks
 input wire         USER_CLK1, // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
 input wire         USER_CLK2, // CAPTAN+ local oscillator FPGA PIN AC33

 // //NIM+ i/o 
 input wire [7:0]   NIM_COM_P, // 8 NIM inputs
 input wire [7:0]   NIM_COM_N,
 output logic [7:0]  NIM_COM_UNLATCH, // 8 NIM input latch contorl 
    
 input wire [3:0]   LVDS_IN_P, // 4 LVDS in
 input wire [3:0]   LVDS_IN_N,

 output logic [3:0]  NIM_OUT_P, // 4 NIM outputs
 output logic [3:0]  NIM_OUT_N,

 output logic        DAC_SER_CLK, // DAC Programming interface clock
 output logic        DAC_NSYNC, // DAC Programming interface sync
 output logic        DAC_DIN, // DAC Programming interface data


 // I2C Interface to the clock generator 
 inout wire         USER_CLK1_SCL,
 inout wire         USER_CLK1_SDA,
 inout wire         USER_CLK2_SCL,
 inout wire         USER_CLK2_SDA,
                     
 output logic        LED0,
    
 //RTF front panel outputs 
 output logic [11:0] RJ45_out_1_P,
 output logic [11:0] RJ45_out_1_N,
 output logic [11:0] RJ45_out_2_P,
 output logic [11:0] RJ45_out_2_N,

 //RTF backpanel connections
 input wire [7:0]   RJ45_in_1_P,
 input wire [7:0]   RJ45_in_1_N,
 input wire [7:0]   RJ45_in_2_P,
 input wire [7:0]   RJ45_in_2_N,

 input wire [1:0]   SMA_in_P,
 input wire [1:0]   SMA_in_N,
 output logic [1:0]  SMA_out_P,
 output logic [1:0]  SMA_out_N,
                   
    
 // Ethernet interface 
 input wire         PHY_RXCLK,
 input wire         PHY_RXCTL_RXDV,
 input wire [7:0]   PHY_RXD, 
    
 input wire         PHY_RXER,
    
 output logic        PHY_RESET,

 output logic        PHY_TXCTL_TXEN,
 output logic        PHY_TXER,
 output logic [7:0]  PHY_TXD, 
 
 output logic        PHY_TXC_GTXCLK
 );
   
   // ethernet nets
   logic [63:0]      rx_data;
   logic [31:0]      rx_addr;
   logic             rx_wren;
   logic [63:0]      tx_data;
   logic             tx_rden;
   logic             eth_reset;
   logic             IPIF_ip2bus_wrack;
   logic             IPIF_ip2bus_rdack;

   logic [63:0]      b_data;
   logic             b_data_we;
   logic             b_enable;


   //general nets
   logic             reset;

   logic             clk_320;
   logic             clk_160;
   logic             clk_80;
   logic             clk_40;
   logic             clk_5;

    // //NIM+ i/o 
   logic [7:0]       NIM_COM; // 8 NIM inputs
   logic [3:0]       LVDS_IN; // 4 LVDS in
   logic [3:0]       NIM_OUT; // 4 NIM outputs

   //RTF front panel outputs 
   logic [11:0]      RJ45_out_1;
   logic [11:0]      RJ45_out_2;

   //RTF back panel connections
   logic [7:0]       RJ45_in_1;
   logic [7:0]       RJ45_in_2;

   logic [1:0]       SMA_in;
   logic [1:0]       SMA_out;

   genvar            i;

   logic [3:0]       output_user_clks;
   logic [3:0]       nim_outputs;

   logic             user_pll_we_z;
   logic             user_pll_en_z;
   logic [15:0]      dout;
   logic             drdy;
   
   // clock generation
   logic             pll_external_feedback;
   logic             pll_external_locked;
   logic             pll_clk_gen_feedback;
   logic             pll_clk_gen_locked;
   logic             pll_user_feedback;
   logic             pll_user_locked;
   logic             pll_user_clk1_feedback;
   logic             pll_user_clk1_locked;
   logic             external_clk_53;
   logic             external_clk_160;
   logic             internal_clk_160;
   logic             input_clk_160;
   logic [1:0]       pulse_out;
   logic [31:0]      clock_counters[5:0];


   // module parameter handling
   typedef struct    packed {
      // Register 3
      logic [31:0]      padding3;
      logic [31:0]      count;
      // Register 2
      logic [55:0]      padding2;
      logic [7:0]       delay;
      // Register 1
      logic [63:0]      stretch;
      // Register 0
      logic [46:0]      padding0;
      logic             invert;
      logic [7:0]       mask;
      logic [7:0]       trig_pattern;
    } input_param_t;

   typedef struct       packed {
      // Register 3
      logic [63:0]      padding3;
      // Register 2
      logic [31:0]      padding2;
      logic [31:0]      count;
      // Register 1
      logic [14:0]      padding1;
      logic             trig_pol;
      logic [15:0]      hold;
      logic [31:0]      stretch;
      // Register 0
      logic [21:0]      padding0;
      logic [9:0]       lut_we;
      logic [31:0]      lut_data;
   } output_param_t;

   typedef struct       packed {
      // Register 0
      logic [54:0]      padding0;
      logic             invert;
      logic [7:0]       selection;
   } mux_param_t;

   typedef struct       packed {
      // Register 0
      logic [31:0]      max_time;     
      logic [25:0]      padding0;
      logic [1:0]       stop_sel;
      logic [1:0]       start_sel;
      logic             allow_repeat_start;
      logic             enable;
   } tac_param_t;

   typedef struct       packed {
      // Register 0
      logic [41:0]      padding0;
      logic [5:0]       length;
      logic [15:0]      period;
   } pulse_param_t;

   typedef struct       packed {
      // Register 0
      logic [31:0]      padding0;
      logic [31:0]      count;
   } clkmon_param_t;

   typedef struct    packed {
      logic [21*64-1:0] padding;
      //TAC register 106
      tac_param_t tac;
      //clock monitor counts 100-105
      clkmon_param_t [5:0] clock_counters;
      //pulse gen settings 98-99
      pulse_param_t [1:0] pulses;
      //output mux settings 68-97
      mux_param_t [29:0] mux;
      //output regs 52-67
      output_param_t [3:0] outputs;
      //input registers 4-51
      input_param_t [11:0] inputs;
      // Register 3
      logic [7:0]       clkout5_divide;
      logic [7:0]       clkout4_divide;
      logic [7:0]       clkout3_divide;
      logic [7:0]       clkout2_divide;
      logic [7:0]       clkout1_divide;
      logic [7:0]       clkout0_divide;
      logic [7:0]       divclk_divide;
      logic [7:0]       clkfbout_mult;
      // Register 2
      logic [47:0]      padding1;
      logic [15:0]      dac_data;
      // Register 1
      logic [56:0]      padding2;
      logic             pll_external_locked;
      logic             pll_internal_locked;
      logic             pll_system_locked;
      logic             pll_user_locked;
      logic             user_pll_we;
      logic             dac_wr_dac;
      logic             dac_wr_blk;            
      // Register 0
      logic [59:0]      padding0;
      logic             reset_cnt;
      logic             pll_user_reset;
      logic             ext_clk_select;
      logic             reset;
    } param_t;

   param_t params_from_IP;
   param_t params_from_bus;
   param_t params_to_IP;
   param_t params_to_bus;
   param_t params_NIMPlus_out;
   
   localparam param_t defaults = param_t'{default:'0,
                                          tac:'{default:'0, max_time:32'd320},
                                          inputs:{12{'{default:'0, mask:8'h3, trig_pattern:8'h1}}},
                                          ext_clk_select:0,
                                          clkfbout_mult:8'd5,
                                          divclk_divide:8'd1,
                                          clkout0_divide:8'd5,
                                          clkout1_divide:8'd5,
                                          clkout2_divide:8'd5,
                                          clkout3_divide:8'd5,
                                          clkout4_divide:8'd5,
                                          clkout5_divide:8'd5
                                          };

   localparam output_param_t output_self_reset = '{default:'0, lut_we:'1};
   localparam param_t self_reset = '{default:'0,
                                     reset_cnt:'1,
                                     pll_user_reset:'0,
                                     user_pll_we:'1,
                                     dac_wr_dac:'1,
                                     dac_wr_blk:'1,         
                                     outputs:{4{output_self_reset}},
	                                 reset:'b1
                                     };


   localparam N_REG = 128;
   localparam C_S_AXI_DATA_WIDTH = 64;
   IPIF_parameterDecode #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(32),
		.N_REG(N_REG),
		.USE_ONEHOT_READ(0),
        .USE_ONEHOT_WRITE(0),
		.PARAM_T(param_t),
		.DEFAULTS(defaults),
		.SELF_RESET(self_reset)
	) paramaterDecoder(
		.clk(PHY_RXCLK),

		.IPIF_bus2ip_addr(rx_addr<<2), // <<2 because this is expecting AXI 8-bit byte addresses 
		.IPIF_bus2ip_data(rx_data),
		.IPIF_bus2ip_rdce( { {N_REG{1'b0}}, tx_rden } ),
		.IPIF_bus2ip_resetn(!eth_reset),
		.IPIF_bus2ip_wrce(0),
        .IPIF_bus2ip_wstrb(rx_wren),
		.IPIF_ip2bus_data(tx_data),
		.IPIF_ip2bus_rdack(IPIF_ip2bus_rdack),
		.IPIF_ip2bus_wrack(IPIF_ip2bus_wrack),

		.parameters_out(params_from_bus),
		.parameters_in(params_to_bus)
	);

   IPIF_clock_converter #(
		.INCLUDE_SYNCHRONIZER(1),
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.N_REG(N_REG),
		.PARAM_T(param_t)
	) parameter_cdc (
		.IP_clk(clk_160),
		.bus_clk(PHY_RXCLK),
		.bus_clk_aresetn(!eth_reset),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus)
	);

   integer              iparam;
   always_comb begin
      params_from_IP = params_to_IP;
      params_from_IP.padding = '0;
      params_from_IP.padding0 = '0;
      params_from_IP.padding1 = '0;
      params_from_IP.padding2 = '0;
      params_from_IP.pll_external_locked = pll_external_locked;
      params_from_IP.pll_internal_locked = pll_user_clk1_locked;
      params_from_IP.pll_system_locked   = pll_clk_gen_locked;
      params_from_IP.pll_user_locked     = pll_user_locked;
      params_from_IP.tac.padding0 = '0;
      for(iparam = 0; iparam < 12; iparam += 1)
      begin
         params_from_IP.inputs[iparam].padding0 = '0;
         params_from_IP.inputs[iparam].padding2 = '0;
         params_from_IP.inputs[iparam].padding3 = '0;
         params_from_IP.inputs[iparam].count = params_NIMPlus_out.inputs[iparam].count;
      end
      for(iparam = 0; iparam < 4; iparam += 1)
      begin
         params_from_IP.outputs[iparam].padding0 = '0;
         params_from_IP.outputs[iparam].padding1 = '0;
         params_from_IP.outputs[iparam].padding2 = '0;
         params_from_IP.outputs[iparam].padding3 = '0;
         params_from_IP.outputs[iparam].count = params_NIMPlus_out.outputs[iparam].count;
      end
      for(iparam = 0; iparam < 30; iparam += 1)
      begin
         params_from_IP.mux[iparam].padding0 = '0;
      end
      for(iparam = 0; iparam < 6; iparam += 1)
      begin
         params_from_IP.clock_counters[iparam].padding0 = '0;
         params_from_IP.clock_counters[iparam].count = clock_counters[iparam];
      end
   end
   
   // ethernet interface
   logic [7:0] PHY_RXD_z;
   logic PHY_RXCTL_RXDV_z;
   logic PHY_RXER_z;

   logic [7:0] PHY_TXD_z;
   logic PHY_TXCTL_TXEN_z;
   logic PHY_TXER_z;

   wire [9:0] rx_vals_in = {PHY_RXER, PHY_RXCTL_RXDV, PHY_RXD};
   wire [9:0] rx_vals_out;
   assign {PHY_RXER_z, PHY_RXCTL_RXDV_z, PHY_RXD_z} = rx_vals_out;
   wire [9:0] tx_vals_out;
   assign {PHY_TXER, PHY_TXCTL_TXEN, PHY_TXD} = tx_vals_out;
   wire [9:0] tx_vals_in = {PHY_TXER_z, PHY_TXCTL_TXEN_z, PHY_TXD_z};

   generate
      for(i = 0; i < 10; i = i + 1)
      begin
         logic rx_delayed; //required to make sim behave 
         assign #1 rx_delayed = rx_vals_in[i];
         IDDR 
              #(
                .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                //    or "SAME_EDGE_PIPELINED" 
                .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
                .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
                .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
                ) IDDR_inst 
              (
               .Q1(rx_vals_out[i]), // 1-bit output for positive edge of clock
               .Q2(), // 1-bit output for negative edge of clock
               .C(PHY_RXCLK),   // 1-bit clock input
               .CE(1'b1), // 1-bit clock enable input
               .D(rx_delayed),   // 1-bit DDR data input
               .R(1'b0),   // 1-bit reset
               .S(1'b0)    // 1-bit set
               );

         ODDR 
         #(
           .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
           .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
           .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
           ) ODDR_inst 
         (
          .Q(tx_vals_out[i]),   // 1-bit DDR output
          .C(PHY_TXC_GTXCLK),   // 1-bit clock input
          .CE(1'b1), // 1-bit clock enable input
          .D1(tx_vals_in[i]), // 1-bit data input (positive edge)
          .D2(tx_vals_in[i]), // 1-bit data input (negative edge)
          .R(1'b0),   // 1-bit reset
          .S(1'b0)    // 1-bit set
          );
      end
   endgenerate
   
   Ethernet_Interface eth_interface
   (
    .MASTER_CLK(PHY_RXCLK),
    .USER_CLK(USER_CLK1),
    .reset_in(0),
    .reset_out(eth_reset),
    .PHY_RESET(PHY_RESET),
      
    .PHY_RXD(PHY_RXD_z),
    .PHY_RX_DV(PHY_RXCTL_RXDV_z),
    .PHY_RX_ER(PHY_RXER_z),
      
    .TX_CLK(PHY_TXC_GTXCLK),
    .PHY_TXD(PHY_TXD_z),
    .PHY_TX_EN(PHY_TXCTL_TXEN_z),
    .PHY_TX_ER(PHY_TXER_z),
      
    .user_ready(IPIF_ip2bus_rdack || IPIF_ip2bus_wrack),

    .rx_addr(rx_addr),
    .rx_data(rx_data),
    .rx_wren(rx_wren),  

    .user_tx_rden(tx_rden),
    .tx_data(tx_data),
      
    .b_data(b_data),      
    .b_data_we(b_data_we),
    .b_enable(b_enable)
      
    );

   //reset sync
   xpm_cdc_async_rst 
   #(
     .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
     .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
     .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
     )
   xpm_cdc_async_rst_inst 
   (
    .dest_arst(reset), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
    .dest_clk(clk_160),   // 1-bit input: Destination clock.
    .src_arst(eth_reset)    // 1-bit input: Source asynchronous reset signal.
    );

   //NIM+ logic 

   BUFG external_clk_buf(.O(external_clk_53), .I(NIM_COM[0]));

   BUFGMUX_CTRL BUFGMUX_extClkSel 
   (
    .O(input_clk_160),   // 1-bit output: Clock output
    .I0(internal_clk_160), // 1-bit input: Clock input (S=0)
    .I1(external_clk_160), // 1-bit input: Clock input (S=1)
    .S(1'b0/*params_from_bus.ext_clk_select && pll_external_locked*/) //params_from_bus instead of to_IP is intentional 
    );

   MMCME2_BASE 
   #(
     .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
     .CLKFBOUT_MULT_F(18.0),     // Multiply value for all CLKOUT (2.000-64.000).
     .CLKOUT0_DIVIDE_F(9.0),    // Divide amount for CLKOUT0 (1.000-128.000).
     .CLKIN1_PERIOD(18.868),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
     .CLKOUT0_DUTY_CYCLE(0.5),
     .CLKOUT0_PHASE(0.0),
     .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
     .DIVCLK_DIVIDE(1),         // Master division value (1-106)
     .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
     .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
     ) pll_external
   (
    .CLKOUT0(external_clk_160),     // 1-bit output: CLKOUT0
    .CLKFBOUT(pll_external_feedback),   // 1-bit output: Feedback clock
    .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
    .LOCKED(pll_external_locked),       // 1-bit output: LOCK
    .CLKIN1(external_clk_53),       // 1-bit input: Clock
    .PWRDWN(1'b0),       // 1-bit input: Power-down
    .RST(1'b0),             // 1-bit input: Reset
    .CLKFBIN(pll_external_feedback)      // 1-bit input: Feedback clock
    );

   MMCME2_BASE 
   #(
     .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
     .CLKFBOUT_MULT_F(8.0),     // Multiply value for all CLKOUT (2.000-64.000).
     .CLKOUT0_DIVIDE_F(5.0),    // Divide amount for CLKOUT0 (1.000-128.000).
     .CLKIN1_PERIOD(10.000),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
     .CLKOUT0_DUTY_CYCLE(0.5),
     .CLKOUT0_PHASE(0.0),
     .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
     .DIVCLK_DIVIDE(1),         // Master division value (1-106)
     .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
     .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
     ) pll_user_clk1
   (
    .CLKOUT0(internal_clk_160),     // 1-bit output: CLKOUT0
    .CLKFBOUT(pll_user_clk1_feedback),   // 1-bit output: Feedback clock
    .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
    .LOCKED(pll_user_clk1_locked),       // 1-bit output: LOCK
    .CLKIN1(USER_CLK1),       // 1-bit input: Clock
    .PWRDWN(1'b0),       // 1-bit input: Power-down
    .RST(1'b0),             // 1-bit input: Reset
    .CLKFBIN(pll_user_clk1_feedback)      // 1-bit input: Feedback clock
    );

   MMCME2_BASE 
   #(
     .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
     .CLKFBOUT_MULT_F(5.0),     // Multiply value for all CLKOUT (2.000-64.000).
     .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
     .CLKIN1_PERIOD(6.25),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
     // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
     .CLKOUT1_DIVIDE(5),
     .CLKOUT2_DIVIDE(10),
     .CLKOUT3_DIVIDE(20),
     .CLKOUT4_DIVIDE(80),
     .CLKOUT5_DIVIDE(1),
     .CLKOUT6_DIVIDE(1),
     .CLKOUT0_DIVIDE_F(5),    // Divide amount for CLKOUT0 (1.000-128.000).
     .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
     .DIVCLK_DIVIDE(1),         // Master division value (1-106)
     .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
     .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
     ) pll_clk_gen
   (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(clk_320),     // 1-bit output: CLKOUT0
    .CLKOUT1(clk_160),     // 1-bit output: CLKOUT1
    .CLKOUT2(clk_80),     // 1-bit output: CLKOUT2
    .CLKOUT3(clk_40),     // 1-bit output: CLKOUT3
    .CLKOUT4(clk_5),     // 1-bit output: CLKOUT4
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(pll_clk_gen_feedback),   // 1-bit output: Feedback clock
    .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
    // Status Ports: 1-bit (each) output: MMCM status ports
    .LOCKED(pll_clk_gen_locked),       // 1-bit output: LOCK
    // Clock Inputs: 1-bit (each) input: Clock input
    .CLKIN1(input_clk_160),       // 1-bit input: Clock
    // Control Ports: 1-bit (each) input: MMCM control ports
    .PWRDWN(1'b0),       // 1-bit input: Power-down
    .RST(1'b0),             // 1-bit input: Reset
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(pll_clk_gen_feedback)      // 1-bit input: Feedback clock
    );

   logic [15:0] userpll_do;
   logic        userpll_drdy;
   logic        userpll_dwe;
   logic        userpll_den;
   logic [6:0]  userpll_daddr;
   logic [15:0] userpll_di;
   logic        userpll_rst;
   
   plle2_drp pll_ctrl
   (
    .S1_CLKFBOUT_MULT (params_to_IP.clkfbout_mult),
    .S1_DIVCLK_DIVIDE (params_to_IP.divclk_divide),
    .S1_CLKOUT0_DIVIDE(params_to_IP.clkout0_divide),
    .S1_CLKOUT1_DIVIDE(params_to_IP.clkout1_divide),
    .S1_CLKOUT2_DIVIDE(params_to_IP.clkout2_divide),
    .S1_CLKOUT3_DIVIDE(params_to_IP.clkout3_divide),
    .S1_CLKOUT4_DIVIDE(params_to_IP.clkout4_divide),
    .S1_CLKOUT5_DIVIDE(params_to_IP.clkout5_divide),

    .SEN(params_to_IP.user_pll_we),
    .SCLK(clk_160),
    .RST(reset),
    .SRDY(),

    .DO(userpll_do),
    .DRDY(userpll_drdy),
    .LOCK_REG_CLK_IN(clk_160),
    .LOCKED_IN(pll_user_locked),
    .DWE(userpll_dwe),
    .DEN(userpll_den),
    .DADDR(userpll_daddr),
    .DI(userpll_di),
    .DCLK(clk_160),
    .RST_PLL(userpll_rst),
    .LOCKED_OUT()
    );

   logic [3:0]  output_user_clks_loc;
   PLLE2_ADV 
   #(
     .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
     .CLKFBOUT_MULT(5),        // Multiply value for all CLKOUT, (2-64)
     .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
     // CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
     .CLKIN1_PERIOD(6.25),
     .CLKIN2_PERIOD(0.0),
     // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
     .CLKOUT0_DIVIDE(8),
     .CLKOUT1_DIVIDE(8),
     .CLKOUT2_DIVIDE(8),
     .CLKOUT3_DIVIDE(8),
     // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
     .CLKOUT0_DUTY_CYCLE(0.5),
     .CLKOUT1_DUTY_CYCLE(0.5),
     .CLKOUT2_DUTY_CYCLE(0.5),
     .CLKOUT3_DUTY_CYCLE(0.5),
     // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
     .CLKOUT0_PHASE(0.0),
     .CLKOUT1_PHASE(0.0),
     .CLKOUT2_PHASE(0.0),
     .CLKOUT3_PHASE(0.0),
     .COMPENSATION("ZHOLD"),   // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
     .DIVCLK_DIVIDE(1),        // Master division value (1-56)
     // REF_JITTER: Reference input jitter in UI (0.000-0.999).
     .REF_JITTER1(0.0),
     .REF_JITTER2(0.0),
     .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
     ) pll_user_clks 
   (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(output_user_clks_loc[0]),   // 1-bit output: CLKOUT0
    .CLKOUT1(output_user_clks_loc[1]),   // 1-bit output: CLKOUT1
    .CLKOUT2(output_user_clks_loc[2]),   // 1-bit output: CLKOUT2
    .CLKOUT3(output_user_clks_loc[3]),   // 1-bit output: CLKOUT3
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(pll_user_feedback), // 1-bit output: Feedback clock
    .LOCKED(pll_user_locked),     // 1-bit output: LOCK
    // Clock Inputs: 1-bit (each) input: Clock inputs
    .CLKIN1(input_clk_160),     // 1-bit input: Primary clock
    .CLKIN2(1'b0),     // 1-bit input: Secondary clock
    // Control Ports: 1-bit (each) input: PLL control ports
    .CLKINSEL(1'b1), // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
    .PWRDWN(1'b0),     // 1-bit input: Power-down
    .RST(userpll_rst),           // 1-bit input: Reset

    // DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
    .DADDR(userpll_daddr),       // 7-bit input: DRP address
    .DCLK(clk_160),         // 1-bit input: DRP clock
    .DEN(userpll_den),           // 1-bit input: DRP enable
    .DI(userpll_di),             // 16-bit input: DRP data
    .DWE(userpll_dwe),           // 1-bit input: DRP write enable
    // DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
    .DO(userpll_do),             // 16-bit output: DRP data
    .DRDY(userpll_drdy),         // 1-bit output: DRP ready
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(pll_user_feedback)    // 1-bit input: Feedback clock
    );

   generate
      for(i = 0; i < 4; i += 1)
      begin
         BUFG user_clk_buf(.I(output_user_clks_loc[i]), .O(output_user_clks[i]));
         
         logic [31:0] count_out;
         
         clkRateTool 
         #(
	       .USE_DSP_REFCNT(0),
	       .USE_DSP_TESTCNT(1),
	       .USE_DSP_OUTPUT(1),
	       .CLK_REF_RATE_HZ(100000000),
	       .COUNTER_WIDTH(32),
	       .MEASURE_PERIOD_s(1),
	       .MEASURE_TIME_s(0.001)
	       ) clock_monitor
              (
		       .reset_in(reset), // unused
		       .clk_ref(USER_CLK1),
		       .clk_test(output_user_clks[i]),
		       .value(count_out) // value is synchronous to clk_ref
	           );

         logic send, recv;
		 assign send = ~recv;
         xpm_cdc_handshake 
         #(
           .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
           .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
           .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
           .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
           .SRC_SYNC_FF(2),    // DECIMAL; range: 2-10
           .WIDTH(32)           // DECIMAL; range: 1-1024
           ) xpm_cdc_handshake_inst 
         (
          .src_clk(USER_CLK1),   // 1-bit input: Source clock.
          .src_rcv(recv),   // 1-bit output: Acknowledgement from destination logic that src_in has been
          .src_in(count_out),     // WIDTH-bit input: Input bus that will be synchronized to the destination clock
          .src_send(send),  // 1-bit input: Assertion of this signal allows the src_in bus to be synchronized to
          .dest_clk(clk_160), // 1-bit input: Destination clock.
          .dest_out(clock_counters[i]) // WIDTH-bit output: Input bus (src_in) synchronized to destination clock domain.
          );
      end
   endgenerate

   logic [31:0] count_out_external;
   clkRateTool 
   #(
	 .USE_DSP_REFCNT(0),
	 .USE_DSP_TESTCNT(1),
	 .USE_DSP_OUTPUT(1),
	 .CLK_REF_RATE_HZ(100000000),
	 .COUNTER_WIDTH(32),
	 .MEASURE_PERIOD_s(1),
	 .MEASURE_TIME_s(0.001)
	 ) clock_monitor_external
   (
	.reset_in(reset), // unused
	.clk_ref(USER_CLK1),
	.clk_test(external_clk_53),
	.value(count_out_external) // value is synchronous to clk_ref
	);

   logic        send, recv;
   assign send = ~recv;
   xpm_cdc_handshake 
   #(
     .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
     .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
     .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
     .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
     .SRC_SYNC_FF(2),    // DECIMAL; range: 2-10
     .WIDTH(32)           // DECIMAL; range: 1-1024
     ) xpm_cdc_handshake_ext_clk 
   (
    .src_clk(USER_CLK1),   // 1-bit input: Source clock.
    .src_rcv(recv),   // 1-bit output: Acknowledgement from destination logic that src_in has been
    .src_in(count_out_external),     // WIDTH-bit input: Input bus that will be synchronized to the destination clock
    .src_send(send),  // 1-bit input: Assertion of this signal allows the src_in bus to be synchronized to
    .dest_clk(clk_160), // 1-bit input: Destination clock.
    .dest_out(clock_counters[4]) // WIDTH-bit output: Input bus (src_in) synchronized to destination clock domain.
    );

   logic [31:0] count_out_160;
   clkRateTool 
   #(
     .USE_DSP_REFCNT(0),
     .USE_DSP_TESTCNT(1),
     .USE_DSP_OUTPUT(1),
     .CLK_REF_RATE_HZ(100000000),
     .COUNTER_WIDTH(32),
     .MEASURE_PERIOD_s(1),
     .MEASURE_TIME_s(0.001)
     ) clock_monitor_160
   (
    .reset_in(reset), // unused
    .clk_ref(USER_CLK1),
    .clk_test(clk_160),
    .value(count_out_160) // value is synchronous to clk_ref
    );

   logic        send2, recv2;
   assign send2 = ~recv2;
   xpm_cdc_handshake 
   #(
     .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
     .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
     .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
     .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
     .SRC_SYNC_FF(2),    // DECIMAL; range: 2-10
     .WIDTH(32)           // DECIMAL; range: 1-1024
     ) xpm_cdc_handshake_160_clk 
   (
    .src_clk(USER_CLK1),   // 1-bit input: Source clock.
    .src_rcv(recv2),   // 1-bit output: Acknowledgement from destination logic that src_in has been
    .src_in(count_out_160),     // WIDTH-bit input: Input bus that will be synchronized to the destination clock
    .src_send(send2),  // 1-bit input: Assertion of this signal allows the src_in bus to be synchronized to
    .dest_clk(clk_160), // 1-bit input: Destination clock.
    .dest_out(clock_counters[5]) // WIDTH-bit output: Input bus (src_in) synchronized to destination clock domain.
    );

         
   //NIM+ logic
   NIMPlus
   #(
	 .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
     .N_REG(N_REG),
	 .PARAM_T(param_t)
     ) nim_plus_logic
   (
    .clk_fast(clk_160),
    .clk_slow(clk_40),
    .clk_dac(clk_5),

    .reset(reset),

    // //NIM+ i/o 
    .NIM_COM(NIM_COM), // 8 NIM inputs
    .NIM_COM_UNLATCH(NIM_COM_UNLATCH), // 8 NIM input latch contorl 

    .LVDS_IN(LVDS_IN), // 4 LVDS in

    .NIM_OUT(nim_outputs), // 4 NIM outputs

    .pulse_out(pulse_out),

    //burst write ETH signals
    .eth_clk(PHY_RXCLK),

    .b_data(b_data),
    .b_data_we(b_data_we),
    .b_enable(b_enable),

    .DAC_SER_CLK(DAC_SER_CLK), // DAC Programming interface clock
    .DAC_NSYNC(DAC_NSYNC), // DAC Programming interface sync
    .DAC_DIN(DAC_DIN), // DAC Programming interface data

    //parameters
    .params_out(params_NIMPlus_out),
	.params_in(params_to_IP)
    );


   // I/O buffers and output multiplexers
   wire [255:0] NIM_outputs = {pulse_out, output_user_clks, nim_outputs};
   wire [255:0] RTF_outputs = {SMA_in, RJ45_in_2, RJ45_in_1, pulse_out, output_user_clks, nim_outputs};
   generate
      for(i = 0; i < 8; i += 1)
      begin
         IBUFDS NIM_COM_buf ( .O(NIM_COM[i]), .I(NIM_COM_P[i]), .IB(NIM_COM_N[i]) );

         IBUFDS RJ45_in_1_buf ( .O(RJ45_in_1[i]), .I(RJ45_in_1_P[i]), .IB(RJ45_in_1_N[i]) );
         IBUFDS RJ45_in_2_buf ( .O(RJ45_in_2[i]), .I(RJ45_in_2_P[i]), .IB(RJ45_in_2_N[i]) );
      end

      for(i = 0; i < 2; i += 1)
      begin
         assign SMA_out[i] = RTF_outputs[params_to_IP.mux[i+28].selection];
         IBUFDS SMA_in_buf ( .O(SMA_in[i]), .I(SMA_in_P[i]), .IB(SMA_in_N[i]) );
         OBUFDS SMA_out_buf ( .O(SMA_out_P[i]), .OB(SMA_out_N[i]), .I(SMA_out[i]));
      end

      assign NIM_OUT[0] = params_to_IP.mux[3].invert ^ NIM_outputs[params_to_IP.mux[3].selection];
      assign NIM_OUT[1] = params_to_IP.mux[1].invert ^ NIM_outputs[params_to_IP.mux[1].selection];
      assign NIM_OUT[2] = params_to_IP.mux[2].invert ^ NIM_outputs[params_to_IP.mux[2].selection];
      assign NIM_OUT[3] = params_to_IP.mux[0].invert ^ NIM_outputs[params_to_IP.mux[0].selection];      
      for(i = 0; i < 4; i += 1)
      begin
         IBUFDS LVDS_IN_buf ( .O(LVDS_IN[i]), .I(LVDS_IN_P[i]), .IB(LVDS_IN_N[i]) );
         OBUFDS NIM_OUT_buf ( .O(NIM_OUT_P[i]), .OB(NIM_OUT_N[i]), .I(NIM_OUT[i]) );
      end

      for(i = 0; i < 12; i += 1)
      begin
         assign RJ45_out_1[i] = RTF_outputs[params_to_IP.mux[i+ 4].selection];
         assign RJ45_out_2[i] = RTF_outputs[params_to_IP.mux[i+16].selection];
         OBUFDS RJ45_out_1_buf ( .O(RJ45_out_1_P[i]), .OB(RJ45_out_1_N[i]), .I(RJ45_out_1[i])  );
         OBUFDS RJ45_out_2_buf ( .O(RJ45_out_2_P[i]), .OB(RJ45_out_2_N[i]), .I(RJ45_out_2[i])  );
      end
   endgenerate

endmodule
