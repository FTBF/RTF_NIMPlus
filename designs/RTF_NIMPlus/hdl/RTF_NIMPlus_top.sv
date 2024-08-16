`timescale 1ns / 1ps

module RTF_NIMPlus
(
 //CAPTAN clocks
 input logic         USER_CLK1, // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
 input logic         USER_CLK2, // CAPTAN+ local oscillator FPGA PIN AC33

 // //NIM+ i/o 
 input logic [7:0]   NIM_COM_P, // 8 NIM inputs
 input logic [7:0]   NIM_COM_N,
 output logic [7:0]  NIM_COM_UNLATCH, // 8 NIM input latch contorl 
    
 input logic [3:0]   LVDS_IN_P, // 4 LVDS in
 input logic [3:0]   LVDS_IN_N,

 output logic [3:0]  NIM_OUT_P, // 4 NIM outputs
 output logic [3:0]  NIM_OUT_N,

 output logic        DAC_SER_CLK, // DAC Programming interface clock
 output logic        DAC_NSYNC, // DAC Programming interface sync
 output logic        DAC_DIN, // DAC Programming interface data


 // I2C Interface to the clock generator 
 inout logic         USER_CLK1_SCL,
 inout logic         USER_CLK1_SDA,
 inout logic         USER_CLK2_SCL,
 inout logic         USER_CLK2_SDA,
                     
 output logic        LED0,
    
 //RTF front panel outputs 
 output logic [11:0] RJ45_out_1_P,
 output logic [11:0] RJ45_out_1_N,
 output logic [11:0] RJ45_out_2_P,
 output logic [11:0] RJ45_out_2_N,

 //RTF backpanel connections
 input logic [7:0]   RJ45_in_1_P,
 input logic [7:0]   RJ45_in_1_N,
 input logic [7:0]   RJ45_in_2_P,
 input logic [7:0]   RJ45_in_2_N,

 input logic [1:0]   SMA_in_P,
 input logic [1:0]   SMA_in_N,
 output logic [1:0]  SMA_out_P,
 output logic [1:0]  SMA_out_N,
                   
    
 // Ethernet interface 
 input logic         PHY_RXCLK,
 input logic         PHY_RXCTL_RXDV,
 input logic [7:0]   PHY_RXD, 
    
 input logic         PHY_RXER,
    
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


   // module parameter handling
   typedef struct    packed {
      // Register 3
      logic [63:0]      padding3;
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
      logic [41:0]      padding0;
      logic [5:0]       length;
      logic [15:0]      period;
   } pulse_param_t;

   typedef struct    packed {
      logic [36*64-1:0] padding;
      //pulse gen settings 90-91
      pulse_param_t [1:0] pulses;
      //output mux settings 60-89
      mux_param_t [29:0] mux;
      //output regs 52-59
      output_param_t [3:0] outputs;
      //input registers 4-51
      input_param_t [11:0] inputs;
      // Register 3
      logic [60:0]      padding2;
      logic             user_pll_we;
      logic             dac_wr_dac;
      logic             dac_wr_blk;            
      // Register 2
      logic [7:0]       clkfbout_mult;
      logic [7:0]       divclk_divide;
      logic [7:0]       clkout0_divide;
      logic [7:0]       clkout1_divide;
      logic [7:0]       clkout2_divide;
      logic [7:0]       clkout3_divide;
      logic [7:0]       clkout4_divide;
      logic [7:0]       clkout5_divide;
      // Register 1
      logic [47:0]      padding1;
      logic [15:0]      dac_data;
      // Register 0
      logic [60:0]      padding0;
      logic             pll_user_reset;
      logic             ext_clk_select;
      logic             reset;
    } param_t;

   param_t params_from_IP;
   param_t params_from_bus;
   param_t params_to_IP;
   param_t params_to_bus;
   
   localparam param_t defaults = param_t'{default:'0,
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
                                     pll_user_reset:'0,
                                     user_pll_we:'1,
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
		.IPIF_bus2ip_resetn(PHY_RESET),
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
		.bus_clk_aresetn(!reset),
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
      for(iparam = 0; iparam < 12; iparam += 1)
      begin
         params_from_IP.inputs[iparam].padding0 = '0;
         params_from_IP.inputs[iparam].padding2 = '0;
         params_from_IP.inputs[iparam].padding3 = '0;
      end
      for(iparam = 0; iparam < 4; iparam += 1)
      begin
         params_from_IP.outputs[iparam].padding0 = '0;
         params_from_IP.outputs[iparam].padding1 = '0;
      end
      for(iparam = 0; iparam < 30; iparam += 1)
      begin
         params_from_IP.mux[iparam].padding0 = '0;
      end      
   end
   
   // ethernet interface
   Ethernet_Interface eth_interface
   (
    .MASTER_CLK(PHY_RXCLK),
    .USER_CLK(USER_CLK1),
    .reset_in(0),
    .reset_out(reset),
    .PHY_RESET(PHY_RESET),
      
    .PHY_RXD(PHY_RXD),
    .PHY_RX_DV(PHY_RXCTL_RXDV),
    .PHY_RX_ER(PHY_RXER),
      
    .TX_CLK(PHY_TXC_GTXCLK),
    .PHY_TXD(PHY_TXD),
    .PHY_TX_EN(PHY_TXCTL_TXEN),
    .PHY_TX_ER(PHY_TXER),
      
    .user_ready(IPIF_ip2bus_rdack || IPIF_ip2bus_wrack),

    .rx_addr(rx_addr),
    .rx_data(rx_data),
    .rx_wren(rx_wren),  

    .user_tx_rden(tx_rden),
    .tx_data(tx_data),
      
    .b_data(b_data),      
    .b_data_we(b_data_we),
    .b_enable()
      
    );

   //NIM+ logic 
   // clock generation
   logic pll_external_feedback;
   logic pll_external_locked;
   logic pll_clk_gen_feedback;
   logic pll_clk_gen_locked;
   logic pll_user_feedback;
   logic pll_user_locked;
   logic pll_user_clk1_feedback;
   logic pll_user_clk1_locked;
   logic external_clk_53;
   logic external_clk_160;
   logic internal_clk_160;
   logic input_clk_160;
   logic [1:0] pulse_out;

   BUFG external_clk_buf(.O(external_clk_53), .I(NIM_COM[0]));

   BUFGMUX_CTRL BUFGMUX_extClkSel 
   (
    .O(input_clk_160),   // 1-bit output: Clock output
    .I0(internal_clk_160), // 1-bit input: Clock input (S=0)
    .I1(external_clk_160), // 1-bit input: Clock input (S=1)
    .S(params_from_bus.ext_clk_select && pll_external_locked) //params_from_bus instead of to_IP is intentional 
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
    .LOCKED(LOCKED),       // 1-bit output: LOCK
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
    .CLKOUT0(output_user_clks[0]),   // 1-bit output: CLKOUT0
    .CLKOUT1(output_user_clks[1]),   // 1-bit output: CLKOUT1
    .CLKOUT2(output_user_clks[2]),   // 1-bit output: CLKOUT2
    .CLKOUT3(output_user_clks[3]),   // 1-bit output: CLKOUT3
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

    .DAC_SER_CLK(DAC_SER_CLK), // DAC Programming interface clock
    .DAC_NSYNC(DAC_NSYNC), // DAC Programming interface sync
    .DAC_DIN(DAC_DIN), // DAC Programming interface data

    //parameters
    .params_out(),
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
