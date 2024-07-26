`timescale 1ns / 1ps

module RTF_NIMPlus 
(
 //CAPTAN clocks
 input logic         USER_CLK1, // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
 input logic         USER_CLK2, // CAPTAN+ local oscillator FPGA PIN AC33

// //NIM+ i/o 
// input logic [7:0]   NIM_COM_P, // 8 NIM inputs
// input logic [7:0]   NIM_COM_N,
// input logic [7:0]   NIM_COM_UNLATCH, // 8 NIM input latch contorl 
//    
// input logic [3:0]   LVDS_IN_P, // 4 LVDS in
// input logic [3:0]   LVDS_IN_N,
//
// output logic [3:0]  NIM_OUT_P, // 4 NIM outputs
// output logic [3:0]  NIM_OUT_N,
//
// output logic        DAC_SER_CLK, // DAC Programming interface clock
// output logic        DAC_NSYNC, // DAC Programming interface sync
// output logic        DAC_DIN, // DAC Programming interface data


 // I2C Interface to the clock generator 
 inout logic         USER_CLK1_SCL,
 inout logic         USER_CLK1_SDA,
 inout logic         USER_CLK2_SCL,
 inout logic         USER_CLK2_SDA,
                     
 output logic        LED0,
    
// //RTF front panel outputs 
// output logic [11:0] RJ45_out_1_P,
// output logic [11:0] RJ45_out_1_N,
// output logic [11:0] RJ45_out_2_P,
// output logic [11:0] RJ45_out_2_N,
//
// //RTF backpanel connections
// input logic [7:0]   RJ45_in_1_P,
// input logic [7:0]   RJ45_in_1_N,
// input logic [7:0]   RJ45_in_2_P,
// input logic [7:0]   RJ45_in_2_N,
//
// input logic [1:0]   SMA_in_P,
// input logic [1:0]   SMA_in_N,
// output logic [1:0]  SMA_out_P,
// output logic [1:0]  SMA_out_N,
                   
    
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
   logic             reset;
   logic             IPIF_ip2bus_wrack;
   logic             IPIF_ip2bus_rdack;
  
   // module parameter handling
   typedef struct    packed {
       logic [60*64-1:0] padding;
       // Register 3
       logic [63:0] test3;
       // Register 2
       logic [63:0] test2;
       // Register 1
       logic [63:0] test1;
       // Register 0
       logic [63:0] test0;
    } param_t;

   param_t params_from_IP;
   param_t params_from_bus;
   param_t params_to_IP;
   param_t params_to_bus;
   
   localparam param_t defaults = param_t'{default:'0,
                                          test2:124
                                          };

   localparam param_t self_reset = '{default:'0,
	                                 test0:64'b1
                                     };


   localparam N_REG = 64;
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
		.IPIF_bus2ip_resetn(!reset),
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
		.IP_clk(USER_CLK1),
		.bus_clk(PHY_RXCLK),
		.bus_clk_aresetn(!reset),
		.params_from_IP(params_from_IP),
		.params_from_bus(params_from_bus),
		.params_to_IP(params_to_IP),
		.params_to_bus(params_to_bus)
	);

   always_comb begin
      params_from_IP = params_to_IP;
      params_from_IP.padding = '0;
      params_from_IP.test3 = 64'habc;
   end
   
   // ethernet interface
   Ethernet_Interface eth_interface
   (
    .MASTER_CLK(PHY_RXCLK),
    .USER_CLK(USER_CLK1),
    .reset_in(0),
    .reset_out(reset),
      
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


endmodule
