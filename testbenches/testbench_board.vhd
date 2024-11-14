LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY testbench_board IS
PORT (
    keypad_row : IN nibble;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    keypad_col : OUT nibble;
    lcd_rs : OUT STD_LOGIC;
    lcd_data : OUT nibble;
    lcd_rw : OUT STD_LOGIC;
    lcd_e : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF testbench_board IS
    SIGNAL clk_50mhz, locked : STD_LOGIC;
BEGIN
    CLK_WIZ_COMP : ENTITY WORK.clk_wiz_0
    PORT MAP (
        clk_in => clk,
        reset => rst,
        clk_out => clk_50mhz,
        locked => locked
    );
    PASSWORD_SYSTEM_COMP: ENTITY WORK.password_system
    PORT MAP (
        keypad_row => keypad_row,
        clk => clk_50mhz,
        rst => rst,
        keypad_col => keypad_col,
        lcd_rs => lcd_rs,
        lcd_data => lcd_data,
        lcd_rw => lcd_rw,
        lcd_e => lcd_e
    );
END ARCHITECTURE;