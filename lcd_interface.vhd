LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY lcd_interface IS
PORT (
    din : IN byte;
    vi : IN STD_LOGIC;
    ready : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    dout : OUT byte;
    rs : OUT STD_LOGIC;
    vo : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF lcd_interface IS  
    -- LCD Character/Command 
    TYPE lcd_data_t IS RECORD
        data : byte;
        rs : STD_LOGIC;
    END RECORD;
    
    -- Configuration sequence
    TYPE conf_sequence_t IS ARRAY (0 TO 4) OF lcd_data_t;
    CONSTANT CONF_SEQUENCE : conf_sequence_t := (
        (x"28", '0'), -- Function Set
        (x"08", '0'), -- Display Off
        (x"01", '0'), -- Clear
        (x"06", '0'), -- Entry Mode Set
        (x"0C", '0')  -- Display On
    );
    
    -- Main text "Password: "
    TYPE main_string_t IS ARRAY (0 TO 10) OF lcd_data_t;
    CONSTANT MAIN_STRING : main_string_t := (
        (x"01", '0'),  -- Clear display and go to home
        (x"50", '1'),  -- P
        (x"61", '1'),  -- a
        (x"73", '1'),  -- s
        (x"73", '1'),  -- s
        (x"77", '1'),  -- w
        (x"6F", '1'),  -- o
        (x"72", '1'),  -- r
        (x"64", '1'),  -- d
        (x"3A", '1'),  -- :
        (x"20", '1')   -- (SPACE)
    );
          
    -- Success text "Correct Password"
    TYPE success_string_t IS ARRAY (0 TO 16) OF lcd_data_t;
    CONSTANT SUCCESS_STRING : success_string_t := (
        (x"C0", '0'),  -- Go to second line
        (x"43", '1'),  -- C
        (x"6F", '1'),  -- o
        (x"72", '1'),  -- r
        (x"72", '1'),  -- r
        (x"65", '1'),  -- e
        (x"63", '1'),  -- c
        (x"74", '1'),  -- t
        (x"20", '1'),  -- 
        (x"50", '1'),  -- P
        (x"61", '1'),  -- a
        (x"73", '1'),  -- s
        (x"73", '1'),  -- s
        (x"77", '1'),  -- w
        (x"6F", '1'),  -- o
        (x"72", '1'),  -- r
        (x"64", '1')   -- d
    );
    
    -- Error text "Invalid Password"
    TYPE error_string_t IS ARRAY (0 TO 16) OF lcd_data_t;
    CONSTANT ERROR_STRING : error_string_t := (
        (x"C0", '0'),  -- Go to second line
        (x"49", '1'),  -- I
        (x"6E", '1'),  -- n
        (x"76", '1'),  -- v
        (x"61", '1'),  -- a
        (x"6C", '1'),  -- l
        (x"69", '1'),  -- i
        (x"64", '1'),  -- d
        (x"20", '1'),  -- 
        (x"50", '1'),  -- P
        (x"61", '1'),  -- a
        (x"73", '1'),  -- s
        (x"73", '1'),  -- s
        (x"77", '1'),  -- w
        (x"6F", '1'),  -- o
        (x"72", '1'),  -- r
        (x"64", '1')   -- d
    );

    TYPE lcd_state_data_t IS (
        INIT, 
        CONFIG, 
        MAIN_TEXT, 
        KEYPAD_DATA,
        SUCCESS_TEXT,
        ERROR_TEXT
    );
    
    SIGNAL data : byte := x"00";
    SIGNAL ready_posedge : STD_LOGIC := '0';
    SIGNAL state : lcd_state_data_t := INIT;
    SIGNAL counter : INTEGER RANGE 0 TO 150000000 := 0;
    SIGNAL config_it : INTEGER RANGE 0 TO CONF_SEQUENCE'LENGTH := 0;
    SIGNAL main_string_it : INTEGER RANGE 0 TO MAIN_STRING'LENGTH := 0;
    SIGNAL success_string_it : INTEGER RANGE 0 TO SUCCESS_STRING'LENGTH := 0;
    SIGNAL error_string_it : INTEGER RANGE 0 TO ERROR_STRING'LENGTH := 0;
BEGIN
    EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => ready,
        clk => clk,
        rst => rst,
        posedge => ready_posedge
    );
    DATA_REGISTER_COMP: ENTITY WORK.generic_register
    GENERIC MAP ( N => 8 )
    PORT MAP (
        D => din,
        ld => vi,
        clk => clk,
        rst => rst,
        Q => data
    );
    
    PROCESS(clk, rst)
    BEGIN
        IF(rst = '1') THEN
            state <= INIT;
            vo <= '0';
            dout <= (OTHERS => '0');
            rs <= '0';
            counter <= 0;
            config_it <= 0;
            main_string_it <= 0;
            success_string_it <= 0;
            error_string_it <= 0;
        ELSIF(RISING_EDGE(clk)) THEN
            CASE state IS
                WHEN INIT =>
                    IF(ready = '1') THEN
                        state <= CONFIG;
                    END IF;
                    
                WHEN CONFIG =>
                    IF(config_it = CONF_SEQUENCE'LENGTH) THEN
                        state <= MAIN_TEXT;
                    ELSE
                        IF(ready = '1' AND config_it < CONF_SEQUENCE'LENGTH - 1) THEN
                            vo <= '1';
                        ELSE
                            vo <= '0';
                        END IF;
                        
                        IF(ready_posedge = '1') THEN
                            config_it <= config_it + 1;
                        END IF;
                        
                        rs <= CONF_SEQUENCE(config_it).rs;
                        dout <= CONF_SEQUENCE(config_it).data;
                    END IF;
                    
                WHEN MAIN_TEXT =>
                    IF(main_string_it = MAIN_STRING'LENGTH) THEN
                        state <= KEYPAD_DATA;
                        main_string_it <= 0;
                    ELSE
                        IF(ready = '1' AND main_string_it < MAIN_STRING'LENGTH - 1) THEN
                            vo <= '1';
                        ELSE
                            vo <= '0';
                        END IF;
                        
                        IF(ready_posedge = '1') THEN
                            main_string_it <= main_string_it + 1;
                        END IF;
                        
                        dout <= MAIN_STRING(main_string_it).data;
                        rs <= MAIN_STRING(main_string_it).rs;
                    END IF;
                    
                WHEN KEYPAD_DATA =>
                    IF(vi = '1' AND din = x"01") THEN
                        state <= SUCCESS_TEXT;
                        dout <= (OTHERS => '0');
                        vo <= '0';
                        rs <= '1';
                    ELSIF(vi = '1' AND din = x"02") THEN
                        state <= ERROR_TEXT;
                        dout <= (OTHERS => '0');
                        vo <= '0';
                        rs <= '1';
                    ELSE
                        vo <= vi;
                        rs <= '1';
                        dout <= data;
                    END IF;
                    
                WHEN ERROR_TEXT =>
                    IF(error_string_it = ERROR_STRING'LENGTH) THEN
                        IF(counter = 150000000) THEN
                            counter <= 0;
                            state <= MAIN_TEXT;
                            error_string_it <= 0;
                        ELSE
                            counter <= counter + 1;
                        END IF;
                    ELSE
                        IF(ready = '1' AND error_string_it < ERROR_STRING'LENGTH - 1) THEN
                            vo <= '1';
                        ELSE
                            vo <= '0';
                        END IF;
                        
                        IF(ready_posedge = '1') THEN
                            error_string_it <= error_string_it + 1;
                        END IF;
                        
                        dout <= ERROR_STRING(error_string_it).data;
                        rs <= ERROR_STRING(error_string_it).rs;
                    END IF;
                    
                WHEN SUCCESS_TEXT =>
                    IF(success_string_it = SUCCESS_STRING'LENGTH) THEN
                        IF(counter = 150000000) THEN
                            counter <= 0;
                            state <= MAIN_TEXT;
                            success_string_it <= 0;
                        ELSE
                            counter <= counter + 1;
                        END IF;
                    ELSE
                        IF(ready = '1' AND success_string_it < SUCCESS_STRING'LENGTH - 1) THEN
                            vo <= '1';
                        ELSE
                            vo <= '0';
                        END IF;
                        
                        IF(ready_posedge = '1') THEN
                            success_string_it <= success_string_it + 1;
                        END IF;
                        
                        dout <= SUCCESS_STRING(success_string_it).data;
                        rs <= SUCCESS_STRING(success_string_it).rs;
                    END IF;
                WHEN OTHERS =>
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;
