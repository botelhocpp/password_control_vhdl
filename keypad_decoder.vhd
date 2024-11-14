LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY keypad_decoder IS
PORT (
    keypad_row : IN nibble;
    
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    
    eoc : OUT STD_LOGIC;
    keypad_col : OUT nibble;
    data : OUT nibble
);
END ENTITY;

ARCHITECTURE rtl OF keypad_decoder IS
    SIGNAL counter : UNSIGNED(3 DOWNTO 0) := "0000";
    SIGNAL done : STD_LOGIC := '0';
BEGIN   
    eoc <= done;
    done <= keypad_row(TO_INTEGER(counter(3 DOWNTO 2)));
    data <= nibble(counter);
    
    PROCESS(counter)
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF(i = TO_INTEGER(counter(1 DOWNTO 0))) THEN
                keypad_col(i) <= '1';
            ELSE
                keypad_col(i) <= '0';
            END IF;
        END LOOP;
    END PROCESS;
    
    PROCESS(clk, rst)
    BEGIN
        IF(rst = '1') THEN
            counter <= "0000";
        ELSIF(RISING_EDGE(clk) AND done = '0') THEN
            counter <= counter + 1;
        END IF;
    END PROCESS;
END ARCHITECTURE;
