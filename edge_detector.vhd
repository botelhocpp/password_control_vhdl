LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY edge_detector IS
PORT (
    A : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    posedge : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF edge_detector IS
    SIGNAL data : STD_LOGIC := '0';
BEGIN
    posedge <= (NOT data) AND A;

    -- Flip-Flop
    PROCESS(rst, clk)
    BEGIN
        IF(rst = '1') THEN
            data <= '0';
        ELSIF(RISING_EDGE(clk)) THEN
            data <= A;
        END IF;
    END PROCESS;
END ARCHITECTURE;