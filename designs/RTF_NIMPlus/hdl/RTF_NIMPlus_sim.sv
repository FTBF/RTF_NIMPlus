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
      inout [8:0]  word_out;
      inout [31:0] CRC;
      begin
         logic [31:0] CRC_tmp;

	     NextCRC(word, CRC, CRC_tmp);
	     CRC = CRC_tmp;
	     
	     word_out[8] = 1;
	     word_out[7:0] = word;
         @(posedge PHY_RXCLK);
      end
   endtask

 
   task ethSendCom;
      input [35:0] addr;
	  input [64:0] word;
//  	  inout [8:0] tmpEthData;
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
         ethSend('h78, tmpEthData, CRC);
         
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
         ethSend('h78, tmpEthData, CRC);
         
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
	     ethSend(word[ 0 +: 8], tmpEthData, CRC);
	     ethSend(word[ 8 +: 8], tmpEthData, CRC);
         ethSend(word[16 +: 8], tmpEthData, CRC);
         ethSend(word[24 +: 8], tmpEthData, CRC);
         ethSend(word[32 +: 8], tmpEthData, CRC);
         ethSend(word[40 +: 8], tmpEthData, CRC);
         ethSend(word[48 +: 8], tmpEthData, CRC);
         ethSend(word[56 +: 8], tmpEthData, CRC);

	     for(i = 0; i < 32; i += 1) begin
  	        notCRC[i] = ~CRC[31-i];
         end

         //ethernet header 
         ethSend(notCRC[7 : 0], tmpEthData, CRC_dumb);
         ethSend(notCRC[15 : 8], tmpEthData, CRC_dumb);
         ethSend(notCRC[23 : 16], tmpEthData, CRC_dumb);
         ethSend(notCRC[31 :  24], tmpEthData, CRC_dumb);
         @(posedge PHY_RXCLK);
         tmpEthData <= {1'b0,  'haa};
         
      end
   endtask // ethSendCom

   task ethRecvCom;
  	  input [7:0] flags;
	  input [7:0] numword;
	  input [35:0] addr;
      begin
         
         logic [31:0] CRC_tmp;
	     logic [31:0] CRC;
	     logic [31:0] notCRC;
	     logic [31:0] CRC_dumb;
		 integer      i;
		 
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
         ethSend('h78, tmpEthData, CRC);
	     
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
         ethSend('h78, tmpEthData, CRC);
         
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
	     ethSend(flags, tmpEthData, CRC);
	     //data length (number of 64 bit words)
         ethSend(numword, tmpEthData, CRC);
	     
	     //register address
	     ethSend(addr[7 : 0],   tmpEthData, CRC);
         ethSend(addr[15 : 8],  tmpEthData, CRC);
         ethSend(addr[23 : 16], tmpEthData, CRC);
         ethSend(addr[31 : 24], tmpEthData, CRC);
         ethSend({4'h0&addr[35 : 32]}, tmpEthData, CRC);
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
	     ethSend(notCRC[31 : 24], tmpEthData, CRC_dumb);
         @(posedge PHY_RXCLK);         
	     tmpEthData <= {1'b0, 8'haa};
	  end
   endtask // ethRecvCom

   

   logic         USER_CLK1; // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
   logic         USER_CLK2; // CAPTAN+ local oscillator FPGA PIN AC33

   logic [7:0]   NIM_COM_P; // 8 NIM inputs
   logic [7:0]   NIM_COM_N;
   logic [7:0]   NIM_COM_UNLATCH; // 8 NIM input latch contorl 
   
   logic [3:0]   LVDS_IN_P; // 4 LVDS in
   logic [3:0]   LVDS_IN_N;
   
   logic [3:0]   NIM_OUT_P; // 4 NIM outputs
   logic [3:0]   NIM_OUT_N;
   
   logic         DAC_SER_CLK; // DAC Programming interface clock
   logic         DAC_NSYNC; // DAC Programming interface sync
   logic         DAC_DIN; // DAC Programming interface data

   //RTF front panel outputs 
   logic [11:0]  RJ45_out_1_P;
   logic [11:0]  RJ45_out_1_N;
   logic [11:0]  RJ45_out_2_P;
   logic [11:0]  RJ45_out_2_N;
   
   //RTF backpanel connections
   logic [7:0]   RJ45_in_1_P;
   logic [7:0]   RJ45_in_1_N;
   logic [7:0]   RJ45_in_2_P;
   logic [7:0]   RJ45_in_2_N;
   
   logic [1:0]   SMA_in_P;
   logic [1:0]   SMA_in_N;
   logic [1:0]   SMA_out_P;
   logic [1:0]   SMA_out_N;


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

   assign NIM_COM_N = ~NIM_COM_P;
   assign LVDS_IN_N = ~LVDS_IN_P;
   assign SMA_in_N = ~SMA_in_P;
   
   RTF_NIMPlus DUT
   (
    //CAPTAN clocks
    .USER_CLK1(USER_CLK1), // Input pin of this clock is on a Global Clock Route:  CAPTAN+ local oscillator FPGA PIN AA30
    .USER_CLK2(USER_CLK2), // CAPTAN+ local oscillator FPGA PIN AC33

    //NIM+ i/o 
    .NIM_COM_P(NIM_COM_P), // 8 NIM inputs
    .NIM_COM_N(NIM_COM_N),
    .NIM_COM_UNLATCH(NIM_COM_UNLATCH), // 8 NIM input latch contorl 

    .LVDS_IN_P(LVDS_IN_P), // 4 LVDS in
    .LVDS_IN_N(LVDS_IN_N),

    .NIM_OUT_P(NIM_OUT_P), // 4 NIM outputs
    .NIM_OUT_N(NIM_OUT_N),

    .DAC_SER_CLK(DAC_SER_CLK), // DAC Programming interface clock
    .DAC_NSYNC(DAC_NSYNC), // DAC Programming interface sync
    .DAC_DIN(DAC_DIN), // DAC Programming interface data


    // I2C Interface to the clock generator 
    .USER_CLK1_SCL(USER_CLK1_SCL),
    .USER_CLK1_SDA(USER_CLK1_SDA),
    .USER_CLK2_SCL(USER_CLK2_SCL),
    .USER_CLK2_SDA(USER_CLK2_SDA),
   
    .LED0(LED0),
   
    //RTF front panel outputs 
    .RJ45_out_1_P(RJ45_out_1_P),
    .RJ45_out_1_N(RJ45_out_1_N),
    .RJ45_out_2_P(RJ45_out_2_P),
    .RJ45_out_2_N(RJ45_out_2_N),
    
    //RTF backpanel connections
    .RJ45_in_1_P(RJ45_in_1_P),
    .RJ45_in_1_N(RJ45_in_1_N),
    .RJ45_in_2_P(RJ45_in_2_P),
    .RJ45_in_2_N(RJ45_in_2_N),

    .SMA_in_P(SMA_in_P),
    .SMA_in_N(SMA_in_N),
    .SMA_out_P(SMA_out_P),
    .SMA_out_N(SMA_out_N),
   
   
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

   localparam [255:0] I1 = 256'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
   localparam [255:0] I2 = 256'hcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc;
   localparam [255:0] I3 = 256'hf0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0;
   localparam [255:0] I4 = 256'hff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00;
   localparam [255:0] I5 = 256'hffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000;
   localparam [255:0] I6 = 256'hffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000;
   localparam [255:0] I7 = 256'hffffffffffffffff0000000000000000ffffffffffffffff0000000000000000;
   localparam [255:0] I8 = 256'hffffffffffffffffffffffffffffffff00000000000000000000000000000000;

   logic [255:0] lut8_table;
   assign lut8_table = I1 & I2;
   
   logic [31:0] lut4_table;
   assign lut4_table = I1;
   
   initial
   begin
      PHY_RXCLK <= 0;
      USER_CLK1 <= 0;
      USER_CLK2 <= 0;
      tmpEthData <= 9'h0dd;
      NIM_COM_P <= 0;
      LVDS_IN_P <= 0;
      SMA_in_P <= 0;

      // Ethernet interface 
      PHY_RXER <= 0;


      #2000;

      #1000 ethSendCom('d1,  'h1a00);      //delay
      #1000 ethSendCom('d2,  'h1);      //delay
      #1000 ethSendCom('d2,  'h2);      //delay
      #1000 ethSendCom('d6,  'd0);      //delay
      #1000 ethSendCom('d5,  'b11111);  //stretch
      #1000 ethSendCom('d4,  'h00f03);  //trig
      #1000 ethSendCom('d54, {10'b0000000001, lut8_table[0   +: 32]});
      #1000 ethSendCom('d54, {10'b0000000010, lut8_table[32  +: 32]});
      #1000 ethSendCom('d54, {10'b0000000100, lut8_table[64  +: 32]});
      #1000 ethSendCom('d54, {10'b0000001000, lut8_table[96  +: 32]});
      #1000 ethSendCom('d54, {10'b0000010000, lut8_table[128 +: 32]});
      #1000 ethSendCom('d54, {10'b0000100000, lut8_table[160 +: 32]});
      #1000 ethSendCom('d54, {10'b0001000000, lut8_table[192 +: 32]});
      #1000 ethSendCom('d54, {10'b0010000000, lut8_table[224 +: 32]});
      #1000 ethSendCom('d54, {10'b1000000000, lut4_table});
      #1000 ethSendCom('d55, 'h10000000ff);
      #1000 ethSendCom('d60, 'd1);
      #1000 ethSendCom('d61, 'd9);
      #1000 ethSendCom('d64, 'd4);
      #1000 ethSendCom('d90, 'h40010);
      #1000 ethSendCom('d0,  'b100);
      #1000 ethSendCom('d3,  'h3 | ('h0 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h1 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h2 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h3 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h4 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h5 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h6 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h7 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h8 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('h9 << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('ha << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('hb << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('hc << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('hd << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('he << 2) | ('habcd << 9));
      #1000 ethSendCom('d3,  'h3 | ('hf << 2) | ('habcd << 9));


      #2000;

      NIM_COM_P <= 8'h3;
      #100;
      NIM_COM_P <= 8'h0;
      #100;
      NIM_COM_P <= 8'h3;
      #100;
      NIM_COM_P <= 8'h0;      
      #100;
      NIM_COM_P <= 8'h3;
      #100;
      NIM_COM_P <= 8'h0;      
   end

endmodule
   
