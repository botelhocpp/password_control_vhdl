LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY password_system IS
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

ARCHITECTURE rtl OF password_system IS
    TYPE password_t IS ARRAY (5 DOWNTO 0) OF nibble;
    CONSTANT CORRECT_PASSWORD : password_t := (
        x"0", x"1", x"2", x"4", x"5", x"6" 
    );
    SIGNAL password : password_t := (OTHERS => (OTHERS => '0'));
    
    SIGNAL password_it : INTEGER RANGE 0 TO password'LENGTH;
    
    SIGNAL keypad_data : nibble := (OTHERS => '0');
    SIGNAL data_to_lcd, lcd_data_intermediary : byte := (OTHERS => '0');
    SIGNAL valid_bit, eoc : STD_LOGIC := '0';
    SIGNAL lcd_ready, lcd_rs_intermediary, lcd_valid_intermediary : STD_LOGIC := '0';
BEGIN
    KEYPAD_DECODER_COMP: ENTITY WORK.keypad_decoder
    PORT MAP (
        keypad_row => keypad_row,
        clk => clk,
        rst => rst,
        eoc => eoc,
        keypad_col => keypad_col,
        data => keypad_data
    );
    EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => eoc,
        clk => clk,
        rst => rst,
        posedge => valid_bit
    );
    LCD_INTERFACE_COMP: ENTITY WORK.lcd_interface
    PORT MAP (
        din => data_to_lcd,
        vi => valid_bit,
        ready => lcd_ready,
        clk => clk,
        rst => rst,
        dout => lcd_data_intermediary,
        rs => lcd_rs_intermediary,
        vo => lcd_valid_intermediary
    );
    LCD_DRIVER_COMP: ENTITY WORK.lcd_driver
    PORT MAP (
        data => lcd_data_intermediary,
        rs => lcd_rs_intermediary,
        vi => lcd_valid_intermediary,
        clk => clk,
        rst => rst,
        ready => lcd_ready,
        lcd_rs => lcd_rs,
        lcd_data => lcd_data,
        lcd_rw => lcd_rw,
        lcd_e => lcd_e
    );
    
    data_to_lcd <=  x"01" WHEN (keypad_data = x"3" AND password = CORRECT_PASSWORD) ELSE
                    x"02" WHEN (keypad_data = x"3" AND password /= CORRECT_PASSWORD) ELSE
                    KeyDecode(keypad_data);
                                
    PROCESS(clk, rst)
    BEGIN
        IF(rst = '1') THEN
            password <= (OTHERS => (OTHERS => '0'));
            password_it <= 0;
        ELSIF(RISING_EDGE(clk)) THEN
            IF(valid_bit = '1') THEN
                IF(keypad_data = x"3") THEN
                    password <= (OTHERS => (OTHERS => '0'));
                    password_it <= 0;
                ELSIF(password_it < password'LENGTH) THEN
                    password(password'LENGTH - password_it - 1) <= keypad_data;
                    password_it <= password_it + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;