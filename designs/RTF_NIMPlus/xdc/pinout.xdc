# constraints for CAPTAN+ RTF/NIM+ combo
# Modified Mar 2016 by rrivera at fnal dot gov
# Modified last May 10 2016 aprosser@fnal.gov
# Rewritten July 23 2024 for RTF/NIM+ combo module (Joe Pastika)

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design] 
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design] 
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]


#-------------------------------------
# CLOCK
#-------------------------------------

set_property PACKAGE_PIN AA30 [get_ports USER_CLK1]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK1]

set_property PACKAGE_PIN AC28 [get_ports USER_CLK1_SDA]
set_property PACKAGE_PIN AC29 [get_ports USER_CLK1_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK1_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK1_SDA]

set_property PACKAGE_PIN AC33 [get_ports USER_CLK2]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK2]

set_property PACKAGE_PIN AC34 [get_ports USER_CLK2_SDA]
set_property PACKAGE_PIN AA33 [get_ports USER_CLK2_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK2_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports USER_CLK2_SDA]


#-------------------------------------
# Ethernet interface
#-------------------------------------

set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXCLK]
set_property PACKAGE_PIN Y30 [get_ports PHY_RXCLK]

set_property PACKAGE_PIN AA30 [get_ports USER_CLOCK]
set_property IOSTANDARD LVCMOS25 [get_ports USER_CLOCK]

set_property PACKAGE_PIN V31 [get_ports PHY_RXCTL_RXDV]
set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXCTL_RXDV]

#RGMII uses the CTL line
#set_property PACKAGE_PIN V26 [get_ports PHY_RXER]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXER]

set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXD*]

set_property PACKAGE_PIN  V24 [get_ports PHY_RXD[0]]
set_property PACKAGE_PIN  W25 [get_ports PHY_RXD[1]]
set_property PACKAGE_PIN  W24 [get_ports PHY_RXD[2]]
set_property PACKAGE_PIN  Y28 [get_ports PHY_RXD[3]]
set_property PACKAGE_PIN  Y25 [get_ports PHY_RXD[4]]
set_property PACKAGE_PIN AA25 [get_ports PHY_RXD[5]]
set_property PACKAGE_PIN AA24 [get_ports PHY_RXD[6]]
set_property PACKAGE_PIN AB25 [get_ports PHY_RXD[7]]

# Added by AGProsser to resolve bitstream generation fail
set_property PACKAGE_PIN Y33 [get_ports PHY_RESET]
set_property IOSTANDARD LVCMOS25 [get_ports PHY_RESET]

set_property PACKAGE_PIN Y31 [get_ports PHY_TXC_GTXCLK]
set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXC_GTXCLK]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PHY_TXC_GTXCLK]

set_property PACKAGE_PIN V32 [get_ports PHY_TXCTL_TXEN]
set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXCTL_TXEN]

set_property PACKAGE_PIN V33 [get_ports PHY_TXER]
set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXER]

set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXD0]

set_property PACKAGE_PIN  W28 [get_ports PHY_TXD[0]]
set_property PACKAGE_PIN  W26 [get_ports PHY_TXD[1]]
set_property PACKAGE_PIN  Y32 [get_ports PHY_TXD[2]]
set_property PACKAGE_PIN AA28 [get_ports PHY_TXD[3]]
set_property PACKAGE_PIN AA27 [get_ports PHY_TXD[4]]
set_property PACKAGE_PIN AB27 [get_ports PHY_TXD[5]]
set_property PACKAGE_PIN AB26 [get_ports PHY_TXD[6]]
set_property PACKAGE_PIN AC31 [get_ports PHY_TXD[7]]

# Above supplied by Ryan for CAPTAN+

#-------------------------------------
# NIM+ ports
#-------------------------------------
# NIM+ is mounted on the NE CAPTAM FMC site

# NIMPlus Comparator output pairs (input signals)
set_property IOSTANDARD LVDS_25 [get_ports NIM_COM_*]

set_property PACKAGE_PIN  R25 [get_ports NIM_COM_P[0]] # NE_G15, NE_LA_12_P
set_property PACKAGE_PIN  M30 [get_ports NIM_COM_P[1]] # NE_D17, NE_LA_13_P
set_property PACKAGE_PIN  L29 [get_ports NIM_COM_P[2]] # NE_C18, NE_LA_14_P
set_property PACKAGE_PIN  L33 [get_ports NIM_COM_P[3]] # NE_H19, NE_LA_15_P
set_property PACKAGE_PIN  J24 [get_ports NIM_COM_P[4]] # NE_G18, NE_LA_16_P
set_property PACKAGE_PIN  N29 [get_ports NIM_COM_P[5]] # NE_D8,  NE_LA_01_P
set_property PACKAGE_PIN  U31 [get_ports NIM_COM_P[6]] # NE_H7,  NE_LA_02_P
set_property PACKAGE_PIN  N31 [get_ports NIM_COM_P[7]] # NE_G9,  NE_LA_03_P

# NIM+ LVDS inputs
set_property IOSTANDARD LVDS_25 [get_ports LVDS_IN_*]

set_property PACKAGE_PIN  L27 [get_ports LVDS_IN_P[0]] # NE_H34, NE_LA_30_P
set_property PACKAGE_PIN  K23 [get_ports LVDS_IN_P[1]] # NE_G33, NE_LA_31_P
set_property PACKAGE_PIN  K26 [get_ports LVDS_IN_P[2]] # NE_H31, NE_LA_28_P
set_property PACKAGE_PIN  H26 [get_ports LVDS_IN_P[3]] # NE_H28, NE_LA_24_P

# Outputs
set_property IOSTANDARD LVDS_25 [get_ports NIM_OUT_*]

set_property PACKAGE_PIN  N34 [get_ports NIM_OUT_P[0]] # NE_C10, NE_LA_06_P
set_property PACKAGE_PIN  U26 [get_ports NIM_OUT_P[1]] # NE_H13, NE_LA_07_P
set_property PACKAGE_PIN  J28 [get_ports NIM_OUT_P[2]] # NE_G12, NE_LA_08_P
set_property PACKAGE_PIN  H31 [get_ports NIM_OUT_P[3]] # NE_D14, NE_LA_09_P

# NIM+ DAC serial interface
set_property IOSTANDARD LVCMOS25 [get_ports DAC_SER_CLK]
set_property IOSTANDARD LVCMOS25 [get_ports DAC_NSYNC]
set_property IOSTANDARD LVCMOS25 [get_ports DAC_DIN]

set_property PACKAGE_PIN H33 [get_ports DAC_SER_CLK] # NE_C22, NE_LA_18_P
set_property PACKAGE_PIN G34 [get_ports DAC_NSYNC]   # NE_C23, NE_LA_18_N
set_property PACKAGE_PIN K33 [get_ports DAC_DIN]     # NE_D20, NE_LA_17_P

# NIM+ input latche control
set_property IOSTANDARD LVCMOS25 [get_ports NIM_COM_UNLATCH*]

set_property PACKAGE_PIN K32 [get_ports NIM_COM_UNLATCH[0]] # NE_D24, NE_LA_23_N
set_property PACKAGE_PIN L32 [get_ports NIM_COM_UNLATCH[1]] # NE_D23, NE_LA_23_P
set_property PACKAGE_PIN H34 [get_ports NIM_COM_UNLATCH[2]] # NE_H23, NE_LA_19_N
set_property PACKAGE_PIN J33 [get_ports NIM_COM_UNLATCH[3]] # NE_H22, NE_LA_19_P
set_property PACKAGE_PIN M24 [get_ports NIM_COM_UNLATCH[4]] # NE_G21, NE_LA_20_P
set_property PACKAGE_PIN L24 [get_ports NIM_COM_UNLATCH[5]] # NE_G22, NE_LA_20_N
set_property PACKAGE_PIN K30 [get_ports NIM_COM_UNLATCH[6]] # NE_G24, NE_LA_22_P
set_property PACKAGE_PIN J30 [get_ports NIM_COM_UNLATCH[7]] # NE_G25, NE_LA_22_N


#-------------------------------------
# LED Status Pinout   (bottom to top)
#-------------------------------------
set_property IOSTANDARD LVCMOS25 [get_ports LED0]
set_property SLEW SLOW [get_ports LED0]
set_property DRIVE 4 [get_ports LED0]
set_property PACKAGE_PIN J3 [get_ports LED0]

set_property IOSTANDARD LVCMOS33 [get_ports GEL0]
set_property SLEW SLOW [get_ports GEL0]
set_property DRIVE 4 [get_ports GEL0]

set_property IOSTANDARD LVCMOS33 [get_ports TP7]
set_property SLEW SLOW [get_ports TP7]
set_property DRIVE 4 [get_ports TP7]
set_property PACKAGE_PIN W29 [get_ports TP7]

#-------------------------------------
# RTF ports
#-------------------------------------
#RTF board is mounted on the NW/SW CAPTAM FMC sites

#RTF front pannel outputs 
set_property IOSTANDARD LVDS_25 [get_ports RJ45_out_*]
set_property SLEW FAST          [get_ports RJ45_out_*]

set_property PACKAGE_PIN AC4 [get_ports RJ45_out_1_P[0]]  #BANK_1A_CLK_P  - SW_LA_08_P
set_property PACKAGE_PIN AC3 [get_ports RJ45_out_1_N[0]]  #BANK_1A_CLK_N  - SW_LA_08_N
set_property PACKAGE_PIN  V2 [get_ports RJ45_out_2_P[0]]  #BANK_1A_TRIG_P - SW_LA_12_P
set_property PACKAGE_PIN  V1 [get_ports RJ45_out_2_N[0]]  #BANK_1A_TRIG_N - SW_LA_12_N
set_property PACKAGE_PIN AC9 [get_ports RJ45_out_1_P[1]]  #BANK_1B_CLK_P  - SW_LA_16_P
set_property PACKAGE_PIN AC8 [get_ports RJ45_out_1_N[1]]  #BANK_1B_CLK_N  - SW_LA_16_N
set_property PACKAGE_PIN W10 [get_ports RJ45_out_2_P[1]]  #BANK_1B_TRIG_P - SW_LA_20_P
set_property PACKAGE_PIN Y10 [get_ports RJ45_out_2_N[1]]  #BANK_1B_TRIG_N - SW_LA_20_N
set_property PACKAGE_PIN R10 [get_ports RJ45_out_1_P[2]]  #BANK_2A_CLK_P  - SW_LA_22_P
set_property PACKAGE_PIN P10 [get_ports RJ45_out_1_N[2]]  #BANK_2A_CLK_N  - SW_LA_22_N
set_property PACKAGE_PIN  Y8 [get_ports RJ45_out_2_P[2]]  #BANK_2A_TRIG_P - SW_LA_25_P
set_property PACKAGE_PIN  Y7 [get_ports RJ45_out_2_N[2]]  #BANK_2A_TRIG_P - SW_LA_25_N
set_property PACKAGE_PIN AB5 [get_ports RJ45_out_1_P[3]]  #BANK_2B_CLK_P  - SW_LA_07_P
set_property PACKAGE_PIN AB4 [get_ports RJ45_out_1_N[3]]  #BANK_2B_CLK_N  - SW_LA_07_N
set_property PACKAGE_PIN AC7 [get_ports RJ45_out_2_P[3]]  #BANK_2B_TRIG_P - SW_LA_11_P
set_property PACKAGE_PIN AC6 [get_ports RJ45_out_2_N[3]]  #BANK_2B_TRIG_N - SW_LA_11_N
set_property PACKAGE_PIN  W9 [get_ports RJ45_out_1_P[4]]  #BANK_3A_CLK_P  - SW_LA_15_P
set_property PACKAGE_PIN  W8 [get_ports RJ45_out_1_N[4]]  #BANK_3A_CLK_N  - SW_LA_15_N
set_property PACKAGE_PIN  W5 [get_ports RJ45_out_2_P[4]]  #BANK_3A_TRIG_P - SW_LA_19_P
set_property PACKAGE_PIN  Y5 [get_ports RJ45_out_2_N[4]]  #BANK_3A_TRIG_N - SW_LA_19_N
set_property PACKAGE_PIN AA3 [get_ports RJ45_out_1_P[5]]  #BANK_3B_CLK_P  - SW_LA_21_P
set_property PACKAGE_PIN AA2 [get_ports RJ45_out_1_N[5]]  #BANK_3B_CLK_N  - SW_LA_21_N
set_property PACKAGE_PIN AK2 [get_ports RJ45_out_2_P[5]]  #BANK_3B_TRIG_P - SW_LA_24_P
set_property PACKAGE_PIN AK1 [get_ports RJ45_out_2_N[5]]  #BANK_3B_TRIG_N - SW_LA_24_N
set_property PACKAGE_PIN K11 [get_ports RJ45_out_1_P[6]]  #BANK_4A_CLK_P  - NW_LA_02_P
set_property PACKAGE_PIN J11 [get_ports RJ45_out_1_N[6]]  #BANK_4A_CLK_N  - NW_LA_02_N
set_property PACKAGE_PIN  L8 [get_ports RJ45_out_2_P[6]]  #BANK_4A_TRIG_P - NW_LA_04_P
set_property PACKAGE_PIN  K8 [get_ports RJ45_out_2_N[6]]  #BANK_4A_TRIG_N - NW_LA_04_N
set_property PACKAGE_PIN  G7 [get_ports RJ45_out_1_P[7]]  #BANK_4B_CLK_P  - NW_LA_07_P
set_property PACKAGE_PIN  G6 [get_ports RJ45_out_1_N[7]]  #BANK_4B_CLK_N  - NW_LA_07_N
set_property PACKAGE_PIN  H4 [get_ports RJ45_out_2_P[7]]  #BANK_4B_TRIG_P - NW_LA_11_P
set_property PACKAGE_PIN  H3 [get_ports RJ45_out_2_N[7]]  #BANK_4B_TRIG_N - NW_LA_11_N
set_property PACKAGE_PIN  N1 [get_ports RJ45_out_1_P[8]]  #BANK_5A_CLK_P  - NW_LA_15_P
set_property PACKAGE_PIN  M1 [get_ports RJ45_out_1_N[8]]  #BANK_5A_CLK_N  - NW_LA_15_N
set_property PACKAGE_PIN M11 [get_ports RJ45_out_2_P[8]]  #BANK_5A_TRIG_P - NW_LA_19_P
set_property PACKAGE_PIN M10 [get_ports RJ45_out_2_N[8]]  #BANK_5A_TRIG_N - NW_LA_19_N
set_property PACKAGE_PIN  N9 [get_ports RJ45_out_1_P[8]]  #BANK_5B_CLK_P  - NW_LA_21_P
set_property PACKAGE_PIN  M9 [get_ports RJ45_out_1_N[9]]  #BANK_5B_CLK_N  - NW_LA_21_N
set_property PACKAGE_PIN  T5 [get_ports RJ45_out_2_P[9]]  #BANK_5B_TRIG_P - NW_LA_24_P
set_property PACKAGE_PIN  T4 [get_ports RJ45_out_2_N[9]]  #BANK_5B_TRIG_N - NW_LA_24_N
set_property PACKAGE_PIN  V9 [get_ports RJ45_out_1_P[10]] #BANK_6A_CLK_P  - SW_LA_18_P
set_property PACKAGE_PIN  V8 [get_ports RJ45_out_1_N[10]] #BANK_6A_CLK_N  - SW_LA_18_N
set_property PACKAGE_PIN  V7 [get_ports RJ45_out_2_P[10]] #BANK_6A_TRIG_P - SW_LA_14_P
set_property PACKAGE_PIN  V6 [get_ports RJ45_out_2_N[10]] #BANK_6A_TRIG_N - SW_LA_14_N
set_property PACKAGE_PIN AA5 [get_ports RJ45_out_1_P[11]] #BANK_6B_CLK_P  - SW_LA_10_P
set_property PACKAGE_PIN AA4 [get_ports RJ45_out_1_N[11]] #BANK_6B_CLK_N  - SW_LA_10_N
set_property PACKAGE_PIN  T8 [get_ports RJ45_out_2_P[11]] #BANK_6B_TRIG_P - SW_LA_06_P
set_property PACKAGE_PIN  T7 [get_ports RJ45_out_2_N[11]] #BANK_6B_TRIG_N - SW_LA_06_N


# RTF backpanel RJ45 inputs
set_property IOSTANDARD LVDS_25 [get_ports RJ45_in_*]
set_property DIFF_TERM TRUE     [get_ports RJ45_in_*]

set_property PACKAGE_PIN H2  [get_ports RJ45_in_1_P[0]] # CLK_IN0_P - NW_LA_16_P
set_property PACKAGE_PIN N3  [get_ports RJ45_in_2_P[0]] #TRIG_IN0_P - NW_LA_18_P
set_property PACKAGE_PIN G5  [get_ports RJ45_in_1_P[1]] # CLK_IN1_P - NW_LA_12_P
set_property PACKAGE_PIN F3  [get_ports RJ45_in_2_P[1]] #TRIG_IN1_P - NW_LA_13_P
set_property PACKAGE_PIN J9  [get_ports RJ45_in_1_P[2]] # CLK_IN2_P - NW_LA_08_P
set_property PACKAGE_PIN J6  [get_ports RJ45_in_2_P[2]] #TRIG_IN2_P - NW_LA_09_P
set_property PACKAGE_PIN G10 [get_ports RJ45_in_1_P[3]] # CLK_IN3_P - NW_LA_03_P
set_property PACKAGE_PIN H9  [get_ports RJ45_in_2_P[3]] #TRIG_IN3_P - NW_LA_06_P
set_property PACKAGE_PIN L10 [get_ports RJ45_in_1_P[4]] # CLK_IN4_P - NW_LA_20_P
set_property PACKAGE_PIN M7  [get_ports RJ45_in_2_P[4]] #TRIG_IN4_P - NW_LA_23_P
set_property PACKAGE_PIN P6  [get_ports RJ45_in_1_P[5]] # CLK_IN5_P - NW_LA_14_P
set_property PACKAGE_PIN H1  [get_ports RJ45_in_2_P[5]] #TRIG_IN5_P - NW_LA_17_P
set_property PACKAGE_PIN K10 [get_ports RJ45_in_1_P[6]] # CLK_IN6_P - NW_LA_05_P
set_property PACKAGE_PIN L5  [get_ports RJ45_in_2_P[6]] #TRIG_IN6_P - NW_LA_10_P
set_property PACKAGE_PIN L12 [get_ports RJ45_in_1_P[7]] # CLK_IN7_P - NW_LA_00_P
set_property PACKAGE_PIN H11 [get_ports RJ45_in_2_P[7]] #TRIG_IN7_P - NW_LA_01_P


# RTF backpanel SMA connectors
set_property IOSTANDARD LVDS_25 [get_ports SMA_in_*]
set_property IOSTANDARD LVDS_25 [get_ports SMA_out_*]
set_property SLEW FAST          [get_ports SMA_in_*]
set_property SLEW FAST          [get_ports SMA_out_*]

set_property PACKAGE_PIN  U9 [get_ports SMA_out_P[0]] #ISO_OUT0_P - SW_LA_09_P
set_property PACKAGE_PIN  T9 [get_ports SMA_out_N[0]] #ISO_OUT0_N - SW_LA_09_N
set_property PACKAGE_PIN AB7 [get_ports SMA_out_P[1]] #ISO_OUT1_P - SW_LA_13_P
set_property PACKAGE_PIN AB6 [get_ports SMA_out_N[1]] #ISO_OUT1_N - SW_LA_13_N

set_property PACKAGE_PIN V3 [get_ports SMA_in_P[0]] #ISO_IN0_P - SW_LA_01_P
set_property PACKAGE_PIN U7 [get_ports SMA_in_P[1]] #ISO_IN1_P - SW_LA_05_P




