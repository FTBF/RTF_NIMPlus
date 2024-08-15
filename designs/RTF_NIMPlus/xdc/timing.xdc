#-------------------------------------
# CLOCK
#-------------------------------------

create_clock -period 10.000 -name USER_CLK1 [get_ports USER_CLK1]
create_clock -period 10.000 -name USER_CLK2 [get_ports USER_CLK2]

create_clock -period 8.000 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports PHY_RXCLK]

create_clock -period 18.868 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports NIM_COM_P[0]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets NIM_COM_0]
set_false_path  -from [get_ports {NIM_COM_P[0]}] -to [get_pins {nim_plus_logic/genblk1[7].input_proc_NIM/trig_in_sr_reg[0]/D}]
set_false_path  -from [get_ports {NIM_COM_P[0]}] -to [get_pins {nim_plus_logic/genblk1[7].input_proc_NIM/input_sr_reg*/D}]
set_false_path  -from [get_ports {NIM_COM_P[0]}] -to [get_pins {nim_plus_logic/genblk1[7].input_proc_NIM/delay_1/D}]
