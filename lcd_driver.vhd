-- Implements a FSM to write data and commands to the LCD.
-- Also, initializes the LCD with a fixed sequence.
-- After the initialization, writes to the LCD after a pulse in VI.
-- At last, generates a READY signal when ready to transmit.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY lcd_driver IS
PORT (
    data : IN byte;
    rs : IN STD_LOGIC;
    vi : IN STD_LOGIC;
    
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    
    ready : OUT STD_LOGIC;
    lcd_rs : OUT STD_LOGIC;
    lcd_data : OUT nibble;
    lcd_rw : OUT STD_LOGIC;
    lcd_e : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF lcd_driver IS
    CONSTANT MAX_NUMBER_CYCLES : INTEGER := 750000;
    
    TYPE sequence_element_t IS RECORD
        data : nibble;
        e : STD_LOGIC;
        cnt : INTEGER RANGE 0 TO MAX_NUMBER_CYCLES;
    END RECORD;
    
    TYPE init_sequence_t IS ARRAY (0 TO 8) OF sequence_element_t;
    
    CONSTANT INIT_SEQUENCE : init_sequence_t := (
        ("0000", '0', 750000),  -- 15ms
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 205000),  -- 4.1 ms 
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 5000),    -- 100 μs
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 2000),    -- 40μs
        ("0010", '1', 12),      -- 240ns
        ("0000", '0', 2000)     -- 40μs
    );
    
    TYPE lcd_state_physical_t IS (
        INIT_SETUP,
        IDLE,
        SEND_HIGH_NIBBLE, 
        PULSE_EN_01, 
        DELAY_01, 
        SEND_LOW_NIBBLE,
        PULSE_EN_02, 
        DELAY_02
    );
    SIGNAL state : lcd_state_physical_t;
    
    SIGNAL counter : INTEGER RANGE 0 TO MAX_NUMBER_CYCLES;
    SIGNAL init_it : INTEGER RANGE 0 TO INIT_SEQUENCE'LENGTH;
BEGIN
    lcd_rw <= '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF(rst = '1') THEN
            state <= INIT_SETUP;
            counter <= 0;
            init_it <= 0;
            
            ready <= '0';
            lcd_rs <= '0';
            lcd_e <= '0';
            lcd_data <= "0000";
        ELSIF(RISING_EDGE(clk)) THEN
            -- Default
            lcd_rs <= rs;
            
            CASE state IS
                WHEN INIT_SETUP =>
                    lcd_rs <= '0';
                    IF(init_it = INIT_SEQUENCE'LENGTH) THEN
                        state <= IDLE;
                    ELSE
                        IF(counter < INIT_SEQUENCE(init_it).cnt) THEN
                            lcd_data <= INIT_SEQUENCE(init_it).data;
                            lcd_e <= INIT_SEQUENCE(init_it).e;
                            counter <= counter + 1;
                        ELSE
                            counter <= 0;
                            init_it <= init_it + 1;
                        END IF;
                    END IF;
                
                WHEN IDLE =>
                    lcd_e <= '0';
                    IF(vi = '1') THEN
                        state <= SEND_HIGH_NIBBLE;
                        ready <= '0';
                    ELSE
                        ready <= '1';
                    END IF;    
                    
                WHEN SEND_HIGH_NIBBLE => 
                    lcd_data <= data(7 DOWNTO 4);
                    lcd_e <= '0';
                    ready <= '0';
                    
                    -- Wait 40ns
                    IF(counter < 2) THEN
                        counter <= counter + 1;
                    ELSE
                        counter <= 0;
                        state <= PULSE_EN_01;
                    END IF;
                    lcd_e <= '0';
                    
                WHEN PULSE_EN_01 =>
                    -- Wait 240ns
                    IF(counter < 12) THEN
                        counter <= counter + 1;
                    ELSE
                        counter <= 0;
                        state <= DELAY_01;
                    END IF;
                    lcd_e <= '1'; 
                    
                WHEN DELAY_01 =>
                    -- Wait 1us
                    IF(counter < 50) THEN
                        counter <= counter + 1;
                    ELSE
                        counter <= 0;
                        state <= SEND_LOW_NIBBLE;
                    END IF;
                    lcd_e <= '0';
                    
                WHEN SEND_LOW_NIBBLE =>
                    -- Wait 40ns
                    IF(counter < 2) THEN
                        counter <= counter + 1;
                    ELSE
                        counter <= 0;
                        state <= PULSE_EN_02;
                    END IF;
                    lcd_e <= '0';      
                    lcd_data <= data(3 DOWNTO 0);
                    
                WHEN PULSE_EN_02 =>
                    -- Wait 240ns
                    IF(counter < 12) THEN
                        counter <= counter + 1;
                    ELSE
                        counter <= 0;
                        state <= DELAY_02;
                    END IF;
                    lcd_e <= '1'; 
                    
                WHEN DELAY_02 =>
                    IF(data = x"01") THEN
                        -- Wait 1.64ms
                        IF(counter < 82000) THEN
                            counter <= counter + 1;
                        ELSE
                            counter <= 0;
                            state <= IDLE;
                        END IF;
                    ELSE
                        -- Wait 40us
                        IF(counter < 2000) THEN
                            counter <= counter + 1;
                        ELSE
                            counter <= 0;
                            state <= IDLE;
                        END IF;
                    END IF;
                    lcd_e <= '0';
            END CASE;
        END IF;
    END PROCESS;    
END ARCHITECTURE;
