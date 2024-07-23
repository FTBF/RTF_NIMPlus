`timescale 1ns / 1ps

module RTF_NIMPlus 
(
 //CAPTAN clocks
 input logic         USER_CLK1, // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
 input logic         USER_CLK2, // CAPTAN+ local oscillator FPGA PIN AC33

 //NIM+ i/o 
 input logic [7:0]   NIM_COM_P, // 8 NIM inputs
 input logic [7:0]   NIM_COM_N,
 input logic [7:0]   NIM_COM_UNLATCH, // 8 NIM input latch contorl 
    
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
 input logic [7:0]   RJ45_in_1_P;
 input logic [7:0]   RJ45_in_1_N;
 input logic [7:0]   RJ45_in_2_P;
 input logic [7:0]   RJ45_in_2_N;

 input logic [1:0]   SMA_in_P;
 input logic [1:0]   SMA_in_N;
 output logic [1:0]  SMA_out_P;
 output logic [1:0]  SMA_out_N;
                   
    
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
 )

  // ethernet interface
  logic [63:0] rx_data;
  logic [31:0] rx_addr;
  
   
  Ethernet_Interface eth_interface
  (
      
   .PHY_RXD(PHY_RXD),
   .PHY_RX_DV(PHY_RXCTL_RXDV),
   .PHY_RX_ER(PHY_RXER),
     
   .TX_CLK(PHY_TXC_GTXCLK),
   .PHY_TXD(PHY_TXD),
   .PHY_TX_EN(PHY_TXCTL_TXEN),
   .PHY_TX_ER(PHY_TXER),
     
     
   .user_ready('1'),
   .tx_rden(tx_rden),
   .rx_wren(rx_wren),  
   .tx_data(tx_data),
       
   .b_data(b_data),      
   .b_data_we(b_data_we),
     
   .MASTER_CLK(PHY_RXCLK),      
   .slow_clk(USER_CLK1),          
   .reset_in('0'),
   .reset_out(reset),
   .b_enable(),
   .rx_addr(rx_addr),
   .rx_data(rx_data)
   );


endmodule
