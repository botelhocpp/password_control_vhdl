LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY testbench_simulation IS
END ENTITY;

ARCHITECTURE behavioral OF testbench_simulation IS
    TYPE test_t IS ARRAY (0 TO 2) OF byte;
    CONSTANT TEST_DATA : test_t := (
        x"30", x"30", x"02"
    );

    CONSTANT CLK_50MHZ_PERIOD : TIME := 20ns;

    SIGNAL fpga_clk, rst : STD_LOGIC := '0';
    SIGNAL lcd_rs, lcd_rw, lcd_e, rs, vi, ready : STD_LOGIC := '0';
    SIGNAL lcd_data, keypad_row, keypad_col : nibble;
    
    SIGNAL data_to_lcd : byte := "00000000";
    SIGNAL valid_bit : STD_LOGIC := '0';
    SIGNAL lcd_ready : STD_LOGIC := '0';
    SIGNAL lcd_data_intermediary : byte := "00000000";
    SIGNAL lcd_rs_intermediary : STD_LOGIC := '0';
    SIGNAL lcd_valid_intermediary : STD_LOGIC := '0';
BEGIN
    PASSWORD_SYSTEM_COMP: ENTITY WORK.password_system
    PORT MAP (
        keypad_row => keypad_row,
        clk => fpga_clk,
        rst => rst,
        keypad_col => keypad_col,
        lcd_rs => lcd_rs,
        lcd_data => lcd_data,
        lcd_rw => lcd_rw,
        lcd_e => lcd_e
    );
    
    fpga_clk <= NOT fpga_clk AFTER CLK_50MHZ_period/2;
    rst <= '1', '0' AFTER CLK_50MHZ_period/4;

    PROCESS
    BEGIN
        WAIT FOR 50ms;
        keypad_row <= "0010";
        WAIT;
    END PROCESS; 

END ARCHITECTURE;
