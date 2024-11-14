##Clock signal
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L11P_T1_SRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 [get_ports { clk }];

##Buttons
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports rst]; #IO_L20N_T3_34 Sch=BTN0

##Pmod Header JB
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { lcd_e }]; #IO_L15P_T2_DQS_34 Sch=JB1_p
set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { lcd_rw  }]; #IO_L15N_T2_DQS_34 Sch=JB1_N
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }]; #IO_L16P_T2_34 Sch=JB2_P
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[3] }]; #IO_L17P_T2_34 Sch=JB3_P
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[2] }]; #IO_L17N_T2_34 Sch=JB3_N
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[1] }]; #IO_L22P_T3_34 Sch=JB4_P
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[0] }]; #IO_L22N_T3_34 Sch=JB4_N

##Pmod Header JC
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { keypad_row[0] }]; #IO_L10P_T1_34 Sch=JC1_P
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { keypad_row[1] }]; #IO_L10N_T1_34 Sch=JC1_N
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { keypad_row[2] }]; #IO_L1P_T0_34 Sch=JC2_P
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { keypad_row[3] }]; #IO_L1N_T0_34 Sch=JC2_N
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { keypad_col[0] }]; #IO_L8P_T1_34 Sch=JC3_P
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { keypad_col[1] }]; #IO_L8N_T1_34 Sch=JC3_N
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { keypad_col[2] }]; #IO_L2P_T0_34 Sch=JC4_P
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { keypad_col[3] }]; #IO_L2N_T0_34 Sch=JC4_N

set_property PULLDOWN TRUE [get_ports keypad_row[0]]
set_property PULLDOWN TRUE [get_ports keypad_row[1]]
set_property PULLDOWN TRUE [get_ports keypad_row[2]]
set_property PULLDOWN TRUE [get_ports keypad_row[3]]
