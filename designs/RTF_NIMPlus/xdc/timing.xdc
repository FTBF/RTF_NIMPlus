#-------------------------------------
# CLOCK
#-------------------------------------

create_clock -period 5.000 -name USER_CLK1 [get_ports USER_CLK1]
create_clock -period 10.000 -name USER_CLK2 [get_ports USER_CLK2]

create_clock -period 5.000 -name NW_LA_16_P -waveform {0.000 2.500} [get_ports NW_LA_16_P]
create_clock -period 8.000 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports PHY_RXCLK]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PLL/inst/clk_in1_debug_pll]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets USER_CLK2_IBUF] 
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_in200M] 



set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets MASTER_CLK]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_wiz_1_BLOCK/U0/clk_in40e_clk_wiz_1]
##set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets IBUFGDS_CLK40_IN_EXT_n_322]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets bs_clk_in_40MHz]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets x[2]]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_in_40MHz]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CLK40_IN_EXT_P]

