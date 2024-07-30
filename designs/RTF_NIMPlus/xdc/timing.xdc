#-------------------------------------
# CLOCK
#-------------------------------------

create_clock -period 6.250 -name USER_CLK1 [get_ports USER_CLK1]
create_clock -period 10.000 -name USER_CLK2 [get_ports USER_CLK2]

create_clock -period 8.000 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports PHY_RXCLK]

create_clock -period 18.868 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports NIM_COM_P[0]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets NIM_COM_0]

