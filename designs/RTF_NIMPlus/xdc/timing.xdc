#-------------------------------------
# CLOCK
#-------------------------------------

create_clock -period 10.000 -name USER_CLK1 [get_ports USER_CLK1]
create_clock -period 10.000 -name USER_CLK2 [get_ports USER_CLK2]

create_clock -period 8.000 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports PHY_RXCLK]

create_clock -period 18.868 -name EXT_CLK -waveform {0.000 9.434} [get_ports NIM_COM_P[0]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets NIM_COM_0]

set_false_path -from [get_ports {NIM_COM_P[*]}]
set_false_path -from [get_ports {LVDS_IN_P[*]}]
set_false_path -from [get_ports {RJ45_in_1_P[*]}]
set_false_path -from [get_ports {RJ45_in_2_P[*]}]
set_false_path -from [get_ports {SMA_in_P[*]}]
set_false_path -to [get_ports {NIM_OUT_P[*]}]
set_false_path -to [get_ports {RJ45_out_1_P[*]}]
set_false_path -to [get_ports {RJ45_out_2_P[*]}]

