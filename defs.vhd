LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE defs IS 
    SUBTYPE nibble IS STD_LOGIC_VECTOR(3 DOWNTO 0);  
    SUBTYPE byte IS STD_LOGIC_VECTOR(7 DOWNTO 0);    
    SUBTYPE sbyte IS SIGNED(7 DOWNTO 0);  
    SUBTYPE ubyte IS UNSIGNED(7 DOWNTO 0);  
    
    FUNCTION hex2ssd(hex : nibble) RETURN STD_LOGIC_VECTOR;
    
    FUNCTION KeyDecode(key : nibble) RETURN byte;
END defs;

PACKAGE BODY defs IS 
    FUNCTION hex2ssd(hex : nibble) RETURN STD_LOGIC_VECTOR IS
        VARIABLE ssd : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        CASE TO_INTEGER(UNSIGNED(hex)) IS
            WHEN 0 => ssd := "0111111";
            WHEN 1 => ssd := "0000110";
            WHEN 2 => ssd := "1011011";
            WHEN 3 => ssd := "1001111";
            WHEN 4 => ssd := "1100110"; 
            WHEN 5 => ssd := "1101101";
            WHEN 6 => ssd := "1111101";
            WHEN 7 => ssd := "0000111";
            WHEN 8 => ssd := "1111111";
            WHEN 9 => ssd := "1100111";
            WHEN 10 => ssd := "1110111";
            WHEN 11 => ssd := "1111100";
            WHEN 12 => ssd := "0111001";
            WHEN 13 => ssd := "1011110";
            WHEN 14 => ssd := "1111001";
            WHEN 15 => ssd := "1110001";
        END CASE;
        
        RETURN ssd;
    END FUNCTION;
    
    FUNCTION KeyDecode(key : nibble) RETURN byte IS
        VARIABLE char : byte := x"00";
    BEGIN
        CASE key IS
            WHEN "0000" => char := x"31";
            WHEN "0001" => char := x"32";
            WHEN "0010" => char := x"33";
            WHEN "0011" => char := x"41";
            WHEN "0100" => char := x"34";
            WHEN "0101" => char := x"35";
            WHEN "0110" => char := x"36";
            WHEN "0111" => char := x"42";
            WHEN "1000" => char := x"37";
            WHEN "1001" => char := x"38";
            WHEN "1010" => char := x"39";
            WHEN "1011" => char := x"43";
            WHEN "1100" => char := x"2A";
            WHEN "1101" => char := x"30";
            WHEN "1110" => char := x"23";
            WHEN "1111" => char := x"44";
            WHEN OTHERS => char := x"00";
        END CASE;
    
        RETURN char;
    END FUNCTION;
END defs;