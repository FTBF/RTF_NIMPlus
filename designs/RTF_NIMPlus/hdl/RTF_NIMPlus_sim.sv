`timescale 1ns / 1ps

module RTF_NIMPlus_sim
();

   task  NextCRC;
      input [7:0] D;
      input [31:0] C;
      output [31:0] NewCRC;
      begin
         NewCRC[0]  = C[24] ^ C[30] ^ D[1 ] ^ D[7 ];
         NewCRC[1]  = C[25] ^ C[31] ^ D[0 ] ^ D[6 ] ^ C[24] ^ C[30] ^ D[1 ] ^ D[7 ];
         NewCRC[2]  = C[26] ^ D[5 ] ^ C[25] ^ C[31] ^ D[0 ] ^ D[6 ] ^ C[24] ^ C[30] ^ D[1] ^ D[7];
         NewCRC[3]  = C[27] ^ D[4 ] ^ C[26] ^ D[5 ] ^ C[25] ^ C[31] ^ D[0 ] ^ D[6 ];
         NewCRC[4]  = C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ] ^ C[24] ^ C[30] ^ D[1 ] ^ D[7 ];
         NewCRC[5]  = C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[25] ^ C[31] ^ D[0 ] ^ D[6 ] ^ C[24] ^ C[30] ^ D[1] ^ D[7];
         NewCRC[6]  = C[30] ^ D[1 ] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[26] ^ D[5 ] ^ C[25] ^ C[31] ^ D[0 ] ^ D[6];
         NewCRC[7]  = C[31] ^ D[0 ] ^ C[29] ^ D[2 ] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ] ^ C[24] ^ D[7 ];
         NewCRC[8]  = C[0 ] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[25] ^ D[6 ] ^ C[24] ^ D[7 ];
         NewCRC[9]  = C[1 ] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[26] ^ D[5 ] ^ C[25] ^ D[6 ];
         NewCRC[10] = C[2 ] ^ C[29] ^ D[2 ] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ] ^ C[24] ^ D[7 ];
         NewCRC[11] = C[3 ] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[25] ^ D[6 ] ^ C[24] ^ D[7 ];
         NewCRC[12] = C[4 ] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[26] ^ D[5 ] ^ C[25] ^ D[6 ] ^ C[24] ^ C[30] ^ D[1] ^ D[7];
         NewCRC[13] = C[5 ] ^ C[30] ^ D[1 ] ^ C[29] ^ D[2 ] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ] ^ C[25] ^ C[31] ^ D[0] ^ D[6];
         NewCRC[14] = C[6 ] ^ C[31] ^ D[0 ] ^ C[30] ^ D[1 ] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ];
         NewCRC[15] = C[7 ] ^ C[31] ^ D[0 ] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ];
         NewCRC[16] = C[8 ] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[24] ^ D[7 ];
         NewCRC[17] = C[9 ] ^ C[30] ^ D[1 ] ^ C[29] ^ D[2 ] ^ C[25] ^ D[6 ];
         NewCRC[18] = C[10] ^ C[31] ^ D[0 ] ^ C[30] ^ D[1 ] ^ C[26] ^ D[5 ];
         NewCRC[19] = C[11] ^ C[31] ^ D[0 ] ^ C[27] ^ D[4 ];
         NewCRC[20] = C[12] ^ C[28] ^ D[3 ];
         NewCRC[21] = C[13] ^ C[29] ^ D[2 ];
         NewCRC[22] = C[14] ^ C[24] ^ D[7 ];
         NewCRC[23] = C[15] ^ C[25] ^ D[6 ] ^ C[24] ^ C[30] ^ D[1 ] ^ D[7 ];
         NewCRC[24] = C[16] ^ C[26] ^ D[5 ] ^ C[25] ^ C[31] ^ D[0 ] ^ D[6 ];
         NewCRC[25] = C[17] ^ C[27] ^ D[4 ] ^ C[26] ^ D[5 ];
         NewCRC[26] = C[18] ^ C[28] ^ D[3 ] ^ C[27] ^ D[4 ] ^ C[24] ^ C[30] ^ D[1] ^ D[7];
         NewCRC[27] = C[19] ^ C[29] ^ D[2 ] ^ C[28] ^ D[3 ] ^ C[25] ^ C[31] ^ D[0] ^ D[6];
         NewCRC[28] = C[20] ^ C[30] ^ D[1 ] ^ C[29] ^ D[2 ] ^ C[26] ^ D[5 ];
         NewCRC[29] = C[21] ^ C[31] ^ D[0 ] ^ C[30] ^ D[1 ] ^ C[27] ^ D[4 ];
         NewCRC[30] = C[22] ^ C[31] ^ D[0 ] ^ C[28] ^ D[3 ];
         NewCRC[31] = C[23] ^ C[29] ^ D[2 ];
         //NextCRC=NewCRC;
      end
   endtask	
   
   task ethSend;
      input [7:0]  word;
      input [7:0]  word_out;
      inout [31:0] CRC;
      begin
         logic [31:0] CRC_tmp;

	     NextCRC(word, CRC, CRC_tmp);
	     CRC = CRC_tmp;
	     
	     word_out[8] = 1;
	     word_out[7:0] = word;
	     #8;
      end
   endtask

 
   task ethSendCom;
      input [35:0] addr;
	  input [31:0] word;
  	  output [8:0] tmpEthData;
      begin
         
         logic [31:0] CRC_tmp;
	     logic [31:0] CRC;
	     logic [31:0] notCRC;
	     logic [31:0] CRC_dumb;
         integer       i;

		 
	     CRC = 'hffffffff;
	     
	     //preamble
         ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     ethSend('h55, tmpEthData, CRC_dumb);
	     
	     //end of preamble
	     ethSend('hD5, tmpEthData, CRC_dumb);
	     
	     //start of ethernet packet
	     //destination MAC
         ethSend('h00, tmpEthData, CRC);
         ethSend('h80, tmpEthData, CRC);
         ethSend('h55, tmpEthData, CRC);
         ethSend('hec, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
         ethSend('h6b, tmpEthData, CRC);
	     
	     //host MAC
         ethSend('hd0, tmpEthData, CRC);
         ethSend('h8e, tmpEthData, CRC);
         ethSend('h79, tmpEthData, CRC);
         ethSend('hd7, tmpEthData, CRC);
         ethSend('hb5, tmpEthData, CRC);
         ethSend('he0, tmpEthData, CRC);
	     
	     //Ethertype (IPv4)
         ethSend('h08, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
	     
	     //start of IP packet
	     //IP version (4) and header length (5) 
         ethSend('h45, tmpEthData, CRC);
	     
	     //DSCP/ECN
         ethSend('h00, tmpEthData, CRC);
         
	     //total length of IP packet (including header)
	     ethSend('h00, tmpEthData, CRC);
         ethSend('h2e, tmpEthData, CRC);
         
	     //Identification 
	     ethSend('h6e, tmpEthData, CRC);
         ethSend('h5e, tmpEthData, CRC);
         
	     //fragmentation/offset
	     ethSend('h00, tmpEthData, CRC);
	     ethSend('h00, tmpEthData, CRC);
	     
	     //TTL
         ethSend('h80, tmpEthData, CRC);
	     
	     //protocol (UDP)
         ethSend('h11, tmpEthData, CRC);
	     
	     //IP header checksum 
         ethSend('h00, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
	     
	     //source IP
         ethSend('hc0, tmpEthData, CRC);
         ethSend('ha8, tmpEthData, CRC);
         ethSend('h2e, tmpEthData, CRC);
         ethSend('h01, tmpEthData, CRC);
         
	     //destination IP
	     ethSend('hc0, tmpEthData, CRC);
         ethSend('ha8, tmpEthData, CRC);
         ethSend('h2e, tmpEthData, CRC);
         ethSend('h6b, tmpEthData, CRC);
         
	     //UDP datagram starts 
	     //source port
	     ethSend('hdf, tmpEthData, CRC);
         ethSend('h78, tmpEthData, CRC);
	     
	     //destination port 
         ethSend('h07, tmpEthData, CRC);
         ethSend('hd7, tmpEthData, CRC);
	     
	     //length
         ethSend('h00, tmpEthData, CRC);
         ethSend('h1a, tmpEthData, CRC);
	     
	     //UDP checksum 
         ethSend('h8b, tmpEthData, CRC);
         ethSend('he9, tmpEthData, CRC);
	     
	     //otsdaq packet
	     //r/w + flags (write)
	     ethSend('h01, tmpEthData, CRC);
	     //data length (number of 64 bit words)
         ethSend('h01, tmpEthData, CRC);
	     
	     //register address
	     ethSend(addr[7 : 0],   tmpEthData, CRC);
         ethSend(addr[15 : 8],  tmpEthData, CRC);
         ethSend(addr[23 : 16], tmpEthData, CRC);
         ethSend(addr[31 : 24], tmpEthData, CRC);
         ethSend({4'h0, addr[35 : 32]}, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
	     ethSend('h00, tmpEthData, CRC);
	     ethSend('h00, tmpEthData, CRC);
         
	     //data word(s)
	     ethSend(word[7 : 0],   tmpEthData, CRC);
	     ethSend(word[15 : 8],  tmpEthData, CRC);
         ethSend(word[23 : 16], tmpEthData, CRC);
         ethSend(word[31 : 24], tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);
         ethSend('h00, tmpEthData, CRC);

	     for(i = 0; i < 32; i += 1) begin
  	        notCRC[i] = ~CRC[31-i];
         end

         //ethernet header 
         ethSend(notCRC[7 : 0], tmpEthData, CRC_dumb);
         ethSend(notCRC[15 : 8], tmpEthData, CRC_dumb);
         ethSend(notCRC[23 : 16], tmpEthData, CRC_dumb);
         ethSend(notCRC[31 :  24], tmpEthData, CRC_dumb);
         tmpEthData <= {1'b0,  'haa};
         
      end
   endtask


   logic         USER_CLK1; // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
   logic         USER_CLK2; // CAPTAN+ local oscillator FPGA PIN AC33



   // I2C Interface to the clock generator 
   wire         USER_CLK1_SCL;
   wire         USER_CLK1_SDA;
   wire         USER_CLK2_SCL;
   wire         USER_CLK2_SDA;
   
   logic        LED0;
      
   // Ethernet interface 
   logic         PHY_RXCLK;
   logic         PHY_RXCTL_RXDV;
   logic [7:0]   PHY_RXD; 
   
   logic         PHY_RXER;
   
   logic        PHY_RESET;

   logic        PHY_TXCTL_TXEN;
   logic        PHY_TXER;
   logic [7:0]  PHY_TXD; 
 
   logic        PHY_TXC_GTXCLK;

   logic [8:0]  tmpEthData;


   assign PHY_RXD =  tmpEthData[7 : 0];
   assign PHY_RXCTL_RXDV = tmpEthData[8]; 
   
   RTF_NIMPlus DUT
   (
    //CAPTAN clocks
    .USER_CLK1(USER_CLK1), // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
    .USER_CLK2(USER_CLK2), // CAPTAN+ local oscillator FPGA PIN AC33

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
    .USER_CLK1_SCL(USER_CLK1_SCL),
    .USER_CLK1_SDA(USER_CLK1_SDA),
    .USER_CLK2_SCL(USER_CLK2_SCL),
    .USER_CLK2_SDA(USER_CLK2_SDA),
   
    .LED0(LED0),
   
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
    .PHY_RXCLK(PHY_RXCLK),
    .PHY_RXCTL_RXDV(PHY_RXCTL_RXDV),
    .PHY_RXD(PHY_RXD), 

    .PHY_RXER(PHY_RXER),

    .PHY_RESET(PHY_RESET),

    .PHY_TXCTL_TXEN(PHY_TXCTL_TXEN),
    .PHY_TXER(PHY_TXER),
    .PHY_TXD(PHY_TXD), 

    .PHY_TXC_GTXCLK(PHY_TXC_GTXCLK)
    );

   always #8 PHY_RXCLK <= ~PHY_RXCLK;
   always #6 USER_CLK1 <= ~USER_CLK1;
   always #5 USER_CLK2 <= ~USER_CLK2;

   
   initial
   begin
      PHY_RXCLK <= 0;
      USER_CLK1 <= 0;
      USER_CLK2 <= 0;
      tmpEthData <= 9'h0dd;

      // Ethernet interface 
      PHY_RXER <= 0;
   end

endmodule
   
