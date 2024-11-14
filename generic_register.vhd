LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY PROJECT;
USE PROJECT.DEFS.ALL;

ENTITY generic_register IS
GENERIC ( N : INTEGER := 8);
PORT (
    D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    ld : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE rtl OF generic_register IS
BEGIN    
    PROCESS(clk, rst, ld)
    BEGIN
        IF(rst = '1') THEN
            Q <= (OTHERS => '0');
        ELSIF(RISING_EDGE(clk) AND ld = '1') THEN
            Q <= D;
        END IF;
    END PROCESS;
END ARCHITECTURE;