#-------------------------------------
# CLOCK
#-------------------------------------

create_clock -period 6.250 -name USER_CLK1 [get_ports USER_CLK1]
create_clock -period 10.000 -name USER_CLK2 [get_ports USER_CLK2]

create_clock -period 8.000 -name PHY_RXCLK -waveform {0.000 4.000} [get_ports PHY_RXCLK]


